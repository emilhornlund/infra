FROM docker:cli

ARG REGCTL_VERSION=v0.11.5
ARG TARGETARCH=amd64

RUN apk add --no-cache \
      curl \
      tzdata \
    && curl -fsSL \
      "https://github.com/regclient/regclient/releases/download/${REGCTL_VERSION}/regctl-linux-${TARGETARCH}" \
      -o /usr/local/bin/regctl \
    && chmod +x /usr/local/bin/regctl

COPY scripts/registry-cleanup.sh /usr/local/bin/registry-cleanup
COPY images/maintenance/maintenance.sh /usr/local/bin/maintenance
COPY images/maintenance/entrypoint.sh /usr/local/bin/maintenance-entrypoint

RUN chmod +x \
    /usr/local/bin/registry-cleanup \
    /usr/local/bin/maintenance \
    /usr/local/bin/maintenance-entrypoint

ENTRYPOINT ["/usr/local/bin/maintenance-entrypoint"]