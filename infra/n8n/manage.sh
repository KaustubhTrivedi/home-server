#!/bin/bash

# n8n Management Script
# Provides common management operations for n8n

set -e

COMPOSE_FILE="docker-compose.yml"

# Check if PostgreSQL compose file should be used
if [ -f ".env" ] && grep -q "DB_TYPE=postgresdb" .env 2>/dev/null; then
    COMPOSE_FILE="docker-compose-postgres.yml"
fi

# Check if custom compose file is specified
if [ "$1" = "--postgres" ]; then
    COMPOSE_FILE="docker-compose-postgres.yml"
    shift
fi

case "$1" in
    "start")
        echo "🚀 Starting n8n services..."
        docker compose -f $COMPOSE_FILE up -d
        echo "✅ Services started!"
        ;;
    "stop")
        echo "🛑 Stopping n8n services..."
        docker compose -f $COMPOSE_FILE down
        echo "✅ Services stopped!"
        ;;
    "restart")
        echo "🔄 Restarting n8n services..."
        docker compose -f $COMPOSE_FILE down
        docker compose -f $COMPOSE_FILE up -d
        echo "✅ Services restarted!"
        ;;
    "status")
        echo "📊 Service status:"
        docker compose -f $COMPOSE_FILE ps
        ;;
    "logs")
        echo "📜 Viewing logs (press Ctrl+C to exit):"
        docker compose -f $COMPOSE_FILE logs -f "${2:-n8n}"
        ;;
    "update")
        echo "🔄 Updating n8n..."
        docker compose -f $COMPOSE_FILE pull
        docker compose -f $COMPOSE_FILE down
        docker compose -f $COMPOSE_FILE up -d
        echo "✅ Update complete!"
        ;;
    "backup")
        echo "💾 Creating backup..."
        BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        
        if [[ $COMPOSE_FILE == *"postgres"* ]]; then
            # PostgreSQL backup
            docker compose -f $COMPOSE_FILE exec -T postgres pg_dump -U n8n n8n > "$BACKUP_DIR/database.sql"
            echo "✅ PostgreSQL database backed up to $BACKUP_DIR/database.sql"
        else
            # SQLite backup
            docker compose -f $COMPOSE_FILE cp n8n:/home/node/.n8n "$BACKUP_DIR/n8n-data"
            echo "✅ SQLite data backed up to $BACKUP_DIR/n8n-data"
        fi
        
        # Backup local files
        if [ -d "local-files" ]; then
            cp -r local-files "$BACKUP_DIR/"
            echo "✅ Local files backed up to $BACKUP_DIR/local-files"
        fi
        
        # Backup configuration
        cp .env "$BACKUP_DIR/.env.backup" 2>/dev/null || true
        cp docker-compose*.yml "$BACKUP_DIR/" 2>/dev/null || true
        
        echo "🎉 Backup completed in $BACKUP_DIR"
        ;;
    "shell")
        echo "🐚 Opening shell in n8n container..."
        docker compose -f $COMPOSE_FILE exec n8n /bin/sh
        ;;
    "reset")
        echo "⚠️  This will remove all data and containers!"
        read -p "Are you sure? Type 'yes' to continue: " confirm
        if [ "$confirm" = "yes" ]; then
            docker compose -f $COMPOSE_FILE down -v
            docker volume prune -f
            echo "✅ Reset complete!"
        else
            echo "❌ Reset cancelled"
        fi
        ;;
    "help"|*)
        echo "n8n Management Script"
        echo "===================="
        echo ""
        echo "Usage: $0 [--postgres] <command>"
        echo ""
        echo "Commands:"
        echo "  start     Start n8n services"
        echo "  stop      Stop n8n services"
        echo "  restart   Restart n8n services"
        echo "  status    Show service status"
        echo "  logs      Show logs (optionally specify service name)"
        echo "  update    Update and restart n8n"
        echo "  backup    Create a backup of data and configuration"
        echo "  shell     Open shell in n8n container"
        echo "  reset     Remove all data and containers (DESTRUCTIVE!)"
        echo "  help      Show this help message"
        echo ""
        echo "Options:"
        echo "  --postgres    Use PostgreSQL compose file"
        echo ""
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 logs"
        echo "  $0 logs traefik"
        echo "  $0 --postgres backup"
        ;;
esac
