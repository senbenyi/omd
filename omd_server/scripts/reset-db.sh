#!/usr/bin/env bash
# 清空 omd_restaurant 库内所有表与数据，保留库本身。
# 下次启动 API 时会 EnsureCreated 并重新写入演示种子数据。
set -euo pipefail

CONN="${OMD_DB_URL:-postgresql://omd:omd_secret@localhost:5432/omd_restaurant}"

echo "Resetting database: $CONN"
psql "$CONN" -v ON_ERROR_STOP=1 <<'SQL'
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO omd;
GRANT ALL ON SCHEMA public TO public;
SQL

echo "Database cleared. Restart the API to recreate tables and seed demo data."
