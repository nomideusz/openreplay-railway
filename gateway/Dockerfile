# OpenReplay's single public entry point: the dashboard (static files from
# the upstream frontend image), the tracker ingest endpoint, both APIs and the
# signed recording downloads, routed over Railway's private network.
FROM nginx:1.31.8-alpine
COPY --from=ghcr.io/two-workspaces/openreplay-frontend:v1.28.6 /var/www/openreplay /var/www/openreplay
COPY default.conf.template /etc/nginx/templates/default.conf.template
RUN rm /etc/nginx/conf.d/default.conf
# Have the stock entrypoint read the resolver from /etc/resolv.conf (Railway's
# is IPv6) into ${NGINX_LOCAL_RESOLVERS} for the template.
ENV NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1
