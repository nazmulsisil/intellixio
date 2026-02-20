import { pool } from './db';
import { FastifyRequest, FastifyReply } from 'fastify';

export interface TagProductResponse {
    success: boolean;
    productId: string;
    leafZoneId: string | null;
    zoneIds: string[];
}

export const tagProduct = async (
    productId: string,
    lat: number,
    lng: number
): Promise<TagProductResponse> => {
    // Convert point to 4326 geometry and find intersecting zones
    // Order by area_m2 ASC to find the most specific (smallest) zone first.
    const query = `
        SELECT id, area_m2
        FROM zendolead.zones
        WHERE ST_Covers(boundary, ST_SetSRID(ST_MakePoint($1, $2), 4326))
        ORDER BY area_m2 ASC
    `;

    const { rows } = await pool.query(query, [lng, lat]);

    const zoneIds = rows.map((row) => row.id);
    const leafZoneId = zoneIds.length > 0 ? zoneIds[0] : null;

    // Upsert to product_geo
    const upsertQuery = `
        INSERT INTO zendolead.product_geo (product_id, geom, zone_ids, leaf_zone_id, updated_at)
        VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326), $4, $5, now())
        ON CONFLICT (product_id) DO UPDATE SET
            geom = EXCLUDED.geom,
            zone_ids = EXCLUDED.zone_ids,
            leaf_zone_id = EXCLUDED.leaf_zone_id,
            updated_at = EXCLUDED.updated_at
    `;

    await pool.query(upsertQuery, [
        productId,
        lng,
        lat,
        zoneIds,
        leafZoneId
    ]);

    return {
        success: true,
        productId,
        leafZoneId,
        zoneIds
    };
};

export const tagProductHandler = async (request: FastifyRequest, reply: FastifyReply) => {
    // Enforce ZONEKIT_TAGGING_ENABLED
    if (process.env.ZONEKIT_TAGGING_ENABLED !== 'true') {
        reply.status(403);
        return { error: 'Tagging is not enabled' };
    }

    // Enforce x-zonekit-key
    const authKey = request.headers['x-zonekit-key'];
    const expectedKey = process.env.ZONEKIT_INTERNAL_API_KEY?.trim();
    console.log(`[DEBUG tagger.ts] authKey: "\${authKey}", expectedKey: "\${expectedKey}"`);
    if (!authKey || authKey !== expectedKey) {
        reply.status(401);
        return { error: 'Unauthorized' };
    }

    const body: any = request.body;
    if (!body || typeof body.productId !== 'string' || typeof body.lat !== 'number' || typeof body.lng !== 'number') {
        reply.status(400);
        return { error: 'Invalid request body. "productId", "lat", "lng" are required.' };
    }

    try {
        const result = await tagProduct(body.productId, body.lat, body.lng);
        return result;
    } catch (err) {
        request.log.error(err);
        reply.status(500);
        return { error: 'Internal Server Error' };
    }
};
