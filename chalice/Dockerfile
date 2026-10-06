# OpenReplay's Python API (/api): login, sign-up, projects, session search and
# the signed URLs the player uses to fetch recordings.
FROM public.ecr.aws/p1t3u8a3/chalice:v1.28.0

# Fixed settings from upstream's docker-envs/chalice.env; connection strings
# and secrets come from the template's variables.
ENV TZ=UTC \
    LISTEN_PORT=8000 \
    version_number=v1.28.0 \
    root_path=/api \
    jwt_algorithm=HS512 \
    JWT_EXPIRATION=86400 \
    pg_port=5432 \
    ch_port=9000 \
    ch_port_http=8123 \
    ch_database=default \
    CH_COMPRESSION=false \
    AWS_DEFAULT_REGION=us-east-1 \
    sessions_region=us-east-1 \
    sessions_bucket=mobs \
    IOS_VIDEO_BUCKET=mobs \
    ASSIST_RECORDS_BUCKET=records \
    sourcemaps_bucket=sourcemaps \
    js_cache_bucket=sessions-assets \
    LICENSE_KEY= \
    LOGLEVEL=INFO \
    EMAIL_PORT=587 \
    EMAIL_USE_TLS=true \
    EMAIL_USE_SSL=false \
    EMAIL_FROM="OpenReplay<do-not-reply@openreplay.com>" \
    # Assist and the source map reader aren't part of this template.
    ASSIST_URL=http://127.0.0.1:9/assist/%s \
    sourcemaps_reader=http://127.0.0.1:9/{}/sourcemaps \
    # The installation check probes each Go service at a Kubernetes address;
    # here they share one container, so only Postgres and Redis are checked.
    SKIP_H_BACKENDSERVICES=true \
    SKIP_H_SSL=true

# Upstream binds 0.0.0.0, which Railway's IPv6 private network can't reach.
# Only CMD is replaced, so upstream's tini ENTRYPOINT stays.
CMD ["sh", "-c", "exec uvicorn app:app --host :: --port ${LISTEN_PORT} --proxy-headers --log-level ${S_LOGLEVEL:-warning}"]
