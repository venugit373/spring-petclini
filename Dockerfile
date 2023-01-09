FROM amazoncorretto:11
ADD /home/murali/JAVA/workspace/spring-petclinic/target/spring-petclinic-2.7.3.jar /spc
WORKDIR /spc
EXPOSE 8080
CMD ["java","-jar","spring-petclinic-2.7.3.jar"]
