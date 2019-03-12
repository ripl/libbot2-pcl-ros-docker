pipeline {
  agent any
  environment {
    BASE_IMAGE = "ripl/libbot2-ros:latest"
    BUILD_IMAGE = "ripl/libbot2-pcl-ros:latest"
  }
  stages {
    stage('Update Base Image') {
      steps {
        sh 'docker pull $BASE_IMAGE'
      }
    }
    stage('Build Image') {
      steps {
        sh 'docker build -t $BUILD_IMAGE -f Dockerfile ./'
      }
    }
    stage('Push Image') {
      steps {
        withDockerRegistry(credentialsId: 'DockerHub', url: 'https://index.docker.io/v1/') {
          sh 'docker push $BUILD_IMAGE'
        }
      }
    }
    stage('Clean up') {
      steps {
        sh 'docker rmi $BUILD_IMAGE'
        sh 'docker rmi $BASE_IMAGE'

        cleanWs()
      }
    }
  }
}
