import 'dotenv/config';
import { pool } from '../src/db';

const API_URL = process.env.API_URL || 'http://127.0.0.1:4000';
const API_KEY = process.env.ZONEKIT_INTERNAL_API_KEY || 'for_now_this_works';
const PRODUCT_1 = "d794f4bb-ca3a-4717-8dcf-fa89d8f95dae";
const PRODUCT_2 = "178fd86a-7b92-4233-a0a3-97fb25744c89";

async function main() {
    console.log(`Running smoke tests against ${API_URL}...`);

    try {
        // 1. healthz
        console.log("1. Checking /healthz");
        const healthRes = await fetch(`${API_URL}/healthz`);
        if (!healthRes.ok) throw new Error(`/healthz returned ${healthRes.status}`);
        console.log("  -> /healthz OK");

        // 2. resolve-zone (1 valid, 1 typo)
        console.log("2. Testing /v1/resolve-zone");
        const resolve1 = await fetch(`${API_URL}/v1/resolve-zone`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ text: "dhaka" })
        });
        if (!resolve1.ok) throw new Error(`Failed resolving dhaka: ${resolve1.status}`);
        console.log("  -> Resolved 'dhaka'");

        const resolve2 = await fetch(`${API_URL}/v1/resolve-zone`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ text: "dhhaka" })
        });
        if (!resolve2.ok) throw new Error(`Failed resolving typo dhhaka: ${resolve2.status}`);
        console.log("  -> Resolved 'dhhaka'");

        // 3. tag-product (2 points)
        console.log("3. Testing /v1/tag-product");
        const tag1 = await fetch(`${API_URL}/v1/tag-product`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-zonekit-key': API_KEY
            },
            body: JSON.stringify({ productId: PRODUCT_1, lat: 23.8103, lng: 90.4125 })
        });
        if (!tag1.ok) throw new Error(`Failed tagging ${PRODUCT_1}: ${tag1.status} ` + await tag1.text());
        console.log(`  -> Tagged ${PRODUCT_1}`);

        const tag2 = await fetch(`${API_URL}/v1/tag-product`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-zonekit-key': API_KEY
            },
            body: JSON.stringify({ productId: PRODUCT_2, lat: 22.3569, lng: 91.7832 })
        });
        if (!tag2.ok) throw new Error(`Failed tagging ${PRODUCT_2}: ${tag2.status} ` + await tag2.text());
        console.log(`  -> Tagged ${PRODUCT_2}`);

        // 4. verify DB rows updated
        console.log("4. Verifying DB rows");
        const verifyProducts = [PRODUCT_1, PRODUCT_2];
        let hasError = false;
        for (const productId of verifyProducts) {
            const result = await pool.query('SELECT product_id, leaf_zone_id FROM zendolead.product_geo WHERE product_id = $1', [productId]);
            if (result.rows.length === 0) {
                console.error(`Verification failed: Expected to find DB row for ${productId}`);
                hasError = true;
            } else {
                console.log(`  -> Validated DB row for ${productId}`);
            }
        }

        // Clean up test rows
        await pool.query('DELETE FROM zendolead.product_geo WHERE product_id = ANY($1)', [verifyProducts]);
        console.log(`  -> Cleaned up test data`);
        await pool.end();

        if (hasError) {
            process.exit(1);
        }

        console.log("Smoke test passed successfully.");
        process.exit(0);

    } catch (err) {
        console.error("Test failed:", err);
        process.exit(1);
    }
}

main();
