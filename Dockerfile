# Build stage
FROM maven:3.9.4-eclipse-temurin-17-alpine AS build

WORKDIR /build

# Install Node.js and npm for frontend module (required by parent build)
RUN apk add --no-cache nodejs npm

# Copy parent pom and resolve parent dependencies first
COPY pom.xml ./
RUN mvn dependency:resolve-sources -q 2>/dev/null || true

# Copy all module pom files to resolve dependencies
COPY stocky-api/pom.xml ./stocky-api/
COPY stocky-web/pom.xml ./stocky-web/ 2>/dev/null || echo "No web pom found"

# Resolve all dependencies
RUN mvn dependency:go-offline -B -q 2>/dev/null || true

# Copy source code for API module only
COPY stocky-api/src ./stocky-api/src

# Create empty web module structure to satisfy parent pom
RUN mkdir -p stocky-web/src/main/java && \
    echo 'public class EmptyClass {}' > stocky-web/src/main/java/EmptyClass.java

# Build the project with profiles to skip frontend
RUN mvn clean package -DskipTests -Dmaven.test.skip=true -pl stocky-api -am --batch-mode

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
