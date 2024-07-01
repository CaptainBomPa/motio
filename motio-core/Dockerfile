FROM openjdk:17-jdk-slim

WORKDIR /app

COPY build/libs/motio-core.jar motio-core.jar

EXPOSE 8080

CMD ["java", "-jar", "motio-core.jar"]
