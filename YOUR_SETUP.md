# 🎯 YOUR SETUP - Jenkins Already on EC2

## Perfect News!

Since Jenkins is **already on your EC2**, you have the **SIMPLEST possible setup**!

## What You DON'T Need:

❌ **NO** Docker Hub account  
❌ **NO** Jenkins credentials  
❌ **NO** SSH keys  
❌ **NO** ec2-host credential  
❌ **NO** ec2-ssh-key credential  
❌ **NO** file transfers

## What You DO Need:

✅ MySQL database on the same EC2  
✅ Jenkins user added to docker group  
✅ Port 8081 open in security group

**That's literally it!** 3 things! 🚀

---

## The ONLY Commands You Need to Run

SSH to your EC2 and run these **once**:

```bash
# 1. Let Jenkins use Docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# 2. Install MySQL (if not already installed)
sudo yum install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld

# 3. Create database
sudo mysql << EOF
CREATE DATABASE pet_clinic;
CREATE USER 'root'@'localhost' IDENTIFIED BY 'Root123$';
GRANT ALL PRIVILEGES ON pet_clinic.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EOF
```

**Done with EC2 setup!** ✅

---

## Create Jenkins Pipeline

1. Open Jenkins → New Item
2. Name: `petclinic-pipeline`, Type: Pipeline
3. Pipeline from SCM → Git
4. Repo: `https://github.com/affanm16/petclinic-java`
5. Branch: `main`
6. Save and **Build Now**

**That's it!** 🎉

---

## How Your Pipeline Works

```
Same EC2 Instance:
┌─────────────────────────┐
│  Jenkins                │
│    ↓                    │
│  Builds Docker Image    │
│    ↓                    │
│  Runs Container         │──→ localhost:8081
│    ↓                    │
│  App + MySQL            │
└─────────────────────────┘
```

Everything happens **locally** on the same machine!

---

## Access Your App

After successful build:

- **App**: `http://your-ec2-public-ip:8081`
- **Health**: `http://your-ec2-public-ip:8081/actuator/health`

---

## Files You Should Read

1. **SIMPLE_SETUP.md** ← Start here! Complete guide for your setup
2. **Jenkinsfile** ← Already configured for local deployment
3. **Dockerfile** ← Already optimized

**Ignore these** (they're for remote EC2 deployment):

- ~~JENKINS_SETUP.md~~ (for remote EC2)
- ~~deploy.sh~~ (for remote EC2)

---

## Summary

**Your setup is:** Jenkins → Docker → App (all same EC2)

**You need:**

- MySQL database
- Jenkins can use Docker
- Port 8081 open

**You don't need:**

- Any credentials
- SSH keys
- Docker Hub
- File transfers

**Commands:**

1. Setup MySQL (3 commands above)
2. Create Jenkins pipeline
3. Build!

**Result:** Working app at port 8081! 🚀

---

**Check SIMPLE_SETUP.md for the complete walkthrough!**
