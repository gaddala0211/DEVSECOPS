# ---------- Build Stage ----------
FROM node:20-alpine AS build

# Install necessary packages for npm and native module builds
RUN apk add --no-cache python3 make g++ curl

# Set npm registry to avoid downtime and upgrade npm
RUN npm config set registry https://registry.npmmirror.com \
    && npm install -g npm@11.4.2

WORKDIR /app

# Copy dependency files and install dependencies with retry logic
COPY package*.json ./
RUN npm ci || (sleep 10 && npm ci) || (sleep 20 && npm ci)

# Copy the rest of the app and build
COPY . .
RUN npm run build

# ---------- Production Stage ----------
FROM nginx:1.25.5-alpine3.19

# Upgrade essential system libraries
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

# Copy build output to nginx web root
COPY --from=build /app/dist /usr/share/nginx/html

# Optional: Uncomment and add custom nginx config if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
