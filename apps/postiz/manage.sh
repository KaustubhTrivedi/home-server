#!/bin/bash

# Postiz Management Script

case "$1" in
    start)
        echo "Starting Postiz..."
        docker compose up -d
        echo "Postiz is now running on http://localhost:3003"
        ;;
    stop)
        echo "Stopping Postiz..."
        docker compose down
        echo "Postiz stopped"
        ;;
    restart)
        echo "Restarting Postiz..."
        docker compose down
        docker compose up -d
        echo "Postiz restarted"
        ;;
    logs)
        docker compose logs -f
        ;;
    status)
        docker compose ps
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status}"
        echo ""
        echo "Commands:"
        echo "  start   - Start Postiz service"
        echo "  stop    - Stop Postiz service"
        echo "  restart - Restart Postiz service"
        echo "  logs    - Show Postiz logs"
        echo "  status  - Show service status"
        exit 1
        ;;
esac 