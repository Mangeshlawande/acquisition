# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Node.js acquisition system API built as a learning/demo project for modern backend development with deployment focus (Docker/K8s). It implements a RESTful API with Express.js and PostgreSQL, following clean layered architecture patterns with JWT-based authentication.

## Architecture

### High-Level Structure

The application follows a **layered monolithic architecture** with clean separation of concerns:

```
HTTP Layer (Express + Middleware)
    ↓
Controller Layer (Request/Response Logic)
    ↓
Service Layer (Business Logic)
    ↓
Data Layer (Drizzle ORM + PostgreSQL)
```

### Directory Structure

```
src/
├── index.js          # Entry point (loads env, imports server)
├── server.js         # Server bootstrap (port binding)
├── app.js            # Express app config & middleware setup
├── config/           # Database connection & Winston logger
├── models/           # Drizzle ORM schema definitions
├── controllers/      # HTTP request handlers
├── services/         # Business logic (user creation, password hashing)
├── routes/           # Express route definitions
├── validations/      # Zod schema validation
├── utils/            # JWT tokens, cookies, error formatting
└── middleware/       # Express middleware (empty - reserved for auth middleware)
```

### Technology Stack

- **Backend**: Express.js v5.1.0 with ES modules
- **Database**: PostgreSQL via Neon serverless + Drizzle ORM
- **Authentication**: JWT with bcrypt password hashing
- **Validation**: Zod schemas for type-safe input validation
- **Security**: Helmet.js, CORS, HTTP-only secure cookies
- **Logging**: Winston with file/console transports
- **Development**: ESLint, Prettier, hot reloading

### Path Mapping System

Uses Node.js subpath imports for clean module resolution:

- `#config/*` → `./src/config/*`
- `#models/*` → `./src/models/*`
- `#controllers/*` → `./src/controllers/*`
- `#services/*` → `./src/services/*`
- `#routes/*` → `./src/routes/*`
- `#utils/*` → `./src/utils/*`
- `#validations/*` → `./src/validations/*`
- `#middleware/*` → `./src/middleware/*`

## Common Development Commands

### Development Server

```bash
npm run dev              # Start development server with --watch flag
```

### Code Quality & Linting

```bash
npm run lint             # Run ESLint
npm run lint:fix         # Run ESLint with auto-fix
npm run format           # Format code with Prettier
npm run format:check     # Check formatting without changes
```

### Database Operations

```bash
npm run db:generate      # Generate Drizzle migrations from schema changes
npm run db:migrate       # Apply pending migrations to database
npm run db:studio        # Open Drizzle Studio (visual database browser)
```

### Environment Setup

Create `.env` file with:

```
DATABASE_URL=your_neon_postgresql_connection_string
JWT_SECRET=your_jwt_secret_key
NODE_ENV=development
PORT=3000
```

## Current Implementation Status

### ✅ Implemented Features

- **User Registration**: Complete signup flow with validation
- **Password Security**: bcrypt hashing with salt rounds of 10
- **JWT Authentication**: Token generation and cookie storage
- **Input Validation**: Zod schemas with error formatting
- **Database Schema**: Users table with roles and timestamps
- **Logging**: Winston logger with file/console outputs
- **Security Middleware**: Helmet, CORS, cookie parsing

### 🚧 Incomplete Features

- **User Login**: Route exists but returns placeholder response
- **User Logout**: Route exists but returns placeholder response
- **JWT Middleware**: No authentication middleware for protected routes
- **Password Reset**: Not implemented
- **Email Verification**: Not implemented

## Request Flow Example

### User Registration Flow

```
POST /api/auth/sign-up
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepass123",
  "role": "user"
}

Flow:
1. Express middleware (helmet, cors, json parsing)
2. Route handler (/api/auth → auth.routes.js)
3. Controller (auth.controller.js)
   - Zod validation (signupSchema)
   - Error formatting if validation fails
4. Service layer (auth.service.js)
   - Check if user exists (SELECT query)
   - Hash password (bcrypt)
   - Insert user (INSERT with returning)
5. Response generation
   - Generate JWT token
   - Set HTTP-only cookie
   - Log success/failure
   - Return JSON response
```

## Database Schema

### Users Table

```sql
CREATE TABLE "users" (
  "id" serial PRIMARY KEY,
  "name" varchar(255) NOT NULL UNIQUE,
  "email" varchar(255) NOT NULL UNIQUE,
  "password" varchar(255) NOT NULL,
  "role" varchar(50) DEFAULT 'user',
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);
```

### Database Workflow

1. Modify schema in `src/models/*.js` using Drizzle schema builder
2. Run `npm run db:generate` to create migration files
3. Run `npm run db:migrate` to apply changes
4. Migration files stored in `./drizzle/` directory

## API Endpoints

### Health & Info

- `GET /health` - Server health check (status, timestamp, uptime)
- `GET /` - Welcome message
- `GET /api` - API status message

### Authentication

- `POST /api/auth/sign-up` - User registration (✅ implemented)
- `POST /api/auth/sign-in` - User login (🚧 placeholder)
- `POST /api/auth/sign-out` - User logout (🚧 placeholder)

## Security Implementation

### JWT Token Management

- **Generation**: `utils/jwt.js` with configurable secret/expiration
- **Storage**: HTTP-only cookies with secure flags
- **Cookie Options**:
  - `httpOnly: true` (prevents XSS)
  - `secure: true` (HTTPS only in production)
  - `sameSite: 'strict'` (CSRF protection)
  - `maxAge: 15 minutes`

### Password Security

- **Hashing**: bcrypt with salt rounds of 10
- **Validation**: Minimum 6 characters via Zod schema

## Known Issues & TODOs

### Current Bugs

- **auth.controller.js:13** - Typo: `res.ststus(400)` should be `res.status(400)`
- **auth.service.js:42** - Missing `return newUser;` statement
- **jwt.js:12** - Should use `expiresIn` instead of `expiration` for JWT options
- **logger.js:4,6,7** - Syntax errors in winston format configuration

### Development Improvements Needed

- Add JWT verification middleware for protected routes
- Implement actual sign-in/sign-out functionality
- Add comprehensive test suite
- Add API documentation (Swagger/OpenAPI)
- Implement proper error handling middleware
- Add rate limiting for authentication endpoints

## Development Notes

### Debugging Tips

- Check `logs/combined.log` and `logs/error.log` for application logs
- Use `npm run db:studio` to visually inspect database
- Winston logger outputs to console in development mode
- Database queries are logged via Drizzle ORM

### Testing Database Changes

1. Make schema changes in `src/models/`
2. Generate migration: `npm run db:generate`
3. Review generated SQL in `./drizzle/`
4. Apply migration: `npm run db:migrate`
5. Verify changes: `npm run db:studio`

This codebase demonstrates modern Node.js patterns and is structured for easy extension with additional features like user management, permissions, and business logic.
