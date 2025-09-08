**Last Updated: 8 Sep 2025**

# VPS Setup Instructions for Halo CE / Halo PC

This is a step-by-step tutorial for installing an **Ubuntu 22.04 LTS** VPS with **Wine** and a secured **VNC server** to host a Halo Custom Edition or Combat Evolved (PC) dedicated server.

## Target OS: Ubuntu 22.04 LTS (Jammy Jellyfish) x64

**Note on Compatibility**: While these instructions are specifically written and tested for **Ubuntu 22.04 LTS x64**, the core process (using Wine, VNC, and UFW) is similar for other versions. However, repository links (especially for Wine) and package names may differ significantly on other Ubuntu versions or different Linux distributions (like Debian or CentOS). For the most reliable results, it is strongly recommended to use Ubuntu 22.04 LTS.

---

## Prerequisite Applications

| Application                                                                                     | Description                                                  |
|:------------------------------------------------------------------------------------------------|:-------------------------------------------------------------|
| [BitVise SSH Client](https://www.bitvise.com/ssh-client-download)                               | For secure remote terminal access and file uploads via SFTP. |
| [TightVNC Viewer](https://www.tightvnc.com/download.php)                                        | For remote desktop connections to the VPS GUI.               |
| [HPC/CE Server Template](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/ReadyToGo) | Pre-configured server files compatible with Linux/Wine.      |

### ⚠️ Important Notes Before You Begin

- **Security First:** This guide prioritizes security by creating a non-root user, using a firewall, and locking down
  remote access. Please follow these steps carefully.
- **Cost:** Vultr charges hourly up to a monthly cap. A server with 1 vCPU and 1GB RAM (the $6/mo plan) is sufficient
  for most needs. You can destroy the VPS at any time to stop charges.
- **Your Home IP:** Some steps require your home public IP address. Google "what is my ip" to find it. Note that this
  may change if your internet provider does not assign a static IP.

---

## Steps

### 1. Download and Prepare the Server Template

1. Download the [HPC_Server.zip or HCE_Server.zip](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/ReadyToGo) file.
2. Extract the ZIP file on your local computer using 7-Zip or WinRAR. You should have a folder named `HPC_Server` or `HCE_Server`. Keep this handy for later.

### 2. Deploying a New VPS on Vultr

1. Navigate to the [Vultr Deploy](https://my.vultr.com/deploy/) page.
2. Select **Cloud Compute**.
3. Choose a server location closest to you and your players.
4. Under **Server Type**, select **Ubuntu 22.04 LTS x64**.
5. Select a plan (e.g., **$6/mo** for 1 vCPU, 1GB RAM).
6. (**Recommended**) Under **SSH Keys**, add your public SSH key for more secure authentication. If you don't know how, you can use the password method shown later.
7. Give your server a hostname label (e.g., `halo-server`).
8. Click **Deploy Now**. Wait a few minutes for it to install.

### 3. Initial Connection & User Setup via BitVise

1. From your Vultr control panel, note the server's **IP Address**, **Password** (if you didn't use an SSH key), and username (`root`).
2. Open BitVise SSH Client.
3. Enter the IP address under **Host**.
4. For **Username**, enter `root`.
5. For **Authentication**, select `password` and paste the server's password.
6. Click **Login**. Accept the host key.
7. Once connected, click the **New Terminal Console** button.

**We will now create a new user instead of running everything as root:**

```bash
# Create a new user named 'haloadmin' (you can change this)
adduser haloadmin
# Follow the prompts to set a strong password for this user.

# Add the new user to the 'sudo' group to grant administrative privileges
usermod -aG sudo haloadmin

# Verify the user was added correctly
grep sudo /etc/group
# You should see 'haloadmin' in the output, e.g., 'sudo:x:27:ubuntu,haloadmin'

# Switch to the new user's environment USING A LOGIN SHELL (the '-' is important)
su - haloadmin
```

*Your terminal prompt should now show `haloadmin@your-server-name` instead of `root@your-server-name`.*

### 4. Install Wine

Run these commands in the SSH terminal to install Wine. These are correct for Ubuntu 22.04 LTS.

```bash
# Enable 32-bit architecture
# You may be asked for your haloadmin password, enter it when prompted.
sudo dpkg --add-architecture i386

# Create the keyring directory and download the WineHQ key
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

# Add the WineHQ repository for Ubuntu 22.04 LTS (Jammy)
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources

# Update the package list
sudo apt update

# --- IMPORTANT: Check for and Install System Upgrades ---
# It's good practice to apply any available OS updates before installing new software.
# Check for upgradable packages (this is informational, you can run it to see what's available)
apt list --upgradable

# Apply all available updates. This ensures your system has the latest security patches.
sudo apt upgrade -y

# --- Proceed with Wine Installation ---
# Install Wine
sudo apt install --install-recommends winehq-stable -y

# Verify the installation (it will likely prompt to install Mono, just close the window for now)
wine --version
```

### 5. Install and Configure TightVNC & XFCE

Install the desktop environment and VNC server.

```bash
# Install the required packages
sudo apt install xfce4 xfce4-goodies tightvncserver -y

# Start the VNC server for the first time to create its config files
vncserver
# You will be prompted to create a VNC password (max 8 characters).
# Then, you can choose to create a view-only password (select 'n' for no).
# "View-only password" means a separate password that allows someone to see your desktop but not interact with it. They cannot click, type, or move the mouse. It's like a "read-only" mode for your screen.

# Now, stop the VNC server instance
vncserver -kill :1
```

Back up the existing configuration file and then modify it to start XFCE.

```bash
# Backup the original xstartup file
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak

# Create a new xstartup file and open it for editing
nano ~/.vnc/xstartup
```

**Paste the following exact lines into the nano editor:**

```bash
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
```

**To save and exit nano:** Press `CTRL+O`, then `ENTER`, then `CTRL+X`.

Make the script executable:

```bash
chmod +x ~/.vnc/xstartup
```

### 6. Create a Systemd Service for VNC (Auto-start on boot)

Create a service file to manage VNC. The `-localhost` flag is used for maximum security, meaning VNC will only accept connections from the machine itself. We will later configure the firewall to securely forward our external connection.

```bash
sudo nano /etc/systemd/system/vncserver@.service
```

**Paste the following configuration into the file.**
> ⚠️ Don't forget to edit the file to replace `haloadmin` with your actual username.

```ini
[Unit]
Description = TightVNC Remote Desktop Service
After = syslog.target network.target

[Service]
Type = forking
User = haloadmin
Group = haloadmin
WorkingDirectory = /home/haloadmin
PIDFile = /home/haloadmin/.vnc/%H:%i.pid
ExecStartPre = -/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart = /usr/bin/vncserver -depth 24 -geometry 1280x720 -localhost :%i
ExecStop = /usr/bin/vncserver -kill :%i

[Install]
WantedBy = multi-user.target
```

**Save and exit nano (`CTRL+O`, `ENTER`, `CTRL+X`).**

Reload systemd and enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1.service
```

### 7. Configure the Firewall (UFW) for Security and VNC Access

Configure the firewall to only allow essential ports. **Replace `YOUR_HOME_IP` with your actual public IP address.**

This step is **CRITICAL**. We will configure the firewall to forward connections from your IP to the VNC server, which is locked down to localhost.

```bash
# Enable SSH connections
sudo ufw allow OpenSSH

# Allow Halo game connections (UDP)
sudo ufw allow 2302:2303/udp

# Allow Halo server list (heartbeat) ports if needed (UDP)
sudo ufw allow 2304:2313/udp

# --- Configure Secure VNC Access via Port Forwarding ---
# 1. Enable IP forwarding and add NAT rule for UFW
sudo nano /etc/ufw/before.rules

# 2. Add the following lines AT THE TOP OF THE FILE, *ABOVE* the line that says '*filter'
# Replace YOUR_HOME_IP with your actual public IP address.
*nat
:PREROUTING ACCEPT [0:0]
-A PREROUTING -p tcp -s YOUR_HOME_IP --dport 5901 -j REDIRECT --to-port 5901
COMMIT

# 3. Save and exit the file (CTRL+O, ENTER, CTRL+X)

# 4. Enable IP forwarding in the UFW configuration
sudo nano /etc/ufw/sysctl.conf
# Find and uncomment (remove the # from) this line:
# net/ipv4/ip_forward=1
# Save and exit the file.

# 5. Add a firewall rule to ACCEPT the forwarded VNC traffic on the internal interface
sudo ufw allow in on lo from YOUR_HOME_IP to any port 5901 proto tcp

# Enable the firewall and deny all other incoming traffic by default
sudo ufw enable
# Type 'y' and press ENTER to confirm.

# 6. Reload UFW to apply all the complex routing rules we just added
sudo ufw reload
```

### 8. (Optional but Recommended) Harden SSH Security

```bash
# Change the default SSH port to reduce bot noise
sudo nano /etc/ssh/sshd_config
```

Find the line `#Port 22`, uncomment it, and change it to a number between 1024 and 65535 (e.g., `Port 22992`).
**Save and exit nano.**

```bash
# Install and enable fail2ban to block brute force attacks
sudo apt install fail2ban -y
sudo systemctl enable fail2ban

# Allow the new SSH port in the firewall.
sudo ufw allow 22992/tcp

# IMPORTANT: Restart the SSH service for changes to take effect.
# Do NOT close your BitVise window yet! Open a NEW BitVise session
# and test connecting to the NEW PORT before closing this one.
sudo systemctl restart sshd
```

**⚠️ Warning:** After this, you must specify the new port (e.g., `22992`) in the Port field in BitVise for all future
connections.

### 9. Upload Server Files via BitVise SFTP

1. In your existing BitVise session, click the **New SFTP Window** button.
2. In the SFTP window, navigate to the `/home/haloadmin/` directory.
3. On your local computer, locate the extracted `HPC_Server` or `HCE_Server` folder.
4. Drag and drop the entire server folder from your local machine into the `/home/haloadmin/` directory on the VPS. This may take a few minutes.

### 10. Final Setup via VNC Desktop

1. Open **TightVNC Viewer** on your PC.
2. Connect to `your.vps.ip.address:5901`.
3. Enter the VNC password you created earlier.
4. You should now see the XFCE desktop environment.
5. Use the file manager to navigate to the server folder you uploaded (e.g., `HPC_Server`).
6. Inside, find the `Wine Launch Files` folder and double-click the `run.desktop` file.
7. The first time you run it, Wine will prompt you to install Mono. **Click "Install"** and allow it to complete. The server console window should open once finished.
8. You can now configure your server by editing the `server.cfg` file in the main server directory.

Your server should now be running and accessible to players. You can manage it via the VNC desktop. The VNC service will automatically restart if your VPS reboots.

---

Of course. Here is the new section, written to match the professional tone and structure of your existing guide. It has been integrated as a new step between your current Step 10 and Step 11.

---

### 11. (Optional) Create a Desktop Shortcut for Your Server

For ease of use when connected via VNC or X2Go, you can create a desktop shortcut to launch your Halo server with a double-click. This example will create a shortcut for a server named "divide_and_conquer" - replace this name with your actual server's directory name.

1.  **Open a Terminal** from your remote desktop (Applications > System Tools > Terminal) or via your existing BitVise SSH session (logged in as `haloadmin`).

2.  **Create a launch script.** This script will navigate to your server directory and start the dedicated server with Wine. Replace `divide_and_conquer` with your server's folder name and adjust the `-port` number if necessary.

```bash
sudo nano /home/haloadmin/HCE_Server/divide_and_conquer.sh
```

**Paste the following contents into the file.**
> ⚠️ **Important:** Double-check that the paths (`-path`, `-exec`) and `-port` number match your server's configuration.

```bash
#!/bin/bash
cd "/home/haloadmin/HCE_Server"
wine haloceded.exe -path "cg/divide_and_conquer" -exec "cg/divide_and_conquer/init.txt" -port 2304
```

**Save and exit nano (`CTRL+O`, `ENTER`, `CTRL+X`).**

Make the script executable:

```bash
sudo chmod +x /home/haloadmin/HCE_Server/divide_and_conquer.sh
```

3. **Create the desktop shortcut file.**

```bash
sudo nano /home/haloadmin/Desktop/divide_and_conquer.desktop
```

**Paste the following configuration into the file.** Edit the `Name` and `Exec` lines to match your server.

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Divide and Conquer Server
Exec=/home/haloadmin/HCE_Server/divide_and_conquer.sh
Icon=utilities-terminal
Categories=Game;
```

**Save and exit nano.**

Make the desktop file executable:

```bash
sudo chmod +x /home/haloadmin/Desktop/divide_and_conquer.desktop
```

4. **Using the Shortcut:** You should now see a new icon on your VPS desktop. The first time you double-click it, you will likely be prompted by Wine to **install Mono**. Click "Install" and allow it to complete. Once installed, the server console window will open. Subsequent double-clicks will launch the server directly.

**You can now launch your server directly from the desktop.**

---

### 12. (Optional, Recommended Upgrade) Install X2Go for a Superior Remote Desktop

TightVNC works but can be laggy. **X2Go** uses a more efficient protocol, offering a much faster and more responsive remote desktop experience. It also allows you to disconnect and reconnect to your running desktop session.

**Prerequisite:** Download and install the [X2Go Client](https://wiki.x2go.org/doku.php/doc:installation:x2goclient) on your Windows PC.

**On the VPS (via BitVise SSH):**

```bash
# Install the X2Go server and the XFCE session module
sudo apt install x2goserver x2goserver-xsession -y

# The XFCE desktop you installed earlier is the perfect match for X2Go.
# No further configuration is needed on the server.
```

**On Your Windows PC:**

1.  Open the **X2Go Client**.
2.  Create a new session:
    *   **Session Name:** `Halo Server`
    *   **Host:** Your VPS's IP address
    *   **Login:** `haloadmin`
    *   **SSH Port:** `22` (or your custom port if you changed it in Step 8)
    *   **Session Type:** `XFCE`
3.  Click **OK** to save the session.
4.  Select the new session and click **Session** -> **Start**. You will be prompted for your `haloadmin` user's password (or your SSH key if you set one up).
5.  You will now be connected to a much smoother and more responsive desktop.

**⚠️ Important Security Note:** X2Go uses your existing SSH connection for secure tunneling. Once you verify X2Go works, you can **remove the VNC firewall rules** for increased security, as you will no longer need them:

```bash
# Delete the rule allowing VNC on the loopback interface
sudo ufw delete allow in on lo from YOUR_HOME_IP to any port 5901 proto tcp
# Remove the NAT rule by deleting the lines you added to /etc/ufw/before.rules and reloading UFW.
# You can also stop and disable the VNC service if you wish:
sudo systemctl stop vncserver@1.service
sudo systemctl disable vncserver@1.service
```