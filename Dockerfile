# Multi-stage build for Maven multi-module project
FROM maven:3.8.6-openjdk-17-slim AS build

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
FROM openjdk:17-jre-slim

WORKDIR /app

# Copy the built jar from stocky-api module (adjust if different module has main class)
COPY --from=build /app/stocky-api/target/*.jar app.jar

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
