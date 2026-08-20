# Copyright (C) 2026  Henrique Almeida
# This file is part of minecraft-slim.
#
# minecraft-slim is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# minecraft-slim is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with minecraft-slim.  If not, see <https://www.gnu.org/licenses/>.

################################################################################
# JRE Builder
FROM eclipse-temurin:25.0.3_9-jre@sha256:7c1c6297dc3a3ff947922f3ab14ecd326e29083b9edaa8dbff3b94fef1688311 AS jre-builder

# Create rootfs
RUN mkdir -p /rootfs/opt/java /rootfs/tmp && \
  chmod 1777 /rootfs/tmp

# Copy JRE and its dependencies to rootfs
RUN cp -r /opt/java/openjdk/* /rootfs/opt/java/ && \
  ldd /opt/java/openjdk/bin/java | grep "=> /" | awk '{print $3}' | \
  xargs -I '{}' cp --parents '{}' /rootfs && \
  find /opt/java/openjdk -name "*.so*" -exec ldd {} \; | grep "=> /" | awk '{print $3}' | \
  sort -u | xargs -I '{}' cp --parents '{}' /rootfs

# Copy additional dependencies
RUN cp --parents \
  /lib64/ld-linux-x86-64.so.2 \
  /lib/x86_64-linux-gnu/libutil.so.1 \
  /lib/x86_64-linux-gnu/libncursesw.so.6 \
  /lib/x86_64-linux-gnu/libtinfo.so.6 \
  /lib/x86_64-linux-gnu/libudev.so.1 \
  /rootfs && \
  find /rootfs/lib/x86_64-linux-gnu -name "*.so*" -exec ldd {} \; | grep "=> /" | awk '{print $3}' | \
  sort -u | xargs -I '{}' cp --parents '{}' /rootfs

################################################################################
# Final Image
FROM scratch AS final
ARG PAPER_URL="https://fill-data.papermc.io/v1/objects/bd3a58cf96874e5ea6643f5f6fe9b4f5bf9e34b795fa078c2f0ee8b98b2f907e/paper-26.2-112.jar"

COPY --from=jre-builder /rootfs /
ADD --chown=65534:65534 ${PAPER_URL} /opt/paper/paper.jar

ENV JAVA_HOME=/opt/java
ENV PATH="/opt/java/bin"
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

EXPOSE 25565
WORKDIR /data
USER 65534:65534
ENTRYPOINT ["/opt/java/bin/java", "-jar", "/opt/paper/paper.jar", "nogui"]
