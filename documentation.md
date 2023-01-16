# **Full pipeline**
---------------------

## **This document describe the full pipelie life of the JAVA project with the follwig stages .**
  * git checkout
  * build & SonarQube analysis
  * Quality Gate
  * junit testResults
  * rtServer (artifactory configuration) , rtMavenDeployer (repository choosing )
  * rtMavenRun (execute maven goals)
  * Publish build info
  * ![](img\2.png)

* ## prereusites 
   * jenkins setup with atleast one node
   * installed java and maven on the node
   * configure maven  in manage jenkins -> global tool conguration 
      * this is used in 'rtMavenRun tool section'. 
             
         ![](img\1.png).
      * configure sonarqube in manage jenkins -> system configuration
      * ![](img\.png)
    * write jenkis file where the code is present . ie SCM
    * a branchig strategy ( here we follw github branching strategy ie. here we have four branches every branch a pipeline on the dev branch for every commit we triggr the build. on the testing branch we configure cronjob  )
    * 
* ### we use git method to checkout 
   ```bash
    git url: 'https://github.com/vikashpudi/spring-petclini.git', 
        branch: 'main'
   ```
    ![](img\3.png)
* ###  build & SonarQube analysis
  ```bash
   stage("build & SonarQube analysis") {
            steps {
              sh' echo ***********SONAR SCANING************************'
              withSonarQubeEnv('sonarqube') {
                sh "mvn package sonar:sonar"}
              }
            }
  ```
* ###  Quality Gate stage
  ```bash
  stage("Quality Gate") {
            steps {
              sh' echo ***********QUALITY GATE************************'
              timeout(time: 30, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
              }
            }
          }
  ```
*  ### junit testResults
  ```
  junit testResults: 'target/surefire-reports/*.xml'
  ```
*  ### rtServer 
  ```bash
   rtServer (
                  id: 'Artifactory',
                  url: 'https://beatyourlimits.jfrog.io/artifactory/',
                  credentialsId: 'jfrog',
                   bypassProxy: true,
                   timeout: 300
                       )
  ```
   * id: this will be used when ever uwant your server configuration
   * url: this is our artifactory url 
   * credentialsId : give the id which u configure in the jenkis credentals
       manage jenkins -> manage credentials
        ![](img\4.png)
*  ### rtMavenDeployer
``` bash
    rtMavenDeployer (
                        id: "spc_DEPLOYER",
                        serverId: "Artifactory",
                        releaseRepo: "demo",
                        snapshotRepo: "snapdemo"
                                )
```
    * id will be used in further steps
    * give id whic u haven given in rtserver
    * give the repositery names where u want to preserve the artifact
*  ###  rtMavenRun
  ```bash
  rtMavenRun (
                    tool: "maven", // Tool name from Jenkins configuration
                     pom: "pom.xml",
                     goals: "install ",
                     deployerId: "spc_DEPLOYER"
                 )
  ```
    * tool: which was given in global tools
    * pom: path of your pm.xml file
    * goals: maven goals
    * deployerId : wich was given in the rtMavenDeployers id section
*  ### Publish build info
```bash 
rtPublishBuildInfo (
                    serverId: "Artifactory"
                )
```
 * after uploading publish the details in the jenkins build page
  



  --------------------------------------------------------------------------------------------------
````
this command is used to download the artifact from the jfrog repositery
  curl -u "pudivikash:Devops@123456" -X GET https://beatyourlimits.jfrog.io/artifactory/demo/org/springframework/samples/spring-petclinic/2.7.3/spring-petclinic-2.7.3.jar --output spring-petclinic-2.7.3.jar
````



----------------------------------------------------------------------------------------------------
when i run docker image build command manually in node it works but when it runs from jenkins it show demon error. `solutuion --->  sudo chmod 777 /var/run/docker.sock`  (why)