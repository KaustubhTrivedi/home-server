#!/bin/bash

# n8n Setup Script
# This script helps you set up n8n for self-hosting

set -e

echo "🚀 n8n Self-Hosting Setup Script"
echo "================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker &> /dev/null || ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo ""
    echo "📝 Setting up environment configuration..."
    cp .env.example .env
    echo "✅ Created .env file from template"
    echo ""
    echo "⚠️  IMPORTANT: Please edit the .env file with your configuration:"
    echo "   - Set DOMAIN_NAME to your domain"
    echo "   - Set SUBDOMAIN to your desired subdomain" 
    echo "   - Set SSL_EMAIL to your email address"
    echo "   - Set POSTGRES_PASSWORD if using PostgreSQL"
    echo ""
    read -p "Press Enter to continue after editing .env file..."
else
    echo "✅ .env file already exists"
fi

# Create local-files directory
if [ ! -d "local-files" ]; then
    mkdir -p local-files
    echo "✅ Created local-files directory"
else
    echo "✅ local-files directory already exists"
fi

# Ask user which database to use
echo ""
echo "📊 Database Selection:"
echo "1) SQLite (easier setup, good for small-medium workloads)"
echo "2) PostgreSQL (recommended for production)"
echo ""
read -p "Choose database (1 or 2): " db_choice

case $db_choice in
    1)
        COMPOSE_FILE="docker-compose.yml"
        echo "✅ Selected SQLite database"
        ;;
    2)
        COMPOSE_FILE="docker-compose-postgres.yml"
        echo "✅ Selected PostgreSQL database"
        
        # Check if POSTGRES_PASSWORD is set
        if ! grep -q "^POSTGRES_PASSWORD=" .env || grep -q "^POSTGRES_PASSWORD=$" .env; then
            echo ""
            echo "⚠️  PostgreSQL requires a password. Please set POSTGRES_PASSWORD in your .env file."
            read -p "Enter PostgreSQL password: " -s postgres_password
            echo ""
            echo "POSTGRES_PASSWORD=$postgres_password" >> .env
            echo "✅ PostgreSQL password added to .env"
        fi
        ;;
    *)
        echo "❌ Invalid choice. Defaulting to SQLite."
        COMPOSE_FILE="docker-compose.yml"
        ;;
esac

# Ask if user wants to start services
echo ""
read -p "🚀 Start n8n services now? (y/N): " start_services

if [[ $start_services =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔄 Starting n8n services..."
    docker compose -f $COMPOSE_FILE up -d
    
    echo ""
    echo "✅ n8n services started!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Wait for services to fully start (about 1-2 minutes)"
    echo "2. Ensure your DNS A record points to this server"
    echo "3. Access n8n at: https://$(grep SUBDOMAIN .env | cut -d'=' -f2).$(grep DOMAIN_NAME .env | cut -d'=' -f2)"
    echo ""
    echo "📊 Check service status:"
    echo "   docker compose -f $COMPOSE_FILE ps"
    echo ""
    echo "📜 View logs:"
    echo "   docker compose -f $COMPOSE_FILE logs -f"
else
    echo ""
    echo "✅ Setup complete! To start services later, run:"
    echo "   docker compose -f $COMPOSE_FILE up -d"
fi

echo ""
echo "📚 For more information, see README.md"
echo "🎉 Setup complete!"
