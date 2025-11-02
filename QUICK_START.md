# 🚀 Quick Start Guide - Pet Clinic CI/CD

## What You Get

A fully automated pipeline that deploys your Spring Boot app to EC2 **without Docker Hub!**

## Prerequisites Checklist

- [ ] Jenkins server running
- [ ] AWS EC2 instance running
- [ ] EC2 SSH key (.pem file) saved
- [ ] GitHub repository accessible

## 3-Step Setup

### Step 1: Add Jenkins Credentials (5 minutes)

Go to: **Jenkins → Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

#### Credential 1: EC2 SSH Key

```
Kind: SSH Username with private key
ID: ec2-ssh-key
Username: ec2-user (or 'ubuntu' for Ubuntu AMI)
Private Key: [Upload your .pem file]
```

#### Credential 2: EC2 Host

```
Kind: Secret text
Secret: [Your EC2 public IP, e.g., 3.85.123.45]
ID: ec2-host
```

✅ **That's it! No Docker Hub account needed!**

### Step 2: Prepare EC2 (10 minutes)

SSH to your EC2:

```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
```

Run these commands:

```bash
# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install MySQL
sudo yum install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Setup Database
sudo mysql << EOF
CREATE DATABASE pet_clinic;
CREATE USER 'root'@'localhost' IDENTIFIED BY 'Root123$';
GRANT ALL PRIVILEGES ON pet_clinic.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EOF

# Exit and reconnect for docker group to take effect
exit
```

### Step 3: Configure EC2 Security Group (2 minutes)

In AWS Console, add these inbound rules:

| Type       | Port | Source     | Purpose            |
| ---------- | ---- | ---------- | ------------------ |
| SSH        | 22   | Jenkins IP | Jenkins deployment |
| Custom TCP | 8081 | 0.0.0.0/0  | Application access |

## Deploy!

1. **Create Jenkins Pipeline Job:**

   - New Item → Pipeline
   - Name: `petclinic-pipeline`
   - Pipeline from SCM → Git
   - Repo: `https://github.com/affanm16/petclinic-java`
   - Branch: `main`
   - Script path: `Jenkinsfile`
   - Save

2. **Run the Pipeline:**

   - Click "Build Now"
   - Watch the magic happen! ✨

3. **Access Your App:**
   - Open: `http://your-ec2-ip:8081`
   - Health: `http://your-ec2-ip:8081/actuator/health`

## How It Works

```
┌─────────────┐
│   GitHub    │
│ (Your Code) │
└──────┬──────┘
       │ git clone
       ↓
┌─────────────┐
│   Jenkins   │
│             │
│ • Build     │───┐
│ • Test      │   │
│ • Package   │   │
│ • Docker    │   │
└─────────────┘   │
                  │ SCP transfer
                  │ (Docker image as tar.gz)
                  ↓
           ┌─────────────┐
           │  EC2 + SSH  │
           │             │
           │ • Load      │
           │ • Deploy    │
           │ • Run       │
           └─────────────┘
```

**No Docker Hub in the middle! Direct and simple! 🎯**

## What Happens When You Push to GitHub?

1. **Jenkins detects push** (if webhook configured)
2. **Builds your Java app** with Maven
3. **Runs all tests** automatically
4. **Creates Docker image** on Jenkins server
5. **Saves image as compressed file** (tar.gz)
6. **Transfers to EC2** via secure SSH/SCP
7. **Loads image on EC2** from the file
8. **Stops old container** (if running)
9. **Starts new container** with your updated app
10. **Verifies health** automatically

All in **one push!** 🚀

## Troubleshooting

### ❌ "Permission denied" during SSH

**Solution:** Check that Jenkins has the correct SSH key credential

### ❌ Container won't start

**Solution:** Check MySQL is running:

```bash
ssh ec2-user@your-ec2-ip "sudo systemctl status mysqld"
```

### ❌ "Port 8081 already in use"

**Solution:**

```bash
ssh ec2-user@your-ec2-ip "docker stop petclinic; docker rm petclinic"
```

### ❌ Can't access application from browser

**Solution:** Check EC2 security group allows port 8081 from 0.0.0.0/0

## Monitoring Your Deployment

Check container status:

```bash
ssh ec2-user@your-ec2-ip "docker ps"
```

View application logs:

```bash
ssh ec2-user@your-ec2-ip "docker logs -f petclinic"
```

Check health:

```bash
curl http://your-ec2-ip:8081/actuator/health
```

## Cost

- **Jenkins:** Free (open source)
- **EC2:** Pay for instance (t2.micro in free tier)
- **Docker Hub:** **NOT NEEDED** = $0
- **Total Pipeline Cost:** **FREE!** (except EC2 instance) 💰

## Next Steps

### Enable Auto-Deploy on Git Push

Add GitHub webhook:

1. GitHub repo → Settings → Webhooks → Add webhook
2. Payload URL: `http://your-jenkins-url/github-webhook/`
3. Content type: `application/json`
4. Events: Just the push event
5. Save

Now every push triggers automatic deployment! 🎯

### Add Slack Notifications (Optional)

Install Jenkins Slack plugin and get notified of build status!

## Files in This Project

| File            | Purpose               |
| --------------- | --------------------- |
| `Jenkinsfile`   | Pipeline definition   |
| `Dockerfile`    | Container image spec  |
| `deploy.sh`     | EC2 deployment script |
| `pom.xml`       | Maven build config    |
| `.dockerignore` | Build optimization    |

## Support

- 📖 See `JENKINS_SETUP.md` for detailed setup
- ✅ See `DEPLOYMENT_CHECKLIST.md` for quick reference
- 🐛 Check Jenkins console for build errors
- 📊 Check `docker logs petclinic` on EC2 for runtime errors

---

## Success Criteria ✅

After deployment, verify:

- [ ] Jenkins pipeline shows all green stages
- [ ] `http://ec2-ip:8081` shows application
- [ ] `/owners`, `/pets`, `/visits` pages work
- [ ] Can add new owners/pets/visits
- [ ] Health check returns `{"status":"UP"}`

---

**You're deploying to production with just 2 credentials! 🎉**

**No Docker Hub account. No extra services. Just Jenkins → EC2!**
