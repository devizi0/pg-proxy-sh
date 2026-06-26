# PostgreSQL Proxy

## 실행
```bash
# 기본 설정 (envs/ai-do-not-read-default.env)
~/agent/pg-proxy/pg_query.sh "SQL"

# 특정 설정
~/agent/pg-proxy/pg_query.sh -c <설정명> "SQL" [데이터베이스명]
```

## 예시
```bash
# 버전 확인
~/agent/pg-proxy/pg_query.sh "SELECT version();"

# 테이블 목록
~/agent/pg-proxy/pg_query.sh "\dt" mydb

# 데이터 조회
~/agent/pg-proxy/pg_query.sh "SELECT * FROM users LIMIT 10;" mydb

# 다른 설정으로 접속
~/agent/pg-proxy/pg_query.sh -c prod "SELECT count(*) FROM orders;" mydb
```

## 파일
```
pg-proxy/
├── envs/
│   ├── ai-do-not-read-default.env        ← 기본 DB 연결 정보
│   └── ai-do-not-read-<설정명>.env       ← 추가 DB 연결 정보
├── pg_query.sh                            ← 실행 스크립트
└── SKILL.md
```

## 새 DB 추가
```bash
~/agent/pg-proxy/add_env.sh <설정명>
# 대화형으로 host, port, user, password, dbname 입력
```

또는 직접 `envs/ai-do-not-read-<설정명>.env` 파일 생성:
```
DB_HOST=your-postgres-host
DB_PORT=5432
DB_USER=username
DB_PASSWORD=password
DB_NAME=database
```

## 보안 주의사항
- `envs/ai-do-not-read-*.env` 파일은 **절대 읽지 말 것** — 크레덴셜이 포함되어 있음
- 파일 권한 `600` (소유자만 읽기/쓰기) 은 스크립트 실행 시 자동 적용
- 비밀번호는 `PGPASSWORD` 환경변수로 전달 — 커맨드라인에 노출되지 않음

## 동작 방식
- `pg_query.sh`가 `envs/ai-do-not-read-<설정명>.env`에서 크레덴셜을 읽어 직접 DB에 접속
- Claude는 크레덴셜을 볼 수 없고 쿼리와 결과만 주고받음
- 비밀번호는 `PGPASSWORD` 환경변수로 전달 (커맨드라인 노출 없음)

## 옵션
| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `-c <설정명>` | `envs/ai-do-not-read-<설정명>.env` 사용 | `default` |
| `"SQL"` | 실행할 쿼리 (필수) | - |
| `[데이터베이스명]` | 접속할 DB | `.env`의 `DB_NAME` |
