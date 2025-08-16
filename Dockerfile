# Build stage
FROM maven:3.9.4-eclipse-temurin-17-alpine AS build

WORKDIR /build

# Install Node.js and npm (required by the web module even if we skip it)
RUN apk add --no-cache nodejs npm

# Copy parent pom first
COPY pom.xml ./

# Copy both module directories completely
COPY stocky-api ./stocky-api/
COPY stocky-web ./stocky-web/

# Build only the API module, but parent needs all modules present
RUN mvn clean package -DskipTests -pl stocky-api -am --batch-mode

# Production stage  
FROM eclipse-temurin:17-jre-alpine

# Install required tools
RUN apk add --no-cache curl tzdata && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

WORKDIR /app

# Create application user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy jar file with proper permissions
COPY --from=build --chown=appuser:appgroup /build/stocky-api/target/*.jar app.jar

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

# JVM optimization flags
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseStringDeduplication"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
