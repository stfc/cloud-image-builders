FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        qemu-utils git kpartx debootstrap \
        python3-pip curl sudo gnupg lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

    
# Copy this entire git directory, as we may be on a branch with changes we want to include
# rather than main
COPY ./ /opt/cloud-image-builders

# Clone octavia and install its diskimage-create requirements
RUN git clone https://opendev.org/openstack/octavia.git /opt/octavia && \
 git --git-dir=/opt/octavia/.git checkout 08003bb7263aef0ff74d30dc1540bfe18d330f9a && \
 pip3 install --no-cache-dir -r /opt/octavia/diskimage-create/requirements.txt

COPY amphora-image-builder/entrypoint.sh entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "bash", "/entrypoint.sh" ]
