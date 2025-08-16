# Dockerfile (place in repo root)
# Stage 1: build the multi-module Maven project
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace

# Copy entire repo so Maven can resolve parent modules
COPY . /workspace

# Build all modules (skip tests to speed up)
RUN mvn -B -DskipTests clean package

# Stage 2: runtime image (slim)
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Copy the built backend jar from the multi-module build
COPY --from=build /workspace/stocky-api/target/stocky-api-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

# Use env vars for DB creds; Render will provide $PORT
ENTRYPOINT ["sh","-c","java -Dserver.port=${PORT:-8080} \
  -Dspring.datasource.url=${SPRING_DATASOURCE_URL} \
  -Dspring.datasource.username=${SPRING_DATASOURCE_USERNAME} \
  -Dspring.datasource.password=${SPRING_DATASOURCE_PASSWORD} \
  -Dspring.jpa.hibernate.ddl-auto=${SPRING_JPA_HIBERNATE_DDL_AUTO:-update} \
  -jar /app/app.jar"]
