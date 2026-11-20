# ==============================================================================
# Production Dockerfile for Lavalink v4 on Railway.com
# ==============================================================================
# Official container base image with OpenJDK 17/21 runtime & Lavalink v4
FROM ghcr.io/lavalink-devs/lavalink:4

# Working directory inside the container
WORKDIR /opt/Lavalink

# Default port (Railway dynamically overrides PORT at runtime)
ENV PORT=2333

# JVM container options optimized for cloud PaaS (Railway 512MB - 8GB RAM tiers)
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError"

# Ensure directories exist with proper ownership for the non-root lavalink user
USER root
RUN mkdir -p /opt/Lavalink/plugins /opt/Lavalink/logs && \
    chown -R lavalink:lavalink /opt/Lavalink
USER lavalink

# Copy configuration and plugins
COPY --chown=lavalink:lavalink application.yml /opt/Lavalink/application.yml
COPY --chown=lavalink:lavalink plugins/ /opt/Lavalink/plugins/

# Informational port exposure
EXPOSE 2333

# HotSpot JVM executes as PID 1, allowing graceful handling of SIGTERM & SIGINT
ENTRYPOINT ["java", "-jar", "Lavalink.jar"]
