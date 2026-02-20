FROM node:24-alpine AS base

FROM base AS builder
RUN apk update
RUN apk add --no-cache libc6-compat
WORKDIR /app
RUN npm install -g turbo
COPY . .
RUN turbo prune zonekit-api --docker

FROM base AS installer
RUN apk update
RUN apk add --no-cache libc6-compat
WORKDIR /app

# First install the dependencies (as they change less often)
COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN corepack enable pnpm
RUN pnpm install --frozen-lockfile

# Build the project
COPY --from=builder /app/out/full/ .
RUN pnpm turbo run build --filter=zonekit-api

FROM base AS runner
WORKDIR /app

# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 fastify
USER fastify

COPY --from=installer --chown=fastify:nodejs /app/apps/zonekit-api/package.json ./apps/zonekit-api/package.json
COPY --from=installer --chown=fastify:nodejs /app/apps/zonekit-api/dist ./apps/zonekit-api/dist
# Copy root node_modules and app node_modules (which contains pnpm symlinks)
COPY --from=installer --chown=fastify:nodejs /app/node_modules ./node_modules
COPY --from=installer --chown=fastify:nodejs /app/apps/zonekit-api/node_modules ./apps/zonekit-api/node_modules

EXPOSE 4000
CMD ["node", "apps/zonekit-api/dist/index.js"]
