pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "petclinic-app"
        DOCKER_TAG = "${BUILD_NUMBER}"
        CONTAINER_NAME = "petclinic"
        APP_PORT = "8081"
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning the repository...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building the project using Maven...'
                sh 'mvn clean compile'  
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh 'mvn test'  
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the application into a JAR...'
                sh 'mvn package -DskipTests'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Deploy Container') {
            steps {
                echo 'Deploying container locally...'
                script {
                    // Stop and remove existing container if running
                    sh """
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    """
                    
                    // Run new container (using H2 in-memory database - no DB setup needed!)
                    sh """
                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            --restart unless-stopped \
                            -p ${APP_PORT}:${APP_PORT} \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                script {
                    sh '''
                        for i in {1..10}; do 
                            curl -f http://localhost:8081/actuator/health && break || sleep 10
                        done
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline executed successfully!'
            echo 'Application is now running!'
            echo 'Access at: http://<your-ec2-public-ip>:8081'
            sh 'docker ps -f name=${CONTAINER_NAME}'
        }
        failure {
            echo '❌ Pipeline failed! Check Jenkins logs for details.'
            sh 'docker logs ${CONTAINER_NAME} || true'
        }
        always {
            // Clean up old images (keep last 3 builds)
            sh '''
                docker images ${DOCKER_IMAGE} --format "{{.Tag}}" | sort -rn | tail -n +4 | xargs -r -I {} docker rmi ${DOCKER_IMAGE}:{} || true
            '''
        }
    }
}
