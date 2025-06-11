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
RUN apk update && apk add --no-cache \
    curl=8.7.1-r0 \
    libcurl=8.7.1-r0 \
    libexpat=2.6.3-r0 \
    libxml2=2.11.8-r3 \
    libxslt=1.1.39-r1 \
    xz-libs=5.4.5-r1 \
    libcrypto3=3.1.7-r0 \
    libssl3=3.1.7-r0 \
    && rm -rf /var/cache/apk/*

COPY --from=build /app/dist /usr/share/nginx/html
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
