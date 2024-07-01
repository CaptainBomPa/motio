FROM openjdk:17-jdk-slim

WORKDIR /app

COPY build/libs/motio-auth.jar motio-auth.jar

EXPOSE 8070

CMD ["java", "-jar", "motio-auth.jar"]
