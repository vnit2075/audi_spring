# -------- Stage 1: Build the app --------
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy configuration and sources
COPY pom.xml .
COPY src ./src

# Build production jar skipping tests
RUN mvn clean package -DskipTests

# -------- Stage 2: Runtime Image --------
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy built artifact
COPY --from=build /app/target/*.jar app.jar

# Expose HTTP port
EXPOSE 8088

# Execution command
ENTRYPOINT ["java", "-jar", "app.jar"]
