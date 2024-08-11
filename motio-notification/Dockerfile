FROM arm64v8/openjdk:17-jdk-slim

WORKDIR /app

COPY build/libs/motio-notification.jar motio-notification.jar

EXPOSE 8050

CMD ["java", "-jar", "motio-notification.jar"]
