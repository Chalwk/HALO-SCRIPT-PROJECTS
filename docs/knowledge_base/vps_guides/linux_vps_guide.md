**Last Updated: 10 Sep 2025**

# VPS Setup Instructions for Halo CE / Halo PC

This is a step-by-step tutorial for installing an **Ubuntu 22.04 LTS** VPS with **Wine** and a secured **VNC server** to
host a Halo Custom Edition or Combat Evolved (PC) dedicated server.

**NOTE** This guide will take you an estimated ~35 minutes to an hour (for a non-Linux user) to complete.

---

## Target OS: Ubuntu 22.04 LTS (Jammy Jellyfish) x64

**Note on Compatibility**: While these instructions are specifically written and tested for **Ubuntu 22.04 LTS x64**,
the core process (using Wine, VNC, and UFW) is similar for other versions. However, repository links (especially for
Wine) and package names may differ significantly on other Ubuntu versions or different Linux distributions (like Debian
or CentOS). For the most reliable results, it is strongly recommended to use Ubuntu 22.04 LTS.

---

## Prerequisites

| Application                                                                                     | Description                                                  |
|:------------------------------------------------------------------------------------------------|:-------------------------------------------------------------|
| [BitVise SSH Client](https://www.bitvise.com/ssh-client-download)                               | For secure remote terminal access and file uploads via SFTP. |
| [TightVNC Viewer](https://www.tightvnc.com/download.php)                                        | For remote desktop connections to the VPS GUI.               |
| [HPC/CE Server Template](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/ReadyToGo) | Pre-configured server files compatible with Linux/Wine.      |

### Important Notes Before You Begin

- **Security First:** This guide prioritizes security by creating a non-root user, using a firewall, and locking down
  remote access. Please follow these steps carefully.
- **Cost:** Vultr charges hourly up to a monthly cap. A `Shared CPU` plan, with 1 vCPU and 2GB RAM (the **\$10/mo
  plan**) is sufficient for most needs. You can destroy the VPS at any time to stop charges. As of 8/9/2025, the ideal (
  **Shared CPU**) plan is `vc2-1c-2gb | 1 vCPU | 2GB RAM | 55 GB SSD | 2TB/mo Bandwidth` @ **\$10.00/mo** (not including
  Automatic Backups, which are an extra $2.00)

---

## Steps

### 1. Download and Prepare the Server Template

1. Download:
    * [HPC_Server.zip](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/download/ReadyToGo/HPC_Server.zip)
      **or**
    * [HCE_Server.zip](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/download/ReadyToGo/HCE_Server.zip)
2. Extract the ZIP file on your local computer using preferred extraction method. You should have a folder named
   `HPC_Server` or `HCE_Server`. Keep this handy for later.

---

### 2. Deploying a New VPS on Vultr

**Note:** This guide assumes your VPS has a static public IP address. Your home IP address is irrelevant for the
server's availability.

1. Navigate to the [Vultr Deploy](https://my.vultr.com/deploy/) page.
2. Select **Shared CPU**.
3. Choose a location (e.g., `New York (NJ), US`).
4. Select your subscription plan (see [Important Notes Before You Begin](#important-notes-before-you-begin) for cost and
   hardware recommendations).
5. Click `Configure Software` and select **Ubuntu 22.04 LTS x64**.
6. Give your server a hostname label (e.g., `halo-server`).
7. Click **Deploy Now**. Wait a few minutes for it to install.
8. From the instance overview page, note the server's **IP Address**, **Password** and **Username** (`root`).

---

### 3. Initial Connection & User Setup via BitVise

This guide requires SSH key authentication (password login will be disabled later).
> This will be the only time you use password login.

1. Open BitVise SSH Client.
2. Fill in the `Host` and `Username`.
3. Set **Initial Method** to `password` and *tick* `Store encrypted password in profile`. Now fill in the password
   mentioned in previous step.
4. Go to the **Client key manager** (from the login tab)
5. Click **Generate New**.
    * **Algorithm:** `ed25519` (recommended).
    * Leave passphrase blank unless you want to type it every login.
    * Click **Generate**
6. Highlight your new key and click **Export** (the **Export Public or Private Key** window will open):
    * Select **Export Public Key**
    * Select **OpenSSH format**
    * Click **Export**
    * Save to a location you can find later, (e.g., `C:\Users\YourUsername\Desktop\halo-server-key.pub`)
7. Go to the **Login** tab and log in as `root`.

> **Note**: If you see a warning about the host key, this is normal for a new server. Verify the fingerprint matches the
> one shown in your Vultr control panel under the 'Overview' tab, then accept it.

8. Click the **New Terminal Console** button.

**We will now create a new user (`haloadmin`) instead of running everything as root:**

```bash
# Create a new user named 'haloadmin' (you can change this)
sudo adduser haloadmin
# Follow the prompts to set a strong password for this user.
# Leave "Full Name, Room Number, Work Phone, Home Phone, and other fields blank.
# Type "y" and press ENTER to confirm.

# Add the new user to the 'sudo' group to grant administrative privileges
usermod -aG sudo haloadmin

# Verify the user was added correctly
grep sudo /etc/group
# You should see something like, "sudo:x:27:ubuntu,haloadmin"
```

**Upload the Key to Your VPS:**

* Create the `.ssh` folder and file for your new user:

```bash
mkdir -p /home/haloadmin/.ssh
nano /home/haloadmin/.ssh/authorized_keys
```

* Locate the `halo-server-key.pub` file you exported earlier.
* Open it in a text editor (e.g., Notepad).
* Copy the public key (it should be a single line starting with `ssh-ed25519 AAAA...`).
* Paste it into the `authorized_keys` file.
* Save and exit (Press `CTRL+S`, then `CTRL+X`).
* Now we need to **Fix permissions** (critical):

```bash
chmod 700 /home/haloadmin/.ssh
chmod 600 /home/haloadmin/.ssh/authorized_keys
chown -R haloadmin:haloadmin /home/haloadmin/.ssh
```

Close the terminal console.

**Test Key Login in BitVise:**

* Go to the **Login** tab.
* Log out of the `root` session and log in as `haloadmin`.
* Set **Initial Method** to `publickey`
* Select your generated key (Global 1) under **Client key**
* Click **Log in**

> Only proceed once key login works.

* Click the **New Terminal Console** button. *Your terminal prompt should now show `haloadmin@your-server-name` instead
  of `root@your-server-name`.*

---

### 4. Harden SSH Access and Configure the Firewall (UFW)

This step changes the SSH port, sets the Halo server port, disables root login, and configures the firewall. **It is
crucial to follow this order to avoid locking yourself out.**

```bash
# Edit the SSH server configuration file
sudo nano /etc/ssh/sshd_config
# Enter the password for the "haloadmin" user when prompted
```

Find and change the following lines:

```
#Port 22 -> Uncomment and change the number (e.g., Port 22992)
Port 22992

#PermitRootLogin yes -> Change to 'no'
PermitRootLogin no

# For maximum security, disable password authentication.
# ONLY do this if you have already added your SSH public key to /home/haloadmin/.ssh/authorized_keys
#PasswordAuthentication yes -> Change to 'no'
PasswordAuthentication no
```

**Save and exit nano (Press `CTRL+S`, then `CTRL+X`).**

> WARNING: DO NOT LOG OUT OR CLOSE THIS TERMINAL WINDOW YET UNTIL YOU RESTART SSH (see below)

**Before restarting SSH**, we must configure the firewall (UFW) to allow connections on your new custom port and the
Halo server port. If you restart SSH first, you will be locked out.

**Small technical note:** Since the VPS is a **public internet server** (not LAN), and we're not running the Halo client
on the same machine, **TCP 2303 is not required**. The UFW rule allowing UDP 2302 is sufficient. If you were installing
a Halo PC/CE server on your local machine, you would need to allow TCP 2303 as well.

```bash
# Enable SSH connections on your new custom port
sudo ufw allow 22992/tcp comment 'Custom SSH Port'

# Allow the Halo Server Port:
# This is the port players will use to connect to your Halo server.
# Default is 2302. Change if needed.
sudo ufw allow 2302/udp comment 'Halo Server Port'

# Enable the firewall. It will deny all other incoming traffic by default.
sudo ufw enable
# Type 'y' and press ENTER to confirm.

# Verify the rule was added correctly
sudo ufw status verbose
# You should see lines allowing '22992/tcp' for SSH and '2302/udp' for Halo Server,
# along with the default rules that deny other incoming connections.
```

**NOW You Can Restart SSH**

```bash
# Restart the SSH service for changes to take effect.
sudo systemctl restart sshd
```

**Test the New SSH Port:**

1. Open a **new instance** of BitVise SSH Client.
2. Fill in the **Host** (your server IP) and the new Port (`22992`).
3. Set the Username to `haloadmin`.
4. Set Initial Method to `publickey` and select your key.
5. Click **Log In**.

**Only after you have successfully logged into this new session on port 22992 should you close the original terminal
window and the old BitVise session.**

Now that you have successfully logged into this new session on port 22992, we need to remove the default SSH port (22)
from the firewall.

```bash
# Show rules with numbers
sudo ufw status numbered
# You should see:   22/tcp  ALLOW IN  Anywhere
#                   22/tcp (v6)  ALLOW  Anywhere (v6)

# Delete the rules for 22/tcp (replace X and Y with the numbers shown for IPv4 and IPv6)
sudo ufw delete X
sudo ufw delete Y
```

---

### 5. Install Wine

Run these commands in the SSH terminal to install Wine. These are correct for **Ubuntu 22.04 LTS**.

```bash
# Enable 32-bit architecture
sudo dpkg --add-architecture i386

# Download and add the WineHQ key
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

# Add the WineHQ repository for Ubuntu 22.04 LTS (Jammy)
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources

# Update the package list
sudo apt update

# --- Check for and Install System Upgrades ---
sudo apt upgrade -y

# --- Install Wine ---
sudo apt install --install-recommends winehq-stable -y

# Verify the installation
wine --version
```

---

### 6. Install and Configure TightVNC & XFCE

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

**To save and exit nano:** Press `CTRL+S`, then `CTRL+X`.

Make the script executable:

```bash
chmod +x ~/.vnc/xstartup
```

---

### 7. Create a Systemd Service for VNC (Auto-start on boot)

Create a service file to manage VNC. The `-localhost` flag is used for maximum security, meaning VNC will only accept
connections from the machine itself. We will use an SSH tunnel for secure access.

```bash
sudo nano /etc/systemd/system/vncserver@.service
```

**Paste the following configuration into the file.**
> Don't forget to edit the file to replace `haloadmin` with your actual username.

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

**Save and exit nano (Press `CTRL+S`, then `CTRL+X`).**

Reload systemd and enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1.service
```

---

### 8. Connect to Your VNC Desktop Securely via BitVise (C2S Tunneling)

Since we configured the VNC server with the `-localhost` option for maximum security, **you cannot connect directly to
your VPS IP via TightVNC Viewer**.
Instead, we tunnel the VNC connection through your SSH session using BitVise.

1. Go to the **C2S** tab.
2. Click Add under **C2S (Client-to-Server) Port Forwarding**.
3. Enter the following:

| Field            | Value       |
|------------------|-------------|
| Listen Interface | `127.0.0.1` |
| Listen Port      | `5901`      |
| Destination Host | `127.0.0.1` |
| Destination Port | `5901`      |

**Connect TightVNC Viewer through the tunnel:**

1. Open **TightVNC Viewer**.
2. In the **VNC Server** field, enter: `127.0.0.1:5901`
3. Enter the VNC password you created in [step 6](#6-install-and-configure-tightvnc--xfce).
4. Click **Connect**. You should now see the XFCE desktop of your VPS.

> **Important**: BitVise must remain connected as `haloadmin` while using TightVNC Viewer. If you disconnect SSH, the
> VNC tunnel will close.

---

### 9. Install and Enable Fail2ban

Protect against brute-force attacks on your SSH port.

1. **Open a Terminal** from your remote desktop (right-click on the desktop > Open Terminal Here) or via your existing
   BitVise SSH session.

```bash
# Install and enable fail2ban
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
# No further configuration is needed for basic protection.
```

---

### 10. Upload Server Files via BitVise SFTP

1. In your BitVise session, click the **New SFTP Window** button.
2. In the SFTP window, navigate to the `/home/haloadmin/` directory.
3. On your local computer, locate the extracted `HPC_Server` or `HCE_Server` folder.
4. Drag and drop the entire server folder from your local machine into the `/home/haloadmin/` directory on the VPS. This
   may take a few minutes.

---

### 11. (Final Step) Create a Desktop Shortcut for Your Server

For ease of use when connected via VNC, you can create a desktop shortcut to launch your Halo server with a
double-click.

1. **Open a Terminal** from your remote desktop (right-click on the desktop > Open Terminal Here) or via your existing
   BitVise SSH session.

2. **Create a launch script:** This script will navigate to your server directory and start the dedicated server with
   Wine.

```bash
nano /home/haloadmin/HCE_Server/run.sh
```

**Paste the following contents into the file.**
**Important:** Double-check that the paths (`-path`, `-exec`) and `-port` number match your server's configuration. The
**port** must be the same as the port defined in [Step 4](#4-harden-ssh-access-and-configure-the-firewall-ufw).

```bash
#!/bin/bash
cd "/home/haloadmin/HCE_Server"
wineconsole haloceded.exe -path "cg/" -exec "cg/init.txt" -port 2302
```

**Save and exit nano (Press `CTRL+S`, then `CTRL+X`).**

Make the script executable:

```bash
chmod +x /home/haloadmin/HCE_Server/run.sh
```

3. **Create the desktop shortcut file.**

```bash
nano /home/haloadmin/Desktop/run.desktop
```

**Paste the following configuration into the file.** Edit the `Name` and `Exec` lines to match your server.

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=RENAME_THIS
Exec=/home/haloadmin/HCE_Server/run.sh
Icon=utilities-terminal
Categories=Game;
```

**Save and exit nano.**

Make the desktop file executable:

```bash
chmod +x /home/haloadmin/Desktop/all_in_one.desktop
```

4. **Using the Shortcut:** You should now see a new icon on your VPS desktop. The first time you double-click it, you
   will likely be prompted by Wine to **install Mono**. Click "Install" and allow it to complete. Once installed, the
   server console window will open. Subsequent double-clicks will launch the server directly.

**You can now launch your server directly from the desktop.**

---

### 12. (Optional, Recommended Upgrade) Install X2Go for a Superior Remote Desktop

TightVNC works but can be laggy. **X2Go** uses a more efficient protocol, offering a much faster and more responsive
remote desktop experience. It also allows you to disconnect and reconnect to your running desktop session.

**Prerequisite:** Download and install the [X2Go Client](https://wiki.x2go.org/doku.php/doc:installation:x2goclient) on
your Windows PC.

**On the VPS (via BitVise SSH):**

```bash
# Install the X2Go server and the XFCE session module
sudo apt install x2goserver x2goserver-xsession -y

# The XFCE desktop you installed earlier is the perfect match for X2Go.
# No further configuration is needed on the server.
```

**On Your Windows PC:**

1. Open the **X2Go Client**.
2. Create a new session:
    * **Session Name:** `Halo Server`
    * **Host:** Your VPS's IP address
    * **Login:** `haloadmin`
    * **SSH Port:** `22992` (or your custom port)
    * **Session Type:** `XFCE`
3. Click **OK** to save the session.
4. Select the new session and click **Session** -> **Start**.
5. You will now be connected to a much smoother and more responsive desktop.

**Important Note:** X2Go uses your existing SSH connection for secure tunneling. Once you verify X2Go works, you can *
*stop and disable the VNC service** if you wish, as you will no longer need it:

```bash
sudo systemctl stop vncserver@1.service
sudo systemctl disable vncserver@1.service
```
