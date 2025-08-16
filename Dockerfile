# Use official Maven image with JDK 17
FROM maven:3.9.4-eclipse-temurin-17 AS build

WORKDIR /app

# Copy everything (this ensures no missing files)
COPY . .

# Build the entire project but package only API
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Install curl for health checks  
RUN apk add --no-cache curl

# Copy the JAR file from stocky-api module
COPY --from=build /app/stocky-api/target/*.jar app.jar

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser && \
    chown appuser:appuser app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
