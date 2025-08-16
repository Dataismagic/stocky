# Step 1: Use Maven with JDK 17 to build the project
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy everything (multi-module project needs both stocky-api and stocky-mobile)
COPY . .

# Package the whole project, skip tests
RUN mvn -DskipTests clean package

# Step 2: Run the Spring Boot API
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy only the built JAR from stocky-api
COPY --from=build /app/stocky-api/target/stocky-api-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
