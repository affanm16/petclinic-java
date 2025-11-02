# Quick Setup Checklist

## ✅ Pre-Deployment Checklist

### Jenkins Credentials Setup

- [ ] Docker Hub credentials added (ID: `dockerhub-credentials`)
- [ ] EC2 SSH key added (ID: `ec2-ssh-key`)
- [ ] EC2 host address added (ID: `ec2-host`)

### EC2 Instance Configuration

- [ ] EC2 instance launched and running
- [ ] Security group configured:
  - Port 22 (SSH) - from Jenkins IP
  - Port 8081 (Application) - from anywhere or specific IPs
  - Port 3306 (MySQL) - localhost only
- [ ] Docker installed on EC2
- [ ] MySQL installed and database created

### Jenkins Server

- [ ] Docker plugin installed
- [ ] Pipeline plugin installed
- [ ] Jenkins user added to docker group
- [ ] Jenkins service restarted

### Repository Updates

- [ ] Jenkinsfile updated with Docker Hub username
- [ ] Jenkinsfile updated with correct EC2 user (ec2-user or ubuntu)
- [ ] All changes committed and pushed to GitHub

## 🚀 Deployment Commands Quick Reference

### On Jenkins Server

```bash
# Add Jenkins to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Test Docker access
sudo -u jenkins docker ps
```

### On EC2 Instance

```bash
# Install Docker (Amazon Linux)
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install MySQL (Amazon Linux)
sudo yum install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Create Database
sudo mysql
# In MySQL:
CREATE DATABASE pet_clinic;
CREATE USER 'root'@'localhost' IDENTIFIED BY 'Root123$';
GRANT ALL PRIVILEGES ON pet_clinic.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Make deploy script executable
chmod +x deploy.sh

# Verify deployment
docker ps
docker logs petclinic
curl http://localhost:8081/actuator/health
```

### Testing Locally (Before EC2 Deployment)

```bash
# Build and run locally
mvn clean package
docker build -t petclinic-app:test .
docker run -d -p 8081:8081 --name petclinic-test petclinic-app:test

# Check logs
docker logs petclinic-test

# Test application
curl http://localhost:8081/actuator/health

# Cleanup
docker stop petclinic-test
docker rm petclinic-test
```

## 🔧 Jenkins Pipeline Variables to Update

Edit `Jenkinsfile` and change:

```groovy
DOCKER_REGISTRY = "your-dockerhub-username"  // ← Change this
EC2_USER = "ec2-user"  // ← Use "ubuntu" for Ubuntu AMI
```

## 📋 Required Jenkins Credentials

| Credential ID           | Type              | Description                 |
| ----------------------- | ----------------- | --------------------------- |
| `dockerhub-credentials` | Username/Password | Docker Hub login            |
| `ec2-ssh-key`           | SSH Key           | EC2 instance SSH key (.pem) |
| `ec2-host`              | Secret Text       | EC2 public IP/DNS           |

## 🎯 Application URLs After Deployment

- **Application**: `http://<EC2-PUBLIC-IP>:8081`
- **Health Check**: `http://<EC2-PUBLIC-IP>:8081/actuator/health`
- **Owners Page**: `http://<EC2-PUBLIC-IP>:8081/owners`
- **Pets Page**: `http://<EC2-PUBLIC-IP>:8081/pets`
- **Visits Page**: `http://<EC2-PUBLIC-IP>:8081/visits`

## 🐛 Common Issues & Solutions

### Issue: Jenkins can't connect to Docker

**Solution**:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue: SSH to EC2 fails

**Solution**:

- Check security group allows port 22 from Jenkins IP
- Verify SSH key in Jenkins credentials
- Test SSH manually: `ssh -i key.pem ec2-user@<EC2-IP>`

### Issue: Container won't start

**Solution**:

```bash
# On EC2:
docker logs petclinic
# Check if MySQL is running:
sudo systemctl status mysqld
# Restart MySQL if needed:
sudo systemctl restart mysqld
```

### Issue: Port 8081 already in use

**Solution**:

```bash
# On EC2:
docker stop petclinic
docker rm petclinic
# Or check what's using the port:
sudo netstat -tulpn | grep 8081
```

### Issue: Application can't connect to database

**Solution**:

- Verify MySQL is running
- Check database credentials in `application.properties`
- Ensure database `pet_clinic` exists
- Check user permissions in MySQL

## 📊 Monitoring Commands

```bash
# On EC2 - Check container status
docker ps -a

# View logs
docker logs -f petclinic

# Check resource usage
docker stats petclinic

# Check application health
curl http://localhost:8081/actuator/health

# Check MySQL connection
sudo mysql -u root -p
```

## 🔄 Rollback Procedure

If deployment fails:

```bash
# On EC2:
# Stop current container
docker stop petclinic
docker rm petclinic

# Run previous version (replace with actual previous tag)
docker run -d --name petclinic -p 8081:8081 \
  <your-dockerhub-username>/petclinic-app:<previous-build-number>
```

## 📝 Files Modified

✅ Created/Updated:

- `Dockerfile` - Multi-stage build with Java 17
- `Jenkinsfile` - Complete CI/CD pipeline for EC2
- `deploy.sh` - EC2 deployment automation script
- `.dockerignore` - Optimize Docker build
- `JENKINS_SETUP.md` - Comprehensive setup guide
- `DEPLOYMENT_CHECKLIST.md` - This quick reference

## 🎉 Success Criteria

- [ ] Jenkins pipeline runs successfully
- [ ] Docker image built and pushed to registry
- [ ] Application deployed on EC2
- [ ] Health check returns status: UP
- [ ] Application accessible via browser
- [ ] All CRUD operations work (Create/Read/Update/Delete owners, pets, visits)

## 📞 Next Steps After Setup

1. Test the complete pipeline by pushing to GitHub
2. Verify application functionality in browser
3. Set up monitoring and alerts
4. Configure automated backups for database
5. Implement SSL/HTTPS for production
6. Set up proper logging and log aggregation
