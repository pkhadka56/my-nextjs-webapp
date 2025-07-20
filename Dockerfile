FROM node:24.4.1-alpine3.22 AS base

FROM base AS builder

WORKDIR /app

COPY package.json yarn.lock ./

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build

FROM base AS runner

WORKDIR /app

RUN addgroup -g 1001 -S nodejs && \
    adduser -u 1001 -S nextjs -G nodejs

COPY --from=builder /app/.next .next
COPY --from=builder /app/package.json .
COPY --from=builder /app/yarn.lock .
COPY --from=builder /app/node_modules node_modules

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=8080

USER nextjs

EXPOSE 8080

CMD ["yarn", "start"]
