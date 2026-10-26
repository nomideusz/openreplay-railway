# OpenReplay's Go services in one container. Upstream runs each as its own
# container sharing one volume (/mnt/efs): sink writes recordings there and
# storage uploads them, canvases stages screenshots there. Railway volumes
# can't be shared between services, so they share a container instead.
# The http image is the base: it carries the GeoIP and user-agent databases.
# Upstream patches each service on its own (chart AppVersion per service).
FROM public.ecr.aws/p1t3u8a3/sink:v1.28.1 AS sink
FROM public.ecr.aws/p1t3u8a3/storage:v1.28.1 AS storage
FROM public.ecr.aws/p1t3u8a3/ender:v1.28.1 AS ender
FROM public.ecr.aws/p1t3u8a3/db:v1.28.2 AS db
FROM public.ecr.aws/p1t3u8a3/assets:v1.28.3 AS assets
FROM public.ecr.aws/p1t3u8a3/canvases:v1.28.1 AS canvases
FROM public.ecr.aws/p1t3u8a3/api:v1.28.8 AS api

FROM public.ecr.aws/p1t3u8a3/http:v1.28.2
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
