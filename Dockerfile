
FROM openjdk:11


RUN mkdir /app


COPY target/ /app/


WORKDIR /app


CMD ["java", "-jar", "/app/pet-clinic-1.0.0.jar", "--spring.config.location=classpath:/application.properties"]
