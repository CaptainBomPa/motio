FROM arm64v8/openjdk:17-jdk-slim

WORKDIR /app

COPY build/libs/motio-admin.jar motio-admin.jar

EXPOSE 8060

CMD ["java", "-jar", "motio-admin.jar"]
