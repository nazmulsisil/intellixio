import fs from 'node:fs/promises';
import path from 'node:path';
import { Pool } from 'pg';
import { Root } from '../.agent/schemas/geojson';
import 'dotenv/config';

// Ensure DB URL is present
if (!process.env.DATABASE_URL) {
    throw new Error('DATABASE_URL is not set in environment or .env');
}

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

function normalizeGeometry(geom: any) {
    if (!geom) throw new Error('Null geometry');
    if (geom.type === 'Polygon') {
        return {
            type: 'MultiPolygon',
            coordinates: [geom.coordinates],
        };
    }
    if (geom.type === 'MultiPolygon') {
        return geom;
    }
    throw new Error(`Unsupported geometry type: ${geom.type}`);
}

async function safeUpsertFeature(client: any, feature: any, adminLevel: number) {
    const normGeom = normalizeGeometry(feature.geometry);
    const name = feature.properties.shapeName;
    const normalized = name.toLowerCase().replace(/[^a-z0-9\s]/g, '-').replace(/\s+/g, '-');
    const source_feature_id = feature.properties.shapeID;

    let iso = feature.properties.shapeISO || 'BGD';
    if (iso.includes('-')) {
        iso = iso.split('-')[0];
    }
    const region_key = 'dhaka';

    const geomStr = JSON.stringify(normGeom);

    const checkRes = await client.query(
        'SELECT id FROM zendolead.zones WHERE source = $1 AND source_feature_id = $2',
        ['geoBoundaries', source_feature_id]
    );

    if (checkRes.rowCount && checkRes.rowCount > 0) {
        const id = checkRes.rows[0].id;
        await client.query(`
      UPDATE zendolead.zones SET
        name = $1,
        normalized = $2,
        country_code = $3,
        region_key = $4,
        admin_level = $5,
        source_version = 'simplified',
        source_props = $6,
        boundary = ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON($7), 4326)),
        area_m2 = ST_Area(ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON($7), 4326))::geography),
        updated_at = now()
      WHERE id = $8
    `, [name, normalized, iso, region_key, adminLevel, feature.properties, geomStr, id]);
        return id;
    } else {
        const res = await client.query(`
      INSERT INTO zendolead.zones (
        name, normalized, country_code, region_key, admin_level,
        source, source_version, source_feature_id, source_props,
        boundary, area_m2
      ) VALUES (
        $1, $2, $3, $4, $5,
        'geoBoundaries', 'simplified', $6, $7,
        ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON($8), 4326)),
        ST_Area(ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON($8), 4326))::geography)
      ) RETURNING id
    `, [name, normalized, iso, region_key, adminLevel, source_feature_id, feature.properties, geomStr]);
        return res.rows[0].id;
    }
}

async function main() {
    const client = await pool.connect();
    try {
        const rawDir = path.join(__dirname, '../data/raw');

        console.log('Reading ADM2...');
        const adm2File = await fs.readFile(path.join(rawDir, 'geoBoundaries-BGD-ADM2_simplified.geojson'), 'utf8');
        const adm2Data = JSON.parse(adm2File) as Root;

        const dhakaFeature = adm2Data.features.find((f: any) => f.properties.shapeName === 'Dhaka');
        if (!dhakaFeature) {
            throw new Error('Dhaka ADM2 not found in file');
        }

        console.log('Upserting Dhaka ADM2...');
        const dhakaId = await safeUpsertFeature(client, dhakaFeature, 2);
        console.log(`Dhaka ADM2 upserted. ID: ${dhakaId}`);

        console.log('Reading ADM3...');
        const adm3File = await fs.readFile(path.join(rawDir, 'geoBoundaries-BGD-ADM3_simplified.geojson'), 'utf8');
        const adm3Data = JSON.parse(adm3File) as Root;

        console.log(`Upserting all ADM3 features (Total: ${adm3Data.features.length})...`);
        let adm3Count = 0;
        for (const feature of adm3Data.features) {
            await safeUpsertFeature(client, feature, 3);
            adm3Count++;
        }
        console.log(`Upserted ${adm3Count} ADM3 features.`);

        console.log('Reading ADM4...');
        const adm4File = await fs.readFile(path.join(rawDir, 'geoBoundaries-BGD-ADM4_simplified.geojson'), 'utf8');
        const adm4Data = JSON.parse(adm4File) as Root;

        console.log(`Upserting all ADM4 features (Total: ${adm4Data.features.length})...`);
        let adm4Count = 0;
        for (const feature of adm4Data.features) {
            await safeUpsertFeature(client, feature, 4);
            adm4Count++;
        }
        console.log(`Upserted ${adm4Count} ADM4 features.`);

        console.log('Import successful.');
    } catch (error) {
        console.error('Error during import:', error);
        process.exitCode = 1;
    } finally {
        client.release();
        pool.end();
    }
}

main();
