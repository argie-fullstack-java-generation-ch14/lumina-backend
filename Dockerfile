# Etapa 1: Compilar el proyecto usando Maven preinstalado en la imagen
FROM --platform=linux/arm64 maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /workspace

COPY pom.xml .
COPY src src

RUN mvn clean package -DskipTests \
    && JAR_FILE="$(find target -maxdepth 1 -type f -name '*.jar' ! -name '*.original' | head -n 1)" \
    && test -n "$JAR_FILE" \
    && cp "$JAR_FILE" /tmp/app.jar

# Etapa 2: Ejecutar el JAR en ARM64 nativo
FROM --platform=linux/arm64 eclipse-temurin:21-jre-jammy

WORKDIR /app

RUN groupadd -r app && useradd -r -g app app

COPY --from=build --chown=app:app /tmp/app.jar /app/app.jar

USER app

EXPOSE 8080

ENTRYPOINT ["java", "-Xmx350m", "-jar", "/app/app.jar"]FROM ubuntu:latest
LABEL authors="Naya"

ENTRYPOINT ["top", "-b"]