FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip python3-virtualenv python3-pkg-resources git sudo \
    qemu-utils git kpartx debootstrap curl && \
    apt-get clean all

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "bash", "/entrypoint.sh" ]
