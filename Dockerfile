FROM arm32v7/alpine:3.10

# Set ENV_VAR for Greengrass RC to be untarred inside Docker Image
ARG GREENGRASS_RELEASE_URL=https://d1onfpft10uf5o.cloudfront.net/greengrass-core/downloads/1.10.1/greengrass-linux-armv7l-1.10.1.tar.gz

# Install Greengrass Core Dependencies
RUN apk add --no-cache tar gzip wget xz shadow libc6-compat ca-certificates iproute2 python2 python3 openjdk8 nodejs-current && \
    ln -s /usr/bin/java /usr/local/bin/java8 && \
    wget $GREENGRASS_RELEASE_URL && \
    ln -s /usr/bin/node /usr/bin/nodejs12.x && \
    apk del wget

# Copy Greengrass Licenses AWS IoT Greengrass Docker Image
COPY greengrass-license-v1.pdf /
# Copy start-up script
COPY "greengrass-entrypoint.sh" /

# Setup Greengrass inside Docker Image
RUN export GREENGRASS_RELEASE=$(basename $GREENGRASS_RELEASE_URL) && \
    tar xzf $GREENGRASS_RELEASE -C / && \
    rm $GREENGRASS_RELEASE && \
    useradd -r ggc_user && \
    groupadd -r ggc_group

# Expose 8883 to pub/sub MQTT messages
EXPOSE 8883

# Install SSH Server
RUN apk add --upgrade \
    openssh 
COPY sshd_config /etc/ssh/sshd_config
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N '' \
	&& echo "root:root" | chpasswd 

COPY "ssh-greengrass-entrypoint.sh" /
RUN ["chmod", "+x", "greengrass-entrypoint.sh"]
RUN ["chmod", "+x", "ssh-greengrass-entrypoint.sh"]
EXPOSE 22
