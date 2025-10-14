# #!/bin/bash

# # Docker Development Helper Script
# # This script helps manage the development environment

# set -e

# PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ENV_FILE="$PROJECT_ROOT/.env.dev.local"
# COMPOSE_FILE="$PROJECT_ROOT/docker-compose.dev.yml"

# # Colors for output
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[1;33m'
# NC='\033[0m' # No Color

# print_usage() {
#     echo "Usage: $0 {start|stop|restart|logs|shell|migrate|studio|clean|status}"
#     echo ""
#     echo "Commands:"
#     echo "  start     - Start development environment"
#     echo "  stop      - Stop development environment"
#     echo "  restart   - Restart development environment"
#     echo "  logs      - Show application logs"
#     echo "  shell     - Open shell in application container"
#     echo "  migrate   - Run database migrations"
#     echo "  studio    - Open Drizzle Studio"
#     echo "  clean     - Clean up containers and volumes"
#     echo "  status    - Show container status"
# }

# check_env_file() {
#     if [ ! -f "$ENV_FILE" ]; then
#         echo -e "${YELLOW}Warning: $ENV_FILE not found${NC}"
#         echo "Creating from template..."
#         cp "$PROJECT_ROOT/.env.development" "$ENV_FILE"
#         echo -e "${RED}Please edit $ENV_FILE with your Neon credentials before running 'start'${NC}"
#         exit 1
#     fi
# }

# case "$1" in
#     start)
#         echo -e "${GREEN}Starting development environment...${NC}"
#         check_env_file
#         docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
#         echo -e "${GREEN}Development environment started!${NC}"
#         echo "Application: http://localhost:3000"
#         echo "Database (Neon Local): localhost:5432"
#         echo -e "View logs: ${YELLOW}$0 logs${NC}"
#         ;;
        
#     stop)
#         echo -e "${YELLOW}Stopping development environment...${NC}"
#         docker-compose -f "$COMPOSE_FILE" down
#         echo -e "${GREEN}Development environment stopped!${NC}"
#         ;;
        
#     restart)
#         echo -e "${YELLOW}Restarting development environment...${NC}"
#         docker-compose -f "$COMPOSE_FILE" down
#         $0 start
#         ;;
        
#     logs)
#         docker-compose -f "$COMPOSE_FILE" logs -f app
#         ;;
        
#     shell)
#         echo -e "${GREEN}Opening shell in application container...${NC}"
#         docker-compose -f "$COMPOSE_FILE" exec app /bin/sh
#         ;;
        
#     migrate)
#         echo -e "${GREEN}Running database migrations...${NC}"
#         docker-compose -f "$COMPOSE_FILE" exec app npm run db:migrate
#         ;;
        
#     studio)
#         echo -e "${GREEN}Opening Drizzle Studio...${NC}"
#         echo "Drizzle Studio will be available at: http://localhost:4983"
#         docker-compose -f "$COMPOSE_FILE" exec app npm run db:studio
#         ;;
        
#     clean)
#         echo -e "${YELLOW}Cleaning up development environment...${NC}"
#         docker-compose -f "$COMPOSE_FILE" down -v --remove-orphans
#         docker image prune -f
#         docker volume prune -f
#         echo -e "${GREEN}Cleanup completed!${NC}"
#         ;;
        
#     status)
#         echo -e "${GREEN}Development environment status:${NC}"
#         docker-compose -f "$COMPOSE_FILE" ps
#         echo ""
#         echo -e "${GREEN}Container logs (last 10 lines):${NC}"
#         docker-compose -f "$COMPOSE_FILE" logs --tail=10
#         ;;
        
#     *)
#         print_usage
#         exit 1
#         ;;
# esac

#!/bin/bash

# Development startup script for Acquisition App with Neon Local
# This script starts the application in development mode with Neon Local

echo "🚀 Starting Acquisition App in Development Mode"
echo "================================================"

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "❌ Error: .env.development file not found!"
    echo "   Please copy .env.development from the template and update with your Neon credentials."
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker Desktop and try again."
    exit 1
fi

# Create .neon_local directory if it doesn't exist
mkdir -p .neon_local

# Add .neon_local to .gitignore if not already present
if ! grep -q ".neon_local/" .gitignore 2>/dev/null; then
    echo ".neon_local/" >> .gitignore
    echo "✅ Added .neon_local/ to .gitignore"
fi

echo "📦 Building and starting development containers..."
echo "   - Neon Local proxy will create an ephemeral database branch"
echo "   - Application will run with hot reload enabled"
echo ""

# Run migrations with Drizzle
echo "📜 Applying latest schema with Drizzle..."
npm run db:migrate

# Wait for the database to be ready
echo "⏳ Waiting for the database to be ready..."
docker compose exec neon-local psql -U neon -d neondb -c 'SELECT 1'

# Start development environment
docker compose -f docker-compose.dev.yml up --build

echo ""
echo "🎉 Development environment started!"
echo "   Application: http://localhost:5173"
echo "   Database: postgres://neon:npg@localhost:5432/neondb"
echo ""
echo "To stop the environment, press Ctrl+C or run: docker compose down"