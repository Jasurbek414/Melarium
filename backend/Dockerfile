# ══════════════════════════════════════════════════════
# MELARIUM Backend — Multi-Stage Docker Build
# Java 17, Spring Boot 3.2
# ══════════════════════════════════════════════════════

# Stage 1: Build
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copy pom.xml first for better layer caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests -B

# ──────────────────────────────────────────────────────
# Stage 2: Runtime (minimal JRE image)
FROM eclipse-temurin:17-jre-alpine AS runtime

WORKDIR /app

# Security: non-root user
RUN addgroup -S melarium && adduser -S melarium -G melarium

# Copy built JAR
COPY --from=builder /app/target/melarium-backend-*.jar app.jar

# Set ownership
RUN chown melarium:melarium app.jar
USER melarium

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]
