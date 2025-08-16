# Dockerfile (put in repo root)
# Stage 1: build the multi-module Maven project
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace

# Copy whole repo so Maven can resolve parent modules
COPY . /workspace

# Build everything (skip tests to speed up)
RUN mvn -B -DskipTests clean package

# Normalize the built backend jar to a known location so COPY is simple and reliable
# (this also fails fast if no jar was produced)
RUN ls -la /workspace/stocky-api/target || (echo "target missing" && ls -la /workspace && false)
RUN cp /workspace/stocky-api/target/*.jar /workspace/app.jar

# Stage 2: runtime image (lightweight JRE)
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Copy the normalized jar from the build stage
COPY --from=build /workspace/app.jar ./app.jar

EXPOSE 8080

# Use env vars for DB creds; Render injects $PORT
ENTRYPOINT ["sh","-c","java -Dserver.port=${PORT:-8080} \
  -Dspring.datasource.url=${SPRING_DATASOURCE_URL} \
  -Dspring.datasource.username=${SPRING_DATASOURCE_USERNAME} \
  -Dspring.datasource.password=${SPRING_DATASOURCE_PASSWORD} \
  -Dspring.jpa.hibernate.ddl-auto=${SPRING_JPA_HIBERNATE_DDL_AUTO:-update} \
  -jar /app/app.jar"]
