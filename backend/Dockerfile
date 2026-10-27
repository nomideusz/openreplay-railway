# OpenReplay's Go services in one container. Upstream runs each as its own
# container sharing one volume (/mnt/efs): sink writes recordings there and
# storage uploads them, canvases stages screenshots there. Railway volumes
# can't be shared between services, so they share a container instead.
# The http image is the base: it carries the GeoIP and user-agent databases.
# Upstream patches each service on its own (chart AppVersion per service).
FROM ghcr.io/two-workspaces/openreplay-sink:v1.28.2 AS sink
FROM ghcr.io/two-workspaces/openreplay-storage:v1.28.2 AS storage
FROM ghcr.io/two-workspaces/openreplay-ender:v1.28.2 AS ender
FROM ghcr.io/two-workspaces/openreplay-db:v1.28.3 AS db
FROM ghcr.io/two-workspaces/openreplay-assets:v1.28.4 AS assets
FROM ghcr.io/two-workspaces/openreplay-canvases:v1.28.2 AS canvases
FROM ghcr.io/two-workspaces/openreplay-api:v1.28.9 AS api

FROM ghcr.io/two-workspaces/openreplay-http:v1.28.3
USER root
# zstd: canvases packs screenshots; psql: schema init; curl: bucket init; bash: wait -n
RUN apk add --no-cache zstd postgresql17-client curl bash
RUN mkdir /home/openreplay/bin && mv /home/openreplay/service /home/openreplay/bin/http
COPY --from=sink /home/openreplay/service /home/openreplay/bin/sink
COPY --from=storage /home/openreplay/service /home/openreplay/bin/storage
COPY --from=ender /home/openreplay/service /home/openreplay/bin/ender
COPY --from=db /home/openreplay/service /home/openreplay/bin/db
COPY --from=assets /home/openreplay/service /home/openreplay/bin/assets
COPY --from=canvases /home/openreplay/service /home/openreplay/bin/canvases
COPY --from=api /home/openreplay/service /home/openreplay/bin/api
# Fixed settings from upstream's docker-envs/*.env; connection strings and
# secrets come from the template's variables.
ENV AWS_REGION=us-east-1 \
    ch_db=default \
    LICENSE_KEY= \
    KAFKA_USE_SSL=false \
    FS_CLEAN_HRS=24
COPY init_pg_schema.sql /home/openreplay/init_pg_schema.sql
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh
ENTRYPOINT ["/railway-entrypoint.sh"]
