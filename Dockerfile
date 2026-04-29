FROM debian:bookworm-slim

COPY bin/balanced-scheduler /usr/local/bin/balanced-scheduler

USER 65532:65532

ENTRYPOINT ["/usr/local/bin/balanced-scheduler"]
