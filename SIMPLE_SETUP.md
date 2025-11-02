# 🎯 Super Simple Setup - Jenkins & App on Same EC2

## Your Setup
- ✅ Jenkins installed on EC2
- ✅ Application will run on the same EC2
- ✅ **NO credentials needed!**
- ✅ **NO SSH needed!**
- ✅ **NO Docker Hub needed!**

This is the **simplest possible setup!** 🚀

---

## One-Time EC2 Setup (10 minutes)

SSH into your EC2 where Jenkins is running:

```bash
# 1. Make sure Docker is installed and Jenkins can use it
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
sudo systemctl restart docker

# Wait 2 minutes for Jenkins to restart, then continue...

# 2. Install MySQL
sudo yum install mysql-server -y  # For Amazon Linux
# OR
sudo apt install mysql-server -y  # For Ubuntu

sudo systemctl start mysqld
sudo systemctl enable mysqld

# 3. Create database
sudo mysql << EOF
CREATE DATABASE pet_clinic;
CREATE USER 'root'@'localhost' IDENTIFIED BY 'Root123$';
GRANT ALL PRIVILEGES ON pet_clinic.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EOF

# 4. Configure EC2 Security Group
# In AWS Console, allow inbound traffic on port 8081
```

---

## Create Jenkins Pipeline (2 minutes)

1. Open Jenkins (http://your-ec2-ip:8080)
2. Click **New Item**
3. Name: `petclinic-pipeline`
4. Select: **Pipeline**
5. Scroll to **Pipeline** section:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/affanm16/petclinic-java`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
6. Click **Save**

---

## Deploy!

1. Click **Build Now**
2. Watch the pipeline run
3. Access your app: `http://your-ec2-public-ip:8081`

**That's it!** 🎉

---

## How It Works

```
┌────────────────────────────────────┐
│         Your EC2 Instance          │
│                                    │
│  ┌──────────┐                     │
│  │ Jenkins  │                     │
│  │          │                     │
│  │ • Git    │                     │
│  │ • Maven  │                     │
│  │ • Docker │                     │
│  └────┬─────┘                     │
│       │                            │
│       │ builds & runs              │
│       ↓                            │
│  ┌──────────┐    ┌──────────┐    │
│  │  Docker  │───→│  MySQL   │    │
│  │Container │    │ Database │    │
│  │(App:8081)│    │          │    │
│  └──────────┘    └──────────┘    │
│                                    │
└────────────────────────────────────┘
         ↑
         │ Access from browser
         │
    http://ec2-ip:8081
```

Everything runs **locally** on the same EC2! No SSH, no file transfers, no registry!

---

## What the Pipeline Does

1. ✅ **Checkout** - Gets code from GitHub
2. ✅ **Build** - Compiles Java code with Maven
3. ✅ **Test** - Runs unit tests
4. ✅ **Package** - Creates JAR file
5. ✅ **Build Docker Image** - Creates container image
6. ✅ **Deploy Container** - Stops old, runs new container
7. ✅ **Health Check** - Verifies app is running

All happening on the **same machine** where Jenkins runs!

---

## Verify Installation

After building, check:

```bash
# On your EC2:

# Check if container is running
docker ps

# View app logs
docker logs petclinic

# Test health endpoint
curl http://localhost:8081/actuator/health

# Should return: {"status":"UP"}
```

---

## Accessing Your Application

From your browser:
- **Main App**: `http://your-ec2-public-ip:8081`
- **Owners**: `http://your-ec2-public-ip:8081/owners`
- **Pets**: `http://your-ec2-public-ip:8081/pets`
- **Visits**: `http://your-ec2-public-ip:8081/visits`
- **Health**: `http://your-ec2-public-ip:8081/actuator/health`

---

## Troubleshooting

### Jenkins can't access Docker
```bash
# Run on EC2:
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Container fails to start
```bash
# Check if MySQL is running:
sudo systemctl status mysqld

# Check container logs:
docker logs petclinic

# Restart MySQL if needed:
sudo systemctl restart mysqld
```

### Port 8081 not accessible
- Check EC2 Security Group allows inbound on port 8081
- Check if container is running: `docker ps`

### Database connection error
```bash
# Verify database exists:
sudo mysql -e "SHOW DATABASES;"

# Recreate if needed:
sudo mysql << EOF
CREATE DATABASE IF NOT EXISTS pet_clinic;
GRANT ALL PRIVILEGES ON pet_clinic.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EOF
```

---

## Auto-Deploy on Git Push (Optional)

### Enable GitHub Webhook:

1. Go to GitHub repo → Settings → Webhooks
2. Add webhook:
   - Payload URL: `http://your-ec2-public-ip:8080/github-webhook/`
   - Content type: `application/json`
   - Events: Just the push event
3. Save

Now every push to `main` triggers automatic build and deployment! 🚀

### Configure Jenkins:

1. Your pipeline → Configure
2. Build Triggers → Check "GitHub hook trigger for GITScm polling"
3. Save

---

## Resources Needed

| Resource | Usage |
|----------|-------|
| **RAM** | ~2GB (Jenkins + App + MySQL) |
| **Disk** | ~5GB (OS + Tools + Docker images) |
| **Instance** | t2.medium recommended |
| **Ports** | 8080 (Jenkins), 8081 (App) |

---

## Quick Commands

```bash
# View running container
docker ps -f name=petclinic

# View logs
docker logs -f petclinic

# Restart container
docker restart petclinic

# Stop container
docker stop petclinic

# Remove container
docker rm petclinic

# Check disk usage
docker system df

# Clean up old images
docker image prune -a
```

---

## Benefits of This Setup

✅ **Simplest possible** - No external services  
✅ **Zero credentials** - No SSH keys, no Docker Hub  
✅ **Fast deployment** - Everything local  
✅ **Low cost** - Single EC2 instance  
✅ **Easy debugging** - All logs in one place  
✅ **Perfect for** - Development, testing, small projects  

---

## What You DON'T Need

❌ Docker Hub account  
❌ Jenkins credentials  
❌ SSH keys  
❌ deploy.sh script  
❌ Multiple servers  
❌ Complex networking  

**It's all on one machine!** 🎯

---

## Success Checklist

After first deployment:

- [ ] Pipeline shows all green stages
- [ ] `docker ps` shows petclinic container running
- [ ] `curl http://localhost:8081/actuator/health` returns `UP`
- [ ] Browser shows app at `http://ec2-ip:8081`
- [ ] Can view owners/pets/visits pages
- [ ] Can add new data through forms

---

## Next Steps

1. ✅ Setup MySQL database
2. ✅ Add Jenkins user to docker group
3. ✅ Create Jenkins pipeline
4. ✅ Build and deploy
5. ✅ Set up GitHub webhook (optional)
6. 🎉 **Done!**

---

**This is the EASIEST CI/CD setup possible!** 🚀

**Everything on one EC2. Zero external dependencies. Just push and deploy!**
