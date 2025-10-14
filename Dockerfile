# Use Node.js 20 Alpine as base image for smaller size and better security
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Install dependencies required for native modules
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    libc6-compat

# Copy package files for dependency installation
COPY package*.json ./

# Development stage
FROM base AS development

# Install all dependencies (including devDependencies)
RUN npm ci

# Copy source code
COPY . .

# Expose the port
EXPOSE 3000

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership of the app directory
RUN chown -R nodejs:nodejs /app
USER nodejs

# Start the development server
CMD ["npm", "run", "dev"]

# Production dependencies stage
FROM base AS dependencies

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Production stage
FROM node:20-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Set working directory
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Copy production dependencies from dependencies stage
COPY --from=dependencies --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy source code and set ownership
COPY --chown=nodejs:nodejs . .

# Remove unnecessary files for production
RUN rm -rf tests/ *.md .git* .env* docker-compose* Dockerfile* .eslintrc* .prettierrc*

# Switch to non-root user
USER nodejs

# Expose the port
EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the production server
CMD ["node", "start"]