#!/bin/bash

# Home Server Management Script
# Manages all services: nginx proxy manager, n8n, sterling-pdf, postiz

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Home Server Management Script${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Function to start all services
start_all() {
    print_header
    print_status "Starting all home server services..."
    
    check_docker
    
    # Start nginx proxy manager first (infrastructure)
    print_status "Starting nginx proxy manager..."
    cd infra/npm
    docker compose up -d
    cd ../..
    
    # Start n8n
    print_status "Starting n8n..."
    cd infra/n8n
    if [ -f "docker-compose-postgres.yml" ] && [ -f ".env" ] && grep -q "DB_TYPE=postgresdb" .env 2>/dev/null; then
        docker compose -f docker-compose-postgres.yml up -d
    else
        docker compose up -d
    fi
    cd ../..
    
    # Start sterling-pdf
    print_status "Starting Sterling PDF..."
    cd apps/sterling-pdf
    docker compose up -d
    cd ../..
    
    # Start postiz
    print_status "Starting Postiz..."
    cd apps/postiz
    docker compose up -d
    cd ../..
    
    print_status "All services started successfully!"
    print_status "Services will be available at:"
    print_status "  - nginx proxy manager: http://localhost:81"
    print_status "  - n8n: https://n8n.kaustubhsstuff.com"
    print_status "  - Sterling PDF: http://localhost:3002"
    print_status "  - Postiz: https://postiz.kaustubhsstuff.com"
}

# Function to stop all services
stop_all() {
    print_header
    print_status "Stopping all home server services..."
    
    check_docker
    
    # Stop postiz
    print_status "Stopping Postiz..."
    cd apps/postiz
    docker compose down
    cd ../..
    
    # Stop sterling-pdf
    print_status "Stopping Sterling PDF..."
    cd apps/sterling-pdf
    docker compose down
    cd ../..
    
    # Stop n8n
    print_status "Stopping n8n..."
    cd infra/n8n
    if [ -f "docker-compose-postgres.yml" ] && [ -f ".env" ] && grep -q "DB_TYPE=postgresdb" .env 2>/dev/null; then
        docker compose -f docker-compose-postgres.yml down
    else
        docker compose down
    fi
    cd ../..
    
    # Stop nginx proxy manager last
    print_status "Stopping nginx proxy manager..."
    cd infra/npm
    docker compose down
    cd ../..
    
    print_status "All services stopped successfully!"
}

# Function to restart all services
restart_all() {
    print_header
    print_status "Restarting all home server services..."
    stop_all
    sleep 2
    start_all
}

# Function to show status of all services
status_all() {
    print_header
    print_status "Checking status of all services..."
    
    check_docker
    
    echo ""
    print_status "nginx proxy manager status:"
    cd infra/npm
    docker compose ps
    cd ../..
    
    echo ""
    print_status "n8n status:"
    cd infra/n8n
    if [ -f "docker-compose-postgres.yml" ] && [ -f ".env" ] && grep -q "DB_TYPE=postgresdb" .env 2>/dev/null; then
        docker compose -f docker-compose-postgres.yml ps
    else
        docker compose ps
    fi
    cd ../..
    
    echo ""
    print_status "Sterling PDF status:"
    cd apps/sterling-pdf
    docker compose ps
    cd ../..
    
    echo ""
    print_status "Postiz status:"
    cd apps/postiz
    docker compose ps
    cd ../..
}

# Function to show logs
logs() {
    local service=$1
    
    if [ -z "$service" ]; then
        print_error "Please specify a service: nginx, n8n, sterling, postiz, or all"
        exit 1
    fi
    
    case $service in
        "nginx")
            cd infra/npm
            docker compose logs -f
            ;;
        "n8n")
            cd infra/n8n
            if [ -f "docker-compose-postgres.yml" ] && [ -f ".env" ] && grep -q "DB_TYPE=postgresdb" .env 2>/dev/null; then
                docker compose -f docker-compose-postgres.yml logs -f
            else
                docker compose logs -f
            fi
            ;;
        "sterling")
            cd apps/sterling-pdf
            docker compose logs -f
            ;;
        "postiz")
            cd apps/postiz
            docker compose logs -f
            ;;
        "all")
            print_status "Showing logs for all services (use Ctrl+C to exit)..."
            # This is a simplified version - in practice you might want to use tmux or similar
            print_warning "Showing nginx logs first. Use Ctrl+C then run again for other services."
            cd infra/npm
            docker compose logs -f
            ;;
        *)
            print_error "Unknown service: $service"
            print_status "Available services: nginx, n8n, sterling, postiz, all"
            exit 1
            ;;
    esac
}

# Function to update all services
update_all() {
    print_header
    print_status "Updating all home server services..."
    
    check_docker
    
    # Update nginx proxy manager
    print_status "Updating nginx proxy manager..."
    cd infra/npm
    docker compose pull
    docker compose up -d
    cd ../..
    
    # Update n8n
    print_status "Updating n8n..."
    cd infra/n8n
    if [ -f "docker-compose-postgres.yml" ] && [ -f ".env" ] && grep -q "DB_TYPE=postgresdb" .env 2>/dev/null; then
        docker compose -f docker-compose-postgres.yml pull
        docker compose -f docker-compose-postgres.yml up -d
    else
        docker compose pull
        docker compose up -d
    fi
    cd ../..
    
    # Update sterling-pdf
    print_status "Updating Sterling PDF..."
    cd apps/sterling-pdf
    docker compose pull
    docker compose up -d
    cd ../..
    
    # Update postiz
    print_status "Updating Postiz..."
    cd apps/postiz
    docker compose pull
    docker compose up -d
    cd ../..
    
    print_status "All services updated successfully!"
}

# Function to backup all data
backup_all() {
    print_header
    print_status "Creating backup of all services..."
    
    local backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    print_status "Backup directory: $backup_dir"
    
    # Backup nginx proxy manager
    print_status "Backing up nginx proxy manager..."
    cd infra/npm
    docker compose exec -T npm tar czf - /data > "../../$backup_dir/npm-data.tar.gz" 2>/dev/null || print_warning "Could not backup nginx proxy manager data"
    cd ../..
    
    # Backup n8n
    print_status "Backing up n8n..."
    cd infra/n8n
    if [ -f "docker-compose-postgres.yml" ] && [ -f ".env" ] && grep -q "DB_TYPE=postgresdb" .env 2>/dev/null; then
        docker compose -f docker-compose-postgres.yml exec -T postgres pg_dump -U n8n n8n > "../$backup_dir/n8n-database.sql" 2>/dev/null || print_warning "Could not backup n8n database"
    else
        docker compose cp n8n:/home/node/.n8n "../$backup_dir/n8n-data" 2>/dev/null || print_warning "Could not backup n8n data"
    fi
    # Backup local files
    if [ -d "local-files" ]; then
        cp -r local-files "../$backup_dir/n8n-local-files" 2>/dev/null || print_warning "Could not backup n8n local files"
    fi
    cd ../..
    
    # Backup sterling-pdf
    print_status "Backing up Sterling PDF..."
    cd apps/sterling-pdf
    docker compose cp stirling-pdf:/usr/share/tessdata "../../$backup_dir/sterling-tessdata" 2>/dev/null || print_warning "Could not backup Sterling PDF data"
    cd ../..
    
    # Backup postiz
    print_status "Backing up Postiz..."
    cd apps/postiz
    docker compose exec -T postiz-postgres pg_dump -U postiz-user postiz-db-local > "../$backup_dir/postiz-database.sql" 2>/dev/null || print_warning "Could not backup Postiz database"
    cd ../..
    
    # Backup configuration files
    print_status "Backing up configuration files..."
    cp -r infra/npm/docker-compose.yml "$backup_dir/" 2>/dev/null || print_warning "Could not backup nginx config"
    cp -r infra/n8n/docker-compose*.yml "$backup_dir/" 2>/dev/null || print_warning "Could not backup n8n config"
    cp -r apps/sterling-pdf/docker-compose.yml "$backup_dir/" 2>/dev/null || print_warning "Could not backup sterling config"
    cp -r apps/postiz/docker-compose.yml "$backup_dir/" 2>/dev/null || print_warning "Could not backup postiz config"
    
    print_status "Backup completed successfully!"
    print_status "Backup location: $backup_dir"
}

# Function to show help
show_help() {
    print_header
    echo "Usage: $0 <command> [service]"
    echo ""
    echo "Commands:"
    echo "  start     - Start all services"
    echo "  stop      - Stop all services"
    echo "  restart   - Restart all services"
    echo "  status    - Show status of all services"
    echo "  logs      - Show logs (specify service: nginx, n8n, sterling, postiz, all)"
    echo "  update    - Update all services to latest versions"
    echo "  backup    - Create backup of all data"
    echo "  help      - Show this help message"
    echo ""
    echo "Services:"
    echo "  nginx     - nginx proxy manager"
    echo "  n8n       - n8n automation platform"
    echo "  sterling  - Sterling PDF"
    echo "  postiz    - Postiz newsletter platform"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start all services"
    echo "  $0 logs n8n                 # Show n8n logs"
    echo "  $0 status                   # Show status of all services"
    echo "  $0 backup                   # Create backup"
}

# Main script logic
case "$1" in
    "start")
        start_all
        ;;
    "stop")
        stop_all
        ;;
    "restart")
        restart_all
        ;;
    "status")
        status_all
        ;;
    "logs")
        logs "$2"
        ;;
    "update")
        update_all
        ;;
    "backup")
        backup_all
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac 