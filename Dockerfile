# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml and download dependencies
COPY stocky-api/pom.xml stocky-api/
RUN mvn -f stocky-api/pom.xml dependency:go-offline

# Copy source code and build
COPY stocky-api stocky-api
RUN mvn -f stocky-api/pom.xml -DskipTests clean package

# Stage 2: Run the application
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy built JAR from the build stage
COPY --from=build /app/stocky-api/target/stocky-api-0.0.1-SNAPSHOT.jar app.jar

# Expose the app port
EXPOSE 8080

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
