FROM maven:3.5.4-jdk-8-alpine as build
COPY ./pom.xml ./pom.xml
COPY ./src ./src
RUN mvn dependency:go-offline -B
RUN mvn package
FROM openjdk:8u171-jre-alpine
WORKDIR /app
COPY --from=build target/SimpleJavaProject-*.jar ./app/SimpleJavaProject.jar
CMD ["java", "-jar", "./app/SimpleJavaProject.jar"]
