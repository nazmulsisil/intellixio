import { pool } from './db';

const RESOLVER_LIMIT = parseInt(process.env.RESOLVER_LIMIT || '5', 10);
const RESOLVER_MAX_CANDIDATES = parseInt(process.env.RESOLVER_MAX_CANDIDATES || '3', 10);
const RESOLVER_MIN_TOP_SCORE = parseFloat(process.env.RESOLVER_MIN_TOP_SCORE || '0.35');
const RESOLVER_MIN_MARGIN = parseFloat(process.env.RESOLVER_MIN_MARGIN || '0.08');

export interface ResolveZoneRequest {
    text: string;
}

export interface ZoneCandidate {
    id: string;
    name: string;
    normalized: string;
    admin_level: number;
    area_m2: number;
    score: number;
}

export interface ResolveZoneResponse {
    resolved: boolean;
    zone?: ZoneCandidate;
    candidates?: ZoneCandidate[];
    reason: string;
}

export const normalizeText = (text: string): string => {
    return text.toLowerCase().replace(/[^a-z0-9]/g, ' ').replace(/\s+/g, ' ').trim();
};

export const resolveZoneLogic = (candidates: ZoneCandidate[]): ResolveZoneResponse => {
    if (candidates.length === 0) {
        return { resolved: false, reason: 'No candidates matched the minimum similarity threshold.' };
    }

    const topCandidate = candidates[0];

    if (topCandidate.score < RESOLVER_MIN_TOP_SCORE) {
        return {
            resolved: false,
            candidates: candidates.slice(0, RESOLVER_MAX_CANDIDATES),
            reason: `Top candidate score (${topCandidate.score.toFixed(3)}) is below the minimum threshold (${RESOLVER_MIN_TOP_SCORE}).`
        };
    }

    if (candidates.length === 1) {
        return {
            resolved: true,
            zone: topCandidate,
            reason: 'Single strong candidate found.'
        };
    }

    const secondCandidate = candidates[1];
    const margin = topCandidate.score - secondCandidate.score;

    if (margin >= RESOLVER_MIN_MARGIN) {
        return {
            resolved: true,
            zone: topCandidate,
            reason: `Top candidate exceeded runner-up by margin of ${margin.toFixed(3)}.`
        };
    }

    return {
        resolved: false,
        candidates: candidates.slice(0, RESOLVER_MAX_CANDIDATES),
        reason: `Ambiguous match. Margin (${margin.toFixed(3)}) is below the required threshold (${RESOLVER_MIN_MARGIN}).`
    };
};

export const resolveZone = async (text: string): Promise<ResolveZoneResponse> => {
    const normalized = normalizeText(text);

    if (!normalized) {
        return { resolved: false, reason: 'Input text is empty after normalization.' };
    }

    const query = `
        SELECT id, name, normalized, admin_level, area_m2, similarity(normalized, $1) AS score
        FROM zendolead.zones
        WHERE similarity(normalized, $1) >= $2
        ORDER BY score DESC, area_m2 DESC
        LIMIT $3
    `;

    const { rows } = await pool.query<ZoneCandidate>(query, [normalized, 0, RESOLVER_LIMIT]);

    // We filter by min score manually instead of in DB if we want to ensure we see candidates that fail the threshold
    // or we can just pass the threshold to DB. The logic above expects candidates that might be below the threshold
    // so let's pass 0 to the DB query to see the top match regardless of score, then handle it in logic.

    return resolveZoneLogic(rows);
};
