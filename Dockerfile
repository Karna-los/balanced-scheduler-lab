FROM scratch

COPY bin/balanced-scheduler /balanced-scheduler

USER 65532:65532

ENTRYPOINT ["/balanced-scheduler"]
