FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip python3-virtualenv git sudo \
    qemu-utils git kpartx debootstrap curl

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "bash", "/entrypoint.sh" ]
