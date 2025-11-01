pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                git 'http://github.com/USER/REPO.git'
                // Run Maven Wrapper Commands
                echo 'Building the Project with maven compile'
            }
        }

        stage('Test') {
            steps {
                // Run Maven Wrapper Commands
                echo 'Testing the Project with maven test'
            }
        }

        stage('Package') {
            steps {
                // Run Maven Wrapper Commands
                echo 'Packaging the Project with maven package'
            }
        }

        stage('Containerize') {
            steps {
                // Docker build command
                echo 'Containerize the App with docker'
            }
        }

        stage('Deploy') {
            steps {
                // Docker run command with detached mode
                echo 'Deploy the App with Docker'
            }
        }
    }
}
