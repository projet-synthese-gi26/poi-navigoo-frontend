FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install && npm ci --prefer-offline

COPY . .

ARG API_BASE_URL=https://traefikdev.yowyob.com/poi-navigoo
RUN echo "API_BASE_URL=${API_BASE_URL}" > .env && \
    cat .env && \
    npm run build

FROM node:20-alpine AS runner

RUN apk add --no-cache curl

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000

CMD ["node", "server.js"]
