import { Pool } from 'pg';

if (!process.env.DATABASE_URL) {
    throw new Error('DATABASE_URL environment variable is not defined');
}

export const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

export const checkDbHealth = async (): Promise<boolean> => {
    try {
        await pool.query('SELECT 1');
        return true;
    } catch (error) {
        console.error('Database health check failed:', error);
        return false;
    }
};
