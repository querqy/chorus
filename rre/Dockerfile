FROM maven:3-eclipse-temurin-11

ENV MAVEN_OPTS="-Xms1024M -Xmx2048M -XX:MaxMetaspaceSize=1024m -XX:-UseGCOverheadLimit -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn"

RUN mkdir /rre

WORKDIR /rre

COPY rre-server-1.1.jar /rre/
COPY src /rre/src
COPY pom.xml /rre/

# Lets install the RRE plugin dependencies locally.
RUN mvn -B dependency:resolve-plugins dependency:resolve clean package -DincludeScope=runtime

EXPOSE 8080
