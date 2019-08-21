## Disposable image for mvn build
FROM maven:3.6.0-jdk-8-alpine AS builder

COPY pom.xml /build/
COPY src     /build/src/

WORKDIR /build/

RUN mvn package
RUN mkdir -p target/extracted
RUN unzip target/camunda-webapp-0.1.0.jar -d target/extracted

## Actual camunda engine image
FROM openjdk:8-jre-alpine

EXPOSE 8080

# Create default working directory for spring-boot/tomcat
VOLUME /tmp

ARG BASE=/build/target/extracted

COPY --from=builder ${BASE}/BOOT-INF/lib     /app/lib
COPY --from=builder ${BASE}/META-INF         /app/META-INF
COPY --from=builder ${BASE}/BOOT-INF/classes /app

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-cp","app:app/lib/*","ch.helsana.bpm.CamundaWebApplication"]
