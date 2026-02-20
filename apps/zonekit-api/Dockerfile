FROM node:20-alpine AS builder
WORKDIR /app
COPY pnpm-lock.yaml ./
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 4000
CMD ["node", "dist/index.js"]
