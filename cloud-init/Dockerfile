FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        --no-install-recommends \
        cloud-init \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENTRYPOINT ["/usr/bin/cloud-init"]
CMD ["--help"]
# CMD ["devel", "schema", "--config-file", "/app/cloud_init.yml"]
