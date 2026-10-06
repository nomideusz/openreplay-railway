# OpenReplay's analytics store. Stock ClickHouse at the version OpenReplay
# v1.28.0 ships with, plus OpenReplay's schema and one config file that keeps
# it small (logs to the console, ClickHouse's own metric tables off).
FROM clickhouse/clickhouse-server:26.2.19.43-alpine

COPY railway.xml /etc/clickhouse-server/config.d/railway.xml
# The stock file listens on :: and 0.0.0.0; on Railway :: is already
# dual-stack, so the second bind fails with "Address already in use" on every
# boot. Overwritten, not deleted: Railway resurrects files removed in a later layer.
COPY listen.xml /etc/clickhouse-server/config.d/docker_related_config.xml
# Every statement is IF NOT EXISTS / OR REPLACE, so it runs on every boot:
# a bumped schema file adds its new tables without a manual migration step.
COPY init_ch_schema.sql /docker-entrypoint-initdb.d/init_ch_schema.sql
ENV CLICKHOUSE_DB=default \
    CLICKHOUSE_USER=openreplay \
    CLICKHOUSE_ALWAYS_RUN_INITDB_SCRIPTS=1
