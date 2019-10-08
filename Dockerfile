FROM openjdk:11
COPY target/containerdemo-0.1.0-jar-with-dependencies.jar /opt/hello/lib/containerdemo-0.1.0.jar
ENTRYPOINT ["java", "-jar", "/opt/hello/lib/containerdemo-0.1.0.jar"]