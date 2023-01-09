FROM amazoncorretto:11
ADD  ./spring-petclinic-2.7.3.jar /
WORKDIR /
EXPOSE 8080
CMD ["java","-jar","spring-petclinic-2.7.3.jar"]
