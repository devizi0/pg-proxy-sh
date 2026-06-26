# pg-proxy-sh

A shell-based PostgreSQL proxy that lets AI agents execute queries **without ever seeing credentials**.

## Concept

AI agents (like Claude) need database access to be useful — but handing them raw credentials is a security risk. This script acts as a thin proxy: the agent calls the script with a SQL query, the script loads credentials from a local `.env` file that the AI cannot read, and only the query result is returned.

```
AI Agent  -->  pg_query.sh  -->  .env (AI cannot read)  -->  PostgreSQL DB
              (only sees SQL        (credentials stay
               and results)          on your machine)
```

## Usage

```bash
# Default config (envs/ai-do-not-read-default.env)
~/agent/pg-proxy/pg_query.sh "SELECT version();"

# Specific config
~/agent/pg-proxy/pg_query.sh -c <config-name> "SQL" [database]
```

## Examples

```bash
# Check version
~/agent/pg-proxy/pg_query.sh "SELECT version();"

# List tables
~/agent/pg-proxy/pg_query.sh "\dt" mydb

# Query data
~/agent/pg-proxy/pg_query.sh "SELECT * FROM users LIMIT 10;" mydb

# Use a different config
~/agent/pg-proxy/pg_query.sh -c prod "SELECT count(*) FROM orders;" mydb
```

## Setup

### 1. Install psql

```bash
# macOS
brew install libpq
brew link --force libpq

# Ubuntu/Debian
sudo apt install postgresql-client
```

### 2. Add credentials

```bash
# Interactive setup
./add_env.sh <config-name>

# Or manually create envs/ai-do-not-read-<config-name>.env
DB_HOST=your-host.rds.amazonaws.com
DB_PORT=5432
DB_USER=username
DB_PASSWORD=password
DB_NAME=database
```

### 3. Run

```bash
chmod +x pg_query.sh
./pg_query.sh "SELECT 1;"
```

## File Structure

```
pg-proxy/
├── envs/
│   ├── ai-do-not-read-default.env    # credentials (git ignored)
│   └── ai-do-not-read-<name>.env     # additional configs
├── pg_query.sh                        # main script
├── add_env.sh                         # interactive credential setup
└── .gitignore                         # excludes envs/*.env
```

## Security

- `envs/*.env` files are **git ignored** — credentials never leave your machine
- File permissions are set to `600` (owner read/write only) automatically
- Password is passed via `PGPASSWORD` environment variable — never exposed on the command line

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `-c <name>` | Use `envs/ai-do-not-read-<name>.env` | `default` |
| `"SQL"` | SQL query to execute (required) | - |
| `[database]` | Database to connect to | value in `.env` |

## Requirements

- zsh
- psql (auto-detected via `command -v psql`)
