FROM maven:3-eclipse-temurin-11

RUN mkdir /rre

WORKDIR /rre

COPY rre-server-1.1.jar /rre/
COPY src /rre/src
COPY pom.xml /rre/

# Lets install the RRE plugin dependencies locally.
RUN mvn -B dependency:resolve-plugins dependency:resolve clean package -DincludeScope=runtime

EXPOSE 8080
