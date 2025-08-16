# Multi-stage build for Maven multi-module project
FROM maven:3.9.4-eclipse-temurin-17-alpine AS build

WORKDIR /app

# Copy parent pom.xml first
COPY pom.xml .

# Copy module pom.xml files
COPY stocky-api/pom.xml ./stocky-api/
COPY stocky-web/pom.xml ./stocky-web/

# Download dependencies (this layer will be cached)
RUN mvn dependency:go-offline -B

# Copy source code
COPY stocky-api/src ./stocky-api/src
COPY stocky-web/src ./stocky-web/src

# Build the application (assuming stocky-api is the main module with @SpringBootApplication)
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Install curl for health checks (optional)
RUN apk add --no-cache curl

# Copy the built jar from stocky-api module (adjust if different module has main class)
COPY --from=build /app/stocky-api/target/*.jar app.jar

# Create non-root user
RUN addgroup -g 1000 appuser && adduser -D -s /bin/sh -u 1000 -G appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
