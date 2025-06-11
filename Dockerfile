# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
#FROM nginx:alpine
FROM nginx:1.25-alpine3.19
# Upgrade vulnerable system libraries
RUN apk update && \
    apk add --no-cache libcrypto3=3.1.7-r0 libssl3=3.1.7-r0 curl libcurl libexpat libxml2 libxslt xz-libs && \
    rm -rf /var/cache/apk/*

COPY --from=build /app/dist /usr/share/nginx/html
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
