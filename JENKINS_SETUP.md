# Jenkins CI/CD Setup Guide for Pet Clinic Application

This guide will help you set up the complete CI/CD pipeline to deploy the Pet Clinic application to AWS EC2 using Jenkins and Docker.

## Prerequisites

### 1. AWS EC2 Instance Setup

- Launch an EC2 instance (Amazon Linux 2 or Ubuntu)
- Instance type: t2.medium or larger (minimum 2GB RAM)
- Security Group: Open ports 22 (SSH), 8081 (Application), and optionally 3306 (MySQL)
- Save your EC2 SSH key pair (.pem file)

### 2. Jenkins Server Setup

- Jenkins installed and running
- Plugins required:
  - Docker Pipeline
  - Git
  - SSH Agent
  - Credentials Binding
  - Pipeline
  - Blue Ocean (optional, for better UI)

### 3. Docker Hub Account (or AWS ECR)

- Create a Docker Hub account if you don't have one
- Create a repository for your application

## Step-by-Step Configuration

### Step 1: Configure Jenkins Credentials

Go to Jenkins Dashboard → Manage Jenkins → Credentials → System → Global credentials

#### a) Add Docker Hub Credentials

- **Kind**: Username with password
- **Scope**: Global
- **ID**: `dockerhub-credentials`
- **Username**: Your Docker Hub username
- **Password**: Your Docker Hub password or access token
- **Description**: Docker Hub Credentials

#### b) Add EC2 SSH Private Key

- **Kind**: SSH Username with private key
- **Scope**: Global
- **ID**: `ec2-ssh-key`
- **Username**: `ec2-user` (for Amazon Linux) or `ubuntu` (for Ubuntu)
- **Private Key**: Enter directly or upload your .pem file
- **Description**: EC2 SSH Private Key

#### c) Add EC2 Host Address

- **Kind**: Secret text
- **Scope**: Global
- **Secret**: Your EC2 public IP or DNS (e.g., `ec2-xx-xxx-xxx-xxx.compute-1.amazonaws.com`)
- **ID**: `ec2-host`
- **Description**: EC2 Host Address

### Step 2: Update Jenkinsfile

Edit the `Jenkinsfile` and update these variables:

```groovy
DOCKER_REGISTRY = "your-dockerhub-username" // Replace with your Docker Hub username
EC2_USER = "ec2-user" // Change to "ubuntu" if using Ubuntu AMI
```

### Step 3: Prepare EC2 Instance

SSH into your EC2 instance and run these commands:

```bash
# Update system packages
sudo yum update -y  # For Amazon Linux
# OR
sudo apt update && sudo apt upgrade -y  # For Ubuntu

# Install Docker
sudo yum install docker -y  # For Amazon Linux
# OR
sudo apt install docker.io -y  # For Ubuntu

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker ec2-user  # For Amazon Linux
# OR
sudo usermod -aG docker ubuntu  # For Ubuntu

# Install MySQL (optional, if not using external DB)
sudo yum install mysql-server -y  # For Amazon Linux
# OR
sudo apt install mysql-server -y  # For Ubuntu

# Configure MySQL
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Set up MySQL database
sudo mysql
```

In MySQL console:

```sql
CREATE DATABASE pet_clinic;
CREATE USER 'root'@'localhost' IDENTIFIED BY 'Root123$';
GRANT ALL PRIVILEGES ON pet_clinic.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Step 4: Create Jenkins Pipeline Job

1. Go to Jenkins Dashboard → New Item
2. Enter name: `petclinic-pipeline`
3. Select: **Pipeline**
4. Click OK
5. In Pipeline section:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/affanm16/petclinic-java`
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`
6. Save

### Step 5: Configure GitHub Webhook (Optional)

For automatic builds on push:

1. Go to your GitHub repository → Settings → Webhooks
2. Click "Add webhook"
3. **Payload URL**: `http://your-jenkins-url/github-webhook/`
4. **Content type**: application/json
5. **Which events**: Just the push event
6. Click "Add webhook"

### Step 6: Update Application Configuration

If your EC2 MySQL is on a different host, update `application.properties`:

```properties
spring.datasource.url=jdbc:mysql://your-mysql-host:3306/pet_clinic?useSSL=false
spring.datasource.username=your-username
spring.datasource.password=your-password
```

## Running the Pipeline

### Manual Trigger

1. Go to Jenkins Dashboard
2. Click on `petclinic-pipeline`
3. Click "Build Now"

### Automatic Trigger

- Push changes to the `main` branch in GitHub
- Jenkins will automatically start the build

## Pipeline Stages Explained

1. **Checkout**: Clones the repository from GitHub
2. **Build**: Compiles the Java code using Maven
3. **Test**: Runs unit tests and generates reports
4. **Package**: Creates the JAR file
5. **Build Docker Image**: Creates Docker image with build number tag
6. **Push to Registry**: Pushes image to Docker Hub
7. **Deploy to EC2**: Deploys the container on EC2
8. **Health Check**: Verifies the application is running

## Accessing the Application

After successful deployment:

- URL: `http://your-ec2-public-ip:8081`
- Health Check: `http://your-ec2-public-ip:8081/actuator/health`

## Troubleshooting

### Build Fails at Docker Build Stage

- Ensure Docker is installed on Jenkins server
- Add Jenkins user to docker group: `sudo usermod -aG docker jenkins`
- Restart Jenkins: `sudo systemctl restart jenkins`

### SSH Connection Issues

- Verify EC2 security group allows SSH (port 22) from Jenkins server
- Check SSH key permissions: `chmod 400 your-key.pem`
- Verify EC2 instance is running

### Container Fails to Start

- SSH into EC2 and check logs: `docker logs petclinic`
- Verify MySQL is running: `sudo systemctl status mysqld`
- Check database connection in application logs

### Port Already in Use

- Stop existing containers: `docker stop petclinic`
- Remove old containers: `docker rm petclinic`

### Health Check Fails

- Verify application is running: `docker ps`
- Check application logs: `docker logs petclinic`
- Ensure port 8081 is open in EC2 security group

## Security Best Practices

1. **Don't commit sensitive data**: Never commit passwords or keys to Git
2. **Use environment variables**: Store secrets in Jenkins credentials
3. **Restrict EC2 access**: Limit security group rules to specific IPs
4. **Use HTTPS**: Configure SSL/TLS for production
5. **Regular updates**: Keep Docker images and system packages updated
6. **Scan images**: Use Docker image scanning tools for vulnerabilities

## Directory Structure

```
petclinic/
├── Jenkinsfile              # Jenkins pipeline configuration
├── Dockerfile               # Multi-stage Docker build
├── deploy.sh                # EC2 deployment script
├── .dockerignore           # Docker build exclusions
├── pom.xml                  # Maven configuration
└── src/                     # Application source code
```

## Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)

## Support

For issues or questions:

1. Check Jenkins console output for errors
2. Review EC2 instance logs
3. Verify all prerequisites are met
4. Check GitHub repository for updates

---

**Note**: This is a basic setup for demonstration. For production use, consider:

- Using AWS RDS for database
- Implementing proper secrets management (AWS Secrets Manager)
- Setting up load balancers and auto-scaling
- Implementing blue-green or canary deployments
- Adding monitoring and alerting (CloudWatch, Prometheus)
