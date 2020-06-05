FROM maven:3.6.3-adoptopenjdk-11

RUN mkdir /rre

WORKDIR /rre

COPY rre-server-1.1.jar /rre/
COPY src /rre/src
COPY pom.xml /rre/

# Lets install the RRE plugin.
RUN mvn dependency:resolve
RUN mvn dependency:resolve-plugins
RUN mvn rre:evaluate
RUN mvn rre-report:report

EXPOSE 8080
