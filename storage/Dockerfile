# S3-compatible store for recordings (mobs), cached page assets and source
# maps: RustFS, the same server OpenReplay's own docker-compose install uses.
FROM rustfs/rustfs:1.0.0-beta.1

# Railway mounts volumes root-owned and with lost+found at the top, which
# RustFS would list as a bucket: data lives in a subdirectory, and the server
# runs as root to write to the volume (busybox here has no way to drop to the
# rustfs user after a chown).
USER root
ENV RUSTFS_VOLUMES=/data/rustfs \
    RUSTFS_ADDRESS=[::]:9000 \
    RUSTFS_CONSOLE_ENABLE=false \
    RUSTFS_OBS_LOG_DIRECTORY=
CMD ["rustfs"]
