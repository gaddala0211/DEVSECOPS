# Build stage
FROM node:20-alpine AS build
WORKDIR /app
#COPY package*.json ./
#RUN npm ci
#COPY . .
#RUN npm run build

RUN npm config set registry https://registry.npmmirror.com
RUN npm install -g npm@11.4.2
COPY package*.json ./
RUN npm ci || (sleep 10 && npm ci) || (sleep 20 && npm ci)
COPY . .
RUN npm run build

# Production stage
#FROM nginx:alpine
FROM nginx:1.25.5-alpine3.19

# Upgrade vulnerable system libraries
RUN apk update && apk upgrade && apk add --no-cache \
    curl \
    libcurl \
    libexpat \
    libxml2 \
    libxslt \
    xz-libs \
    libcrypto3 \
    libssl3 \
    && rm -rf /var/cache/apk/*

COPY --from=build /app/dist /usr/share/nginx/html
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
