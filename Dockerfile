FROM eclipse-temurin:21-jre-alpine

WORKDIR /app
COPY rest-api-demo/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

# docker build -t my-springboot-app .
# docker run -p 8080:8080 my-springboot-app