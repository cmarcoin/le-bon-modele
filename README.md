# Herve 2

A Rails 8.1 application with PostgreSQL, Tailwind CSS, and importmap, running entirely in Docker containers.

## Prerequisites

- Docker
- Docker Compose

## Development Setup

### 1. Build and start the containers

```bash
docker-compose build
docker-compose up
```

### 2. Initialize the database

In a new terminal, run:

```bash
docker-compose run web rails db:create
docker-compose run web rails db:migrate
```

### 3. Access the application

Open your browser and navigate to:
- http://localhost:3000

## Common Commands

### Run Rails console
```bash
docker-compose run web rails console
```

### Run database migrations
```bash
docker-compose run web rails db:migrate
```

### Run tests
```bash
docker-compose run web rails test
```

### Generate a new controller/model/etc.
```bash
docker-compose run web rails generate controller Welcome index
```

### Run a one-off command
```bash
docker-compose run web <command>
```

### Stop containers
```bash
docker-compose down
```

### Stop and remove volumes (clean slate)
```bash
docker-compose down -v
```

### View logs
```bash
docker-compose logs -f web
```

## Project Structure

- `Dockerfile.dev` - Development Docker image
- `docker-compose.yml` - Orchestrates Rails and PostgreSQL services
- `Procfile.dev` - Defines web server and Tailwind CSS watcher processes

## Features

- **PostgreSQL** - Database with persistent storage
- **Tailwind CSS** - Utility-first CSS framework
- **Importmap** - JavaScript module management
- **Hotwire** - Turbo and Stimulus for modern web interactions

## Notes

- The database data persists in a Docker volume named `postgres_data`
- Gem dependencies are cached in a volume named `bundle_cache` for faster rebuilds
- All code changes are reflected immediately thanks to volume mounting
- The `./bin/dev` command runs both the Rails server and Tailwind CSS watcher (via Procfile.dev)
