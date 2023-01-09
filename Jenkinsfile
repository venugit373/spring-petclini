 pipeline {
    agent { label 'NODE1' }
     environment {
        PATH = "$PATH:/usr/share/maven/bin"
    }
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
        stage("build & SonarQube analysis") {
            steps {
              sh' echo ***********SONAR SCANING************************'
              withSonarQubeEnv('sonarqube') {
                sh "mvn ${params.maven_goal} sonar:sonar"
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
          }

        stage ('Artifactory configuration') {
            steps {
              rtServer (
                  id: 'Artifactory',
                  url: 'https://beatyourlimits.jfrog.io/',
                  credentialsId: 'jfrogcred_id',
                   bypassProxy: true,
                   timeout: 300
                       )
                sh' echo ***********JFROG CONGIG************************'
                rtMavenDeployer (
                    id: "spc_DEPLOYER",
                    serverId: "Artifactory",
                    releaseRepo: "pre-libs-release-local",
                    snapshotRepo: "pre-libs-release-local"
                )
            }
        }
       stage ('Exec Maven') {
            steps {
              sh' echo **********SENDING TO ARTIFACTORY************************'
             /*    rtMavenRun (
                    tool: "maven", // Tool name from Jenkins configuration
                     pom: "pom.xml",
                     goals: "clean install ",
                     deployerId: "spc_DEPLOYER"
                 )*/
                sh 'mvn install'
                }
                }
        stage ('Build docker image') {
            steps {
               sh "docker image build -t beatyourlimits/spc:${BUILD_ID} ."
            }
        }
         stage ('Push image to Artifactory') {
            steps {
                rtDockerPush(
                    serverId: "Artifactory",
                    image: "docker image build -t beatyourlimits/spc:${BUILD_ID}" ,
                     targetRepo: 'docker-local'
                )
            }
        }

         stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "ARTIFACTORY_SERVER"
                )
            }
        }
    }

}
