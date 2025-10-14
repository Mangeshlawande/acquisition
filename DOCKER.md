# Docker Deployment Guide

This guide explains how to deploy the Acquisition System API using Docker with different configurations for development and production environments.

## Overview

The application supports two deployment modes:

1. **Development Mode**: Uses Neon Local proxy for ephemeral database branches
2. **Production Mode**: Connects directly to Neon Cloud database

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Neon account with API key and project setup

## Quick Start

### Development Environment

For local development with ephemeral database branches:

```bash
# 1. Copy and configure development environment
cp .env.development .env.dev.local
# Edit .env.dev.local with your Neon credentials

# 2. Start development environment
docker-compose -f docker-compose.dev.yml --env-file .env.dev.local up -d

# 3. View logs
docker-compose -f docker-compose.dev.yml logs -f app

# 4. Stop development environment
docker-compose -f docker-compose.dev.yml down
```

### Production Environment

For production deployment:

```bash
# 1. Configure production environment
cp .env.production .env.prod.local
# Edit .env.prod.local with your production credentials

# 2. Start production environment
docker-compose -f docker-compose.prod.yml --env-file .env.prod.local up -d

# 3. View logs
docker-compose -f docker-compose.prod.yml logs -f app

# 4. Stop production environment
docker-compose -f docker-compose.prod.yml down
```

## Environment Configuration

### Development Environment Variables

Create `.env.dev.local` with:

```bash
# Neon Local Configuration
NEON_API_KEY=your_neon_api_key
NEON_PROJECT_ID=your_neon_project_id  
PARENT_BRANCH_ID=your_parent_branch_id

# Application Configuration
JWT_SECRET=your_development_jwt_secret
ARCJET_KEY=your_development_arcjet_key
```

### Production Environment Variables

Create `.env.prod.local` with:

```bash
# Production Database (Neon Cloud)
DATABASE_URL=postgresql://user:password@endpoint.neon.tech/dbname?sslmode=require

# Application Configuration
JWT_SECRET=your_production_jwt_secret_strong_random_key
ARCJET_KEY=your_production_arcjet_key
LOG_LEVEL=info
```

## Architecture Details

### Development Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Developer     │    │   Neon Local     │    │   Neon Cloud    │
│   Application   │────│   Proxy          │────│   Database      │
│   (localhost)   │    │   (Ephemeral)    │    │   (Main)        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

- **Neon Local Proxy**: Creates ephemeral database branches automatically
- **Hot Reloading**: Source code changes trigger automatic restarts
- **Fresh Data**: Each container restart gets a clean database branch

### Production Architecture

```
┌─────────────────┐                           ┌─────────────────┐
│   Production    │                           │   Neon Cloud    │
│   Application   │───────────────────────────│   Database      │
│   (Docker)      │                           │   (Production)  │
└─────────────────┘                           └─────────────────┘
```

- **Direct Connection**: App connects directly to Neon Cloud
- **Production Optimized**: Minimal attack surface and resource usage
- **Health Checks**: Automatic container health monitoring

## Docker Images

### Multi-Stage Build

The Dockerfile uses multi-stage builds for optimization:

1. **Base**: Common setup and dependencies
2. **Development**: Includes dev dependencies and hot reloading
3. **Dependencies**: Production-only dependencies
4. **Production**: Minimal, secure runtime image

### Build Targets

```bash
# Build development image
docker build --target development -t acquisitions:dev .

# Build production image  
docker build --target production -t acquisitions:prod .

# Build specific stage
docker build --target dependencies -t acquisitions:deps .
```

## Database Management

### Development Database Workflow

1. **Automatic Branch Creation**: Neon Local creates ephemeral branches
2. **Migration Handling**: Run migrations against the ephemeral branch
3. **Clean Slate**: Each restart provides a fresh database

```bash
# Run migrations in development
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Open Drizzle Studio
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

### Production Database Workflow

1. **Pre-deployment**: Run migrations against production database
2. **Connection Pooling**: Uses Neon's connection pooler
3. **SSL Required**: All connections use SSL/TLS

```bash
# Run production migrations (before deployment)
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

## Security Considerations

### Development Security

- Uses development JWT secrets
- Debug logging enabled
- Containers run with elevated privileges for development tools

### Production Security

- **Non-root User**: Containers run as non-privileged user (`nodejs`)
- **Read-only Filesystem**: Container filesystem is read-only
- **Minimal Capabilities**: Only essential Linux capabilities enabled
- **No New Privileges**: Prevents privilege escalation
- **Resource Limits**: CPU and memory constraints applied
- **Health Checks**: Automatic container health monitoring

## Monitoring and Logging

### Log Management

```bash
# View application logs
docker-compose -f docker-compose.prod.yml logs app

# Follow logs in real-time
docker-compose -f docker-compose.prod.yml logs -f app

# View logs with timestamps
docker-compose -f docker-compose.prod.yml logs -t app
```

### Health Checks

The production container includes health checks:

- **Endpoint**: `GET /health`
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Retries**: 3 attempts
- **Start Period**: 40 seconds

## Troubleshooting

### Common Issues

#### Development Environment

**Issue**: Neon Local fails to connect
```bash
# Check Neon Local container logs
docker-compose -f docker-compose.dev.yml logs neon-local

# Verify environment variables
docker-compose -f docker-compose.dev.yml config
```

**Issue**: Application fails to start
```bash
# Check application logs
docker-compose -f docker-compose.dev.yml logs app

# Verify database connectivity
docker-compose -f docker-compose.dev.yml exec app node -e "console.log(process.env.DATABASE_URL)"
```

#### Production Environment

**Issue**: Database connection fails
```bash
# Test database connectivity
docker-compose -f docker-compose.prod.yml exec app node -e "
const { neon } = require('@neondatabase/serverless');
const sql = neon(process.env.DATABASE_URL);
sql\`SELECT 1\`.then(() => console.log('DB OK')).catch(console.error);
"
```

**Issue**: Container health check fails
```bash
# Check health status
docker inspect acquisitions-prod --format='{{json .State.Health}}'

# Test health endpoint manually
docker-compose -f docker-compose.prod.yml exec app curl -f http://localhost:3000/health
```

### Debug Mode

Enable debug mode in development:

```bash
# Run with debug output
DEBUG=* docker-compose -f docker-compose.dev.yml up

# Run specific service with debugging
docker-compose -f docker-compose.dev.yml run --rm app node --inspect=0.0.0.0:9229 src/index.js
```

## Best Practices

### Development

- Use `.env.dev.local` for local overrides (gitignored)
- Regularly clean up Docker volumes: `docker volume prune`
- Monitor ephemeral branch creation in Neon console

### Production

- Use secrets management (Kubernetes secrets, Docker secrets)
- Implement log aggregation (ELK stack, Fluentd)
- Set up monitoring (Prometheus, Grafana)
- Use container orchestration (Docker Swarm, Kubernetes)

### CI/CD Integration

```yaml
# Example GitHub Actions workflow
- name: Build and test
  run: |
    docker build --target development -t app:test .
    docker run --rm app:test npm test

- name: Build production
  run: |
    docker build --target production -t app:prod .
    docker tag app:prod registry.com/app:${{ github.sha }}
```

## Additional Commands

### Container Management

```bash
# Remove all containers and volumes
docker-compose -f docker-compose.dev.yml down -v

# Rebuild containers from scratch
docker-compose -f docker-compose.dev.yml build --no-cache

# Scale services (production)
docker-compose -f docker-compose.prod.yml up -d --scale app=3
```

### Database Operations

```bash
# Generate new migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# Reset development database
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml up -d
```

This Docker setup provides a robust foundation for both development and production deployments with proper separation of concerns and security best practices.