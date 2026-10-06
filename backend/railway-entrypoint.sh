#!/bin/bash
# Prepares Postgres and the S3 buckets, then runs OpenReplay's Go services
# side by side. If any of them exits, the container exits and Railway
# restarts the lot.
set -euo pipefail
B=/home/openreplay/bin
mkdir -p "$FS_DIR"

until psql "$POSTGRES_STRING" -qc 'select 1' >/dev/null 2>&1; do echo "waiting for Postgres"; sleep 2; done
# Upstream's schema file stops on its own when the tables already exist.
psql "$POSTGRES_STRING" -q -f /home/openreplay/init_pg_schema.sql

s3() { curl -sS -o /dev/null -w '%{http_code}' --aws-sigv4 "aws:amz:${AWS_REGION}:s3" \
         --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" "$@"; }
until [ "$(s3 "$S3_INTERNAL/" || true)" = 200 ]; do echo "waiting for object storage"; sleep 2; done
for b in mobs sessions-assets sourcemaps records spots static; do s3 -X PUT "$S3_INTERNAL/$b" >/dev/null || true; done
# The player loads cached CSS, fonts and images straight from this bucket.
s3 -X PUT "$S3_INTERNAL/sessions-assets?policy" -H 'Content-Type: application/json' --data \
  '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":["*"]},"Action":["s3:GetObject"],"Resource":["arn:aws:s3:::sessions-assets/*"]}]}' >/dev/null

# name, then per-service env. Writers use the private S3 endpoint; api signs
# URLs that browsers open, so it gets the public one (routed by the gateway).
run() {
  local name=$1; shift
  env SERVICE_NAME="$name" AWS_ENDPOINT="$S3_INTERNAL" "$@" "$B/$name" > >(awk -v p="[$name] " '{print p $0; fflush()}') 2>&1 &
}
run http     HTTP_PORT=8080 BUCKET_NAME=uxtesting-records
# Assist (live co-browsing) isn't part of this template, but api won't start without a URL for it.
run api      HTTP_PORT=8081 BUCKET_NAME=spots AWS_ENDPOINT="$S3_PUBLIC" ASSIST_URL="${ASSIST_URL:-http://127.0.0.1:9001/assist/%s}"
run canvases HTTP_PORT=8082 BUCKET_NAME=mobs
run sink
run storage  BUCKET_NAME=mobs
run assets   BUCKET_NAME=sessions-assets
run ender
run db

wait -n
echo "a service exited; stopping so Railway restarts the container"
exit 1
