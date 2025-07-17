# Postiz

Postiz is a modern newsletter platform that helps you create, send, and track beautiful newsletters.

## Setup

1. **Configure Environment Variables**
   
   Edit the `docker-compose.yml` file and update the following environment variables:
   
   - `MAIN_URL`: Replace `postiz.your-server.com` with your actual domain
   - `FRONTEND_URL`: Replace `postiz.your-server.com` with your actual domain  
   - `NEXT_PUBLIC_BACKEND_URL`: Replace `postiz.your-server.com` with your actual domain
   - `JWT_SECRET`: Generate a secure random string for JWT authentication
   - Database credentials (optional - defaults are fine for most users):
     - `POSTGRES_PASSWORD`: PostgreSQL password
     - `POSTGRES_USER`: PostgreSQL username
     - `POSTGRES_DB`: PostgreSQL database name

2. **Start the Service**
   ```bash
   docker compose up -d
   ```

3. **Access Postiz**
   
   Once running, Postiz will be available at `http://localhost:3003`

## Services

This setup includes:
- **Postiz App**: Main application (port 3003)
- **PostgreSQL**: Database for storing newsletters and subscribers
- **Redis**: Caching and session management

## Features

- Create and send beautiful newsletters
- Track email opens and clicks
- Manage subscriber lists
- Custom templates
- Analytics and reporting

## Data Persistence

All data is stored in Docker volumes:
- `postgres-volume`: PostgreSQL database data
- `postiz-redis-data`: Redis cache data
- `postiz-config`: Application configuration
- `postiz-uploads`: Uploaded files and assets

## Port Configuration

Postiz runs on port 3003 by default. The internal services (PostgreSQL on 5432, Redis on 6379) are not exposed externally for security.

## Documentation

For more information, visit: https://docs.postiz.com/ 