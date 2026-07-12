# Herve 2

A Rails 8.1 application with PostgreSQL, Tailwind CSS, and importmap, running entirely in Docker containers.
Helps user buy a car without pain

# Local Development

## Setup

The project has been dockerized. This means you need to have Docker up and running on your machine to start the project.

> [!NOTE]  
> Please note that the dockerfile used by docker compose is `Dockerfile.dev`
> `Dockerfile` should be used for production

Copy the environment file and set the database variables (same values as in signaux-faibles-v2):

```
cp .env.example .env
```

```
DATABASE_HOST=db
DATABASE_PORT=5432
DATABASE_NAME=herve_2
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
```

First create start the `db` service by running

```
docker-compose up -d db
```

then

```
docker-compose run web rails db:create db:migrate
```

This will create the database and run the migrations. For your information, the database is a PostgreSQL database and we use the default configuration for the database connection (host: db, username: postgres, password: password).

Finally start the application by running

```
docker-compose up --build
```

If the application still takes a long time to start, or if it fails, check the container logs for any error messages:

```
docker-compose logs web
```

If you want to connect a dbms to the local dockerized databases, then use the following connection details :

```
Host: localhost
Port: 5433
Database: herve_2_development
Username: postgres
Password: password
```

The application is available at http://localhost:3001

## Common Commands

### Run Rails console

```
docker-compose run web rails console
```

### Run database migrations

```
docker-compose run web rails db:migrate
```

### Run tests

```
docker-compose run web rails test
```

### Stop containers

```
docker-compose down
```

### View logs

```
docker-compose logs -f web
```

## Scalingo (staging / production)

See [Solid Queue on Scalingo](https://doc.scalingo.com/languages/ruby/rails/solid-queue).

1. Attach a PostgreSQL add-on so `DATABASE_URL` is set automatically.
2. Deploy via git push; `postdeploy` runs `rails db:prepare` (primary and queue schemas).
3. Scale the worker so background jobs run:

```
scalingo --app herve-2-staging scale worker:1
```

The `web` container only runs Puma. Solid Queue runs in the `worker` container (`bin/jobs`), not inside Puma.
