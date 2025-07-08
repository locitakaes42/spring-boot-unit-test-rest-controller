# Multi-stage build untuk optimasi ukuran image
FROM openjdk:17-jdk-slim as builder

WORKDIR /app
COPY pom.xml .
COPY src ./src
COPY mvnw .
COPY .mvn ./.mvn

# Build aplikasi
RUN chmod +x mvnw
RUN ./mvnw clean package -DskipTests

# Final stage
FROM openjdk:17-jre-slim

WORKDIR /app

# Install curl untuk health check
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy JAR file dari builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run aplikasi
ENTRYPOINT ["java", "-jar", "app.jar"]