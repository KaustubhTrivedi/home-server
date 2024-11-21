#!/bin/bash

# Host and port of PostgreSQL
HOST="${NOMINATIM_POSTGRES_HOST:-postgres}"
PORT=5432

echo "Waiting for PostgreSQL to be ready at ${HOST}:${PORT}..."

# Wait for PostgreSQL to become available
until pg_isready -h "$HOST" -p "$PORT" -U "$NOMINATIM_POSTGRES_USER"; do
  echo "PostgreSQL is unavailable - waiting..."
  sleep 2
done

echo "PostgreSQL is ready!"
