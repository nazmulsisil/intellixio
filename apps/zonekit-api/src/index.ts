import 'dotenv/config';
import Fastify from 'fastify';
import pino from 'pino';
import { pool, checkDbHealth } from './db';

// Validate environment variables
const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

const fastify = Fastify({
    logger:
        process.env.NODE_ENV === 'production'
            ? { level: LOG_LEVEL }
            : {
                level: LOG_LEVEL,
                transport: {
                    target: 'pino-pretty',
                    options: {
                        translateTime: 'HH:MM:ss Z',
                        ignore: 'pid,hostname',
                    },
                },
            },
});

fastify.get('/healthz', async (request, reply) => {
    const isDbHealthy = await checkDbHealth();
    const status = isDbHealthy ? 200 : 503;
    reply.status(status);
    return { ok: true, db: isDbHealthy };
});

const start = async () => {
    try {
        // Test database connection before starting the server
        const isDbConnected = await checkDbHealth();
        if (!isDbConnected) {
            fastify.log.error('Failed to connect to the database on startup.');
            process.exit(1);
        }
        fastify.log.info('Database connected successfully.');

        await fastify.listen({ port: PORT, host: '0.0.0.0' });
        fastify.log.info(`Server listening on port ${PORT}`);
    } catch (err) {
        fastify.log.error(err);
        process.exit(1);
    }
};

// Graceful shutdown
const shutdown = async () => {
    fastify.log.info('Shutting down server...');
    await fastify.close();
    await pool.end();
    process.exit(0);
};

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

start();
