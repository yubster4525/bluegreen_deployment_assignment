FROM node:20-alpine AS base
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev

COPY src ./src

EXPOSE 3000
ENV PORT=3000 \
    APP_COLOR=blue \
    APP_ENV=blue \
    APP_VERSION=1.0.0

CMD ["node", "src/server.js"]
