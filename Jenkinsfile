pipeline {
    agent any

    environment {
        
        DOCKER_IMAGE = "petclinic-app"
        DOCKER_TAG = "latest"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Cloning the repository...'
                git branch: 'main', url: 'https://github.com/affanm16/petclinic-java'
            }
        }

        stage('Build') {
            steps {
                echo 'Building the project using Maven...'
                sh 'chmod +x ./mvnw'
                sh './mvnw clean compile'
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh './mvnw test'
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the application into a JAR...'
                sh './mvnw package -DskipTests'
            }
        }

        stage('Containerize') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Running Docker container...'
                sh '''
                    docker ps -q --filter "name=petclinic" | xargs -r docker stop
                    docker ps -a -q --filter "name=petclinic" | xargs -r docker rm
                    docker run -d --name petclinic -p 8080:8080 ${DOCKER_IMAGE}:${DOCKER_TAG}
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'OOO nooooo.....Pipeline failed! Check Jenkins logs for details.'
        }
    }
}
