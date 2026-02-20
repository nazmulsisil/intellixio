import 'dotenv/config';
import { test, mock } from 'node:test';
import assert from 'node:assert';
import { tagProduct, tagProductHandler } from '../src/tagger';
import { pool } from '../src/db';

test('tagProduct - returns proper hierarchy (multiple matched parent zones)', async () => {
    const mockQuery = mock.method(pool, 'query', async (query: string, params: any[]) => {
        if (query.includes('ST_Covers')) {
            return {
                rows: [
                    { id: 'zone-child', area_m2: 100 },
                    { id: 'zone-parent', area_m2: 1000 },
                    { id: 'zone-grandparent', area_m2: 10000 },
                ]
            };
        }
        if (query.includes('INSERT INTO zendolead.product_geo')) {
            return { rows: [] };
        }
        return { rows: [] };
    });

    const result = await tagProduct('prod-1', 23.0, 90.0);
    assert.strictEqual(result.success, true);
    assert.strictEqual(result.productId, 'prod-1');
    assert.strictEqual(result.leafZoneId, 'zone-child');
    assert.deepStrictEqual(result.zoneIds, ['zone-child', 'zone-parent', 'zone-grandparent']);

    mockQuery.mock.restore();
});

test('tagProductHandler - missing ZONEKIT_TAGGING_ENABLED', async () => {
    const originalEnv = process.env.ZONEKIT_TAGGING_ENABLED;
    process.env.ZONEKIT_TAGGING_ENABLED = 'false';

    const req = { headers: {}, body: {} } as any;
    const res = {
        code: 0,
        body: null,
        status(c: number) { this.code = c; return this; },
        send(b: any) { this.body = b; return this; },
    } as any;

    const response = await tagProductHandler(req, res);
    assert.strictEqual(res.code, 403);
    assert.match((response as any).error, /Tagging is not enabled/);

    process.env.ZONEKIT_TAGGING_ENABLED = originalEnv;
});

test('tagProductHandler - missing x-zonekit-key', async () => {
    const originalEnv = process.env.ZONEKIT_TAGGING_ENABLED;
    process.env.ZONEKIT_TAGGING_ENABLED = 'true';

    const req = { headers: {}, body: {} } as any;
    const res = {
        code: 0,
        body: null,
        status(c: number) { this.code = c; return this; },
        send(b: any) { this.body = b; return this; },
    } as any;

    const response = await tagProductHandler(req, res);
    assert.strictEqual(res.code, 401);
    assert.match((response as any).error, /Unauthorized/);

    process.env.ZONEKIT_TAGGING_ENABLED = originalEnv;
});

test('tagProductHandler - valid request parameters', async () => {
    const originalEnv = process.env.ZONEKIT_TAGGING_ENABLED;
    const originalKey = process.env.ZONEKIT_INTERNAL_API_KEY;
    process.env.ZONEKIT_TAGGING_ENABLED = 'true';
    process.env.ZONEKIT_INTERNAL_API_KEY = 'test-key';

    const req = {
        headers: { 'x-zonekit-key': 'test-key' },
        body: { productId: 'prod-1', lat: 23.0, lng: 90.0 }
    } as any;

    req.log = { error: () => { } };

    const res = {
        code: 0,
        body: null,
        status(c: number) { this.code = c; return this; },
        send(b: any) { this.body = b; return this; },
    } as any;

    const mockQuery = mock.method(pool, 'query', async (query: string, params: any[]) => {
        return { rows: [{ id: 'z1', area_m2: 10 }] };
    });

    const response = await tagProductHandler(req, res);
    assert.strictEqual((response as any).success, true);
    assert.strictEqual((response as any).productId, 'prod-1');

    mockQuery.mock.restore();
    process.env.ZONEKIT_TAGGING_ENABLED = originalEnv;
    process.env.ZONEKIT_INTERNAL_API_KEY = originalKey;
});
