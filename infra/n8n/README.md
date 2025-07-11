# n8n Self-Hosting Setup

This directory contains the configuration files needed to self-host n8n using Docker Compose with nginx proxy manager for SSL and reverse proxy.

## Prerequisites

- Docker and Docker Compose installed
- nginx proxy manager running and configured for your domain
- Domain/subdomain pointing to your server

## Quick Start

1. **Copy the environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file** with your domain settings:
   - Set `DOMAIN_NAME` to your domain (e.g., `example.com`)
   - Set `SUBDOMAIN` to your desired subdomain (e.g., `n8n`)
   - Set `GENERIC_TIMEZONE` to your timezone
   - Configure other settings as needed

3. **Create the local files directory:**
   ```bash
   mkdir -p local-files
   ```

4. **Start n8n:**
   ```bash
   docker compose up -d
   ```

5. **Configure nginx proxy manager:**
   - Add a new proxy host in nginx proxy manager
   - Domain Names: `n8n.yourdomain.com` (or your subdomain)
   - Forward Hostname/IP: `your-server-ip`
   - Forward Port: `5678`
   - Enable SSL certificate
   - Enable "Force SSL" and "HTTP/2 Support"

6. **Access n8n:**
   - Your n8n instance will be available at `https://n8n.yourdomain.com`

## File Structure

- `docker-compose.yml` - Main configuration with SQLite database
- `.env.example` - Environment variables template
- `local-files/` - Directory for file operations within n8n workflows
- `README.md` - This file

## Configuration Options

### Database

This setup uses **SQLite** (n8n's default database):
- Simpler setup, good for small to medium workloads
- Data stored in Docker volume
- No additional database container needed

### Environment Variables

Key settings in your `.env` file:

- `DOMAIN_NAME` & `SUBDOMAIN` - Your n8n URL will be `https://SUBDOMAIN.DOMAIN_NAME`
- `GENERIC_TIMEZONE` - Timezone for scheduled workflows

Optional advanced settings:
- `N8N_ENCRYPTION_KEY` - Custom encryption key for credentials
- `N8N_LOG_LEVEL` - Logging verbosity
- `EXECUTIONS_TIMEOUT` - Maximum workflow execution time
- `N8N_PAYLOAD_SIZE_MAX` - Maximum request payload size

## SSL & Security

- **SSL handled by nginx proxy manager** - Configure SSL certificates in your nginx proxy manager
- **Port exposure** - n8n only exposes port 5678 to localhost for security
- **Reverse proxy** - nginx proxy manager handles external access and SSL termination

## File Operations

The `local-files/` directory is mounted to `/files` inside the n8n container. Use this for:
- Reading/writing files with the "Read/Write Files from Disk" node
- Storing temporary files for workflows
- File processing operations

## Management Commands

**View logs:**
```bash
docker compose logs -f n8n
```

**Stop services:**
```bash
docker compose down
```

**Update n8n:**
```bash
docker compose pull
docker compose up -d
```

**Backup (SQLite):**
```bash
docker compose cp n8n:/home/node/.n8n ./n8n-backup
```

## nginx proxy manager Configuration

Configure your nginx proxy manager with these settings:

1. **Add Proxy Host:**
   - Domain Names: `n8n.yourdomain.com`
   - Forward Hostname/IP: `your-server-ip` or `localhost` (if NPM is on same server)
   - Forward Port: `5678`

2. **SSL Tab:**
   - Request a new SSL certificate or use existing one
   - Enable "Force SSL"
   - Enable "HTTP/2 Support"

3. **Advanced Tab (optional):**
   ```nginx
   # Add security headers
   proxy_set_header X-Forwarded-Proto $scheme;
   proxy_set_header X-Forwarded-Host $host;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   ```

## DNS Configuration

Before starting, make sure to create an A record for your subdomain:

- **Type:** A
- **Name:** n8n (or your chosen subdomain)
- **Value:** Your server's IP address
- **TTL:** 3600 (or your preference)

## Troubleshooting

**Cannot access n8n:**
- Check if n8n service is running: `docker compose ps`
- View n8n logs: `docker compose logs n8n`
- Ensure DNS points to your server
- Verify nginx proxy manager configuration
- Check that port 5678 is accessible from nginx proxy manager

**SSL certificate issues:**
- Configure SSL in nginx proxy manager, not in n8n
- Ensure your domain points to your server
- Check nginx proxy manager logs

**Performance issues:**
- Monitor disk space for Docker volumes
- Consider increasing container memory limits if needed
- Check n8n logs for any errors

## Security Best Practices

1. **Use strong passwords** for any authentication
2. **Keep n8n updated** regularly with `docker compose pull`
3. **Backup your data** regularly
4. **Monitor logs** for suspicious activity
5. **Configure nginx proxy manager security headers**
6. **Consider VPN access** for additional security
7. **Only expose n8n through nginx proxy manager** (port 5678 bound to localhost only)

## Updating

To update n8n:

```bash
docker compose pull
docker compose down
docker compose up -d
```

For major version updates, check the [n8n release notes](https://github.com/n8n-io/n8n/releases) for any breaking changes.

## Support

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [n8n GitHub Issues](https://github.com/n8n-io/n8n/issues)
