# ☕ Java 17 Setup for Jenkins

## Problem

Your Jenkins is using an older Java version (probably Java 8 or 11) but this application requires **Java 17**.

**Error Message:**
```
[ERROR] Fatal error compiling: error: release version 17 not supported
```

---

## Solution: Install Java 17 on EC2 and Configure Jenkins

### Option 1: Quick Setup (Recommended for Amazon Linux 2023 / Ubuntu)

#### Step 1: Install Java 17 on your EC2

**For Amazon Linux 2023:**
```bash
sudo dnf install java-17-amazon-corretto-devel -y
```

**For Amazon Linux 2:**
```bash
sudo amazon-linux-extras install java-openjdk17 -y
```

**For Ubuntu:**
```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
```

#### Step 2: Verify Installation
```bash
java -version
# Should show: openjdk version "17.x.x"

# Find Java 17 installation path
sudo update-alternatives --config java
# Or
readlink -f $(which java) | sed 's:/bin/java::'
```

You should see something like:
- `/usr/lib/jvm/java-17-amazon-corretto` (Amazon Corretto)
- `/usr/lib/jvm/java-17-openjdk-amd64` (Ubuntu)
- `/usr/lib/jvm/java-17-openjdk` (Amazon Linux 2)

#### Step 3: Configure Java 17 in Jenkins

1. **Go to Jenkins Dashboard**
   - Navigate to: **Manage Jenkins** → **Global Tool Configuration**

2. **Add JDK Installation**
   - Scroll to **JDK** section
   - Click **Add JDK**
   - Configure:
     - **Name**: `Java17` (exactly as written in Jenkinsfile!)
     - **Uncheck** "Install automatically"
     - **JAVA_HOME**: Enter the path from Step 2
       - Example: `/usr/lib/jvm/java-17-amazon-corretto`
       - Example: `/usr/lib/jvm/java-17-openjdk-amd64`
   - Click **Save**

3. **Restart Jenkins (if needed)**
   ```bash
   sudo systemctl restart jenkins
   ```

#### Step 4: Build Again
- Go back to your pipeline
- Click **"Build Now"**
- It should work now! ✅

---

## Option 2: Let Jenkins Install Java 17 Automatically

If you prefer Jenkins to manage Java installation:

1. **Go to Jenkins**: **Manage Jenkins** → **Global Tool Configuration**
2. **JDK Section** → **Add JDK**
3. Configure:
   - **Name**: `Java17`
   - **Check** "Install automatically"
   - Click **Add Installer** → Select **Install from adoptium.net**
   - **Version**: Select `jdk-17.0.x+y` (latest 17.x version)
4. Click **Save**
5. **Build again** - Jenkins will download and install Java 17 automatically

---

## Verify Setup

After configuration, check if Java 17 is being used:

1. Run your pipeline
2. In the **Build** stage output, you should see:
   ```
   openjdk version "17.0.x"
   ```

---

## Troubleshooting

### Issue 1: "Tool type 'jdk' does not have an install of 'Java17'"

**Solution:** The name in Jenkinsfile must EXACTLY match the name in Jenkins configuration.

In **Global Tool Configuration**:
- JDK Name: `Java17` ← Must be exactly this

In **Jenkinsfile** (already configured):
```groovy
tools {
    jdk 'Java17'
}
```

### Issue 2: Jenkins still using wrong Java version

**Check Jenkins system Java:**
```bash
# SSH to EC2
sudo -u jenkins java -version
```

If it shows Java 8/11, the JDK configuration in Jenkins will override it for builds.

### Issue 3: Permission denied on Java path

**Fix permissions:**
```bash
# Make sure Jenkins can access Java
sudo chmod -R 755 /usr/lib/jvm/java-17-*
```

---

## Quick Reference

### Check Java versions on EC2:
```bash
# All installed Java versions
sudo update-alternatives --config java

# Current default Java
java -version

# Java as Jenkins user
sudo -u jenkins java -version
```

### Java Installation Paths by OS:

| OS | Typical Java 17 Path |
|---|---|
| Amazon Linux 2023 | `/usr/lib/jvm/java-17-amazon-corretto` |
| Amazon Linux 2 | `/usr/lib/jvm/java-17-openjdk` |
| Ubuntu | `/usr/lib/jvm/java-17-openjdk-amd64` |
| RHEL/CentOS | `/usr/lib/jvm/java-17-openjdk-17.x.x` |

---

## Summary

✅ **Two Ways to Fix:**

1. **Manual Install (Recommended)**:
   - Install Java 17 on EC2
   - Configure path in Jenkins Global Tool Configuration
   - Name it exactly `Java17`

2. **Automatic Install**:
   - Let Jenkins download and install Java 17
   - Configure in Global Tool Configuration
   - Name it exactly `Java17`

🚀 **After setup**: Build your pipeline again, it should compile successfully!

---

## Next Steps After Java Setup

1. ✅ Configure Java 17 in Jenkins (follow steps above)
2. ✅ Run pipeline again - Build should succeed
3. ✅ Application will deploy with H2 database
4. ✅ Access at: `http://your-ec2-ip:8081`

**No database setup needed!** H2 runs automatically. 🎉
