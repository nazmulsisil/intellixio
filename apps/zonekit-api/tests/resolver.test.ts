import 'dotenv/config';
import { test } from 'node:test';
import assert from 'node:assert';
import { resolveZoneLogic, normalizeText, ZoneCandidate } from '../src/resolver';

test('normalizeText handles whitespace and punctuation', () => {
    assert.strictEqual(normalizeText('  Dhaka, BD  '), 'dhaka bd');
    assert.strictEqual(normalizeText('Uttara-12'), 'uttara 12');
    assert.strictEqual(normalizeText('St. Martin\'s Island!'), 'st martin s island');
});

test('resolveZoneLogic - no candidates', () => {
    const result = resolveZoneLogic([]);
    assert.strictEqual(result.resolved, false);
    assert.match(result.reason, /No candidates/);
});

test('resolveZoneLogic - resolved with single candidate', () => {
    const candidates: ZoneCandidate[] = [
        { id: '1', name: 'Dhaka', normalized: 'dhaka', admin_level: 2, area_m2: 100, score: 0.9 },
    ];
    // With env defaults: MIN_TOP_SCORE = 0.35
    const result = resolveZoneLogic(candidates);
    assert.strictEqual(result.resolved, true);
    assert.strictEqual(result.zone?.id, '1');
});

test('resolveZoneLogic - resolved with margin', () => {
    const candidates: ZoneCandidate[] = [
        { id: '1', name: 'Dhaka', normalized: 'dhaka', admin_level: 2, area_m2: 100, score: 0.8 },
        { id: '2', name: 'Dhaka Bibhag', normalized: 'dhaka bibhag', admin_level: 2, area_m2: 100, score: 0.7 },
    ];
    // margin = 0.1 >= 0.08 defaults
    const result = resolveZoneLogic(candidates);
    assert.strictEqual(result.resolved, true);
    assert.strictEqual(result.zone?.id, '1');
});

test('resolveZoneLogic - ambiguous match', () => {
    const candidates: ZoneCandidate[] = [
        { id: '1', name: 'Mirpur', normalized: 'mirpur', admin_level: 2, area_m2: 100, score: 0.8 },
        { id: '2', name: 'Mirpud', normalized: 'mirpud', admin_level: 2, area_m2: 100, score: 0.75 },
        { id: '3', name: 'Mirp', normalized: 'mirp', admin_level: 2, area_m2: 100, score: 0.7 },
    ];
    // margin = 0.05 < 0.08 defaults
    const result = resolveZoneLogic(candidates);
    assert.strictEqual(result.resolved, false);
    assert.strictEqual(result.candidates?.length, 3); // Max candidates default is 3
    assert.match(result.reason, /Ambiguous/);
});

test('resolveZoneLogic - top score below threshold', () => {
    const candidates: ZoneCandidate[] = [
        { id: '1', name: 'Very weak match', normalized: 'very weak match', admin_level: 2, area_m2: 100, score: 0.2 },
    ];
    const result = resolveZoneLogic(candidates);
    assert.strictEqual(result.resolved, false);
    assert.match(result.reason, /below the minimum threshold/);
});
