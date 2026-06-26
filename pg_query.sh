#!/usr/bin/env zsh
# 사용법: ~/agent/pg-proxy/pg_query.sh [-c 설정명] "SQL" [데이터베이스명]
#   -c 설정명  envs/ai-do-not-read-<설정명>.env 사용 (기본값: default)
# 예시:
#   ~/agent/pg-proxy/pg_query.sh "SELECT version();"
#   ~/agent/pg-proxy/pg_query.sh -c prod "SELECT * FROM users LIMIT 5;" mydb

SCRIPT_DIR="${0:A:h}"
PSQL="$(command -v psql 2>/dev/null || echo /opt/homebrew/opt/libpq/bin/psql)"
CONFIG="default"

# -c 옵션 파싱
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--config)
      CONFIG="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

ENV_FILE="$SCRIPT_DIR/envs/ai-do-not-read-${CONFIG}.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[ERROR] 설정 파일이 없습니다: ai-do-not-read-${CONFIG}.env" >&2
  echo "사용 가능한 설정:" >&2
  ls "$SCRIPT_DIR/envs/" 2>/dev/null | sed 's/ai-do-not-read-//' | sed 's/\.env$//' | sed 's/^/  /' >&2
  exit 1
fi

chmod 600 "$ENV_FILE"

# .env 로드
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" == \#* ]] && continue
  export "$key"="$value"
done < "$ENV_FILE"

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASSWORD" ]]; then
  echo "[ERROR] $ENV_FILE 에 DB_HOST, DB_USER, DB_PASSWORD를 설정하세요." >&2
  exit 1
fi

SQL="${1:-}"
DB="${2:-${DB_NAME:-}}"

if [[ -z "$SQL" ]]; then
  echo "[ERROR] 쿼리를 인수로 전달하세요." >&2
  echo "사용법: $0 [-c 설정명] \"SQL\" [데이터베이스명]" >&2
  echo "" >&2
  echo "사용 가능한 설정:" >&2
  ls "$SCRIPT_DIR/envs/" 2>/dev/null | sed 's/ai-do-not-read-//' | sed 's/\.env$//' | sed 's/^/  /' >&2
  exit 1
fi

# psql 접속 (PGPASSWORD 환경변수로 비밀번호 전달 — 커맨드라인 노출 없음)
export PGPASSWORD="$DB_PASSWORD"

ARGS=(
  -h "$DB_HOST"
  -p "${DB_PORT:-5432}"
  -U "$DB_USER"
  -c "$SQL"
)

if [[ -n "$DB" ]]; then
  ARGS+=("$DB")
fi

exec "$PSQL" "${ARGS[@]}"
