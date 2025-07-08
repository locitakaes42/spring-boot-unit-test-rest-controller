pipeline {
  agent any
  tools {
    maven 'Maven 3.8.8'       
    jdk 'Temurin JDK 17'
  }
 
  environment {
    SONARQUBE_SERVER = 'SonarQube'
    DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials') // ID credentials di Jenkins
    DOCKER_IMAGE_NAME = 'locitakaes/spring-boot-app' // Ganti dengan username Docker Hub Anda
    DOCKER_TAG = "${BUILD_NUMBER}" // Menggunakan build number sebagai tag
  }
 
  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/locitakaes42/spring-boot-unit-test-rest-controller', branch: 'main'
      }
    }
 
    stage('Unit Test & Coverage') {
      steps {
        sh 'mvn package'
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
        }
      }
    }
 
    stage('Static Code Analysis (SAST) via Sonar') {
      steps {
        sh """
            mvn clean compile sonar:sonar \
              -Dsonar.projectKey=test \
              -Dsonar.projectName='test' \
              -Dsonar.host.url=http://sonarqube:9000 \
              -Dsonar.token=sqp_fc2902339e7650bc94ccc1aafdfc1e25da7cfdba
        """
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Build Docker image
          sh """
            docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} .
            docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ${DOCKER_IMAGE_NAME}:latest
          """
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          // Login ke Docker Hub dan push image
          sh """
            echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin
            docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
            docker push ${DOCKER_IMAGE_NAME}:latest
          """
        }
      }
      post {
        always {
          // Logout dari Docker Hub dan cleanup local images
          sh """
            docker logout
            docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} || true
            docker rmi ${DOCKER_IMAGE_NAME}:latest || true
          """
        }
      }
    }
  }
 
  post {
    success {
      echo "Pipeline berhasil 🚀"
      echo "Docker image berhasil di-push ke Docker Hub: ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
    }
    failure {
      echo "Pipeline gagal 💥"
      // Cleanup jika ada kegagalan
      sh """
        docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} || true
        docker rmi ${DOCKER_IMAGE_NAME}:latest || true
      """
    }
  }
}