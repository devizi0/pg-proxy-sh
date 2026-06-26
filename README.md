# pg-proxy-sh

A simple shell script for giving AI agents PostgreSQL access without exposing credentials.

You keep your DB credentials in a local `.env` file that the AI can't read. The AI just passes a SQL query to the script and gets back the results. That's it.

## Install

You need psql.

```bash
brew install libpq && brew link --force libpq    # macOS
sudo apt install postgresql-client               # Ubuntu
```

## Setup

```bash
# interactive
./add_env.sh <name>

# or just create the file manually
# envs/ai-do-not-read-<name>.env
DB_HOST=your-host.rds.amazonaws.com
DB_PORT=5432
DB_USER=username
DB_PASSWORD=password
DB_NAME=database
```

## Usage

```bash
./pg_query.sh "SELECT version();"

./pg_query.sh "SELECT * FROM users LIMIT 10;" mydb

./pg_query.sh -c prod "SELECT count(*) FROM orders;" mydb
```

## Security

`envs/*.env` is in `.gitignore` so credentials never get committed. Password is passed via `PGPASSWORD` env var so it's never exposed on the command line.
