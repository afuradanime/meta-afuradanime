FROM node:20 AS builder

WORKDIR /app
COPY frontend/package*.json ./
RUN npm install

COPY frontend/. .
RUN npm run build

# Production image
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80