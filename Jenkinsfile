 pipeline {
    agent { label 'NODE1' }
    /* environment {
       JAVA_HOME = "/usr/lib/jvm/java-11-openjdk-amd64/"
      M2_HOME = "/usr/share/maven/"
        PATH = "$JAVA_HOME/bin:$PATH:$M2_HOME/bin"
    }*/
    triggers { pollSCM '* * * * *' }
    parameters {  
                 choice(name: 'maven_goal', choices: ['install','package','clean install'], description: 'build the code')
                 choice(name: 'branch_to_build', choices: ['main', 'dev', 'ppm'], description: 'choose build')
                }
    stages {
        stage ('vcs') {
            steps {
                 git url: 'https://github.com/vikashpudi/spring-petclini.git', 
                 branch: 'main'
              //  sh' git checkout main'
            }
        }
    /*    stage("build & SonarQube analysis") {
            steps {
              sh' echo ***********SONAR SCANING************************'
              withSonarQubeEnv('sonarqube') {
                sh "mvn package sonar:sonar"
              }

            junit testResults: 'target/surefire-reports/*.xml'
            }
          }
          stage("Quality Gate") {
            steps {
              sh' echo ***********QUALITY GATE************************'
              timeout(time: 30, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
              }
            }
          } */

        stage ('Artifactory configuration') {
            steps {
              rtServer (
                  id: 'Artifactory',
                  url: 'https://beatyourlimits.jfrog.io/artifactory/',
                  credentialsId: 'jfrog',
                   bypassProxy: true,
                   timeout: 300
                       )
                sh' echo ***********JFROG CONGIG************************'
                rtMavenDeployer (
                    id: "spc_DEPLOYER",
                    serverId: "Artifactory",
                    releaseRepo: "demo",
                    snapshotRepo: "snapdemo"
                )
            }
        }
     stage ('Exec Maven') {
            steps {
              sh' echo **********SENDING TO ARTIFACTORY************************'
               rtMavenRun (
                    tool: "maven", // Tool name from Jenkins configuration
                     pom: "pom.xml",
                     goals: "install ",
                     deployerId: "spc_DEPLOYER"
                 )
                 
                }
                }
stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "Artifactory"
                )
            }
        }

        stage ('Build docker image') {
            steps {sh 'curl -u "pudivikash:Devops@123456" -X GET https://beatyourlimits.jfrog.io/artifactory/demo/org/springframework/samples/spring-petclinic/2.7.3/spring-petclinic-2.7.3.jar --output spring-petclinic-2.7.3.jar '
               sh "docker image build -t beatyourlimits/spc:${BUILD_ID} ."
            }
        }
        stage ('docker Artifactory configuration') {
            steps {
                rtServer (
                    id: "ARTIFACTORY_SERVER",
                    url: "https://beatyourlimits.jfrog.io/artifactory/api/docker/" ,
                    credentialsId: "jfrog "
                )
            }
        }

         stage ('Push image to Artifactory') {
            steps {
                rtDockerPush(
                    serverId: "ARTIFACTORY_SERVER",
                    image: "docker image build -t beatyourlimits/spc:${BUILD_ID}" ,
                    host: 'tcp://localhost:2375',
                     targetRepo: 'docker-local'
                )
            }
        }

         
    }

}
