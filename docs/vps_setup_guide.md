# ⚠️ As of 29-08-2025, this guide made not work anymore due to Vultr's recent changes to their subscription plans.

# VPS Setup Instructions

This is a step-by-step tutorial that covers the installation of an Ubuntu VPS with Wine and a VNC server for remote connection. The hosting company used in this tutorial is [Vultr](https://www.vultr.com/).

## Quality of Life Advice
Copy & paste commands into the SSH Terminal by highlighting the command/text block in this guide, pressing **CTRL-C** to copy, and then right-clicking into the SSH Terminal. This method will save time, so you don't have to write out each command letter by letter.

---

## Prerequisite Applications
| Application                                                                                     | Description                                                     |
|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|
| [BitVise SSH Client](https://www.bitvise.com/ssh-client-download)                               | For remote access to the terminal and to upload files via SFTP. |
| [TightVNC (client)](https://www.tightvnc.com/download.php)                                      | For remote desktop connections.                                 |
| [HPC/CE Server Template](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/ReadyToGo) | These are compatible with Linux.                                |

### Technical Note on [Vultr](https://www.vultr.com/) Subscription Plans
You pay for whatever you need. However, you need at least 150 MiB RAM *per server* to cover peak times. Multiply that by the number of servers you need to estimate your costs. Note that each plan allocates a defined amount of storage space, which may need to be increased depending on how many maps you intend to upload.

---

## Steps

### 1). Download the Server Template
Download the [SAPP server template](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/ReadyToGo) of your choice. Note: You will need a file decompression tool like [WinRAR](https://www.win-rar.com/start.html?&L=0) or [7-zip](https://www.7-zip.org/download.html) to extract the [HPC.Server.zip](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/download/ReadyToGo/HPC.Server.zip) or [HCE.Server.zip](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/download/ReadyToGo/HCE.Server.zip).

### 2). Install Prerequisite Applications
Download and install [BitVise SSH Client](https://www.bitvise.com/ssh-client-download) and [TightVNC (client)](https://www.tightvnc.com/download.php) on your PC.

### 3). Deploying a New VPS on Vultr
- Navigate to the [Deploy](https://my.vultr.com/deploy/) page on Vultr.
- Select **Cloud Compute**.
- Choose your server location.
- Under **Server Type**, select **Ubuntu 21.10 x64**.
- Choose your monthly subscription plan.
- Select any Additional Features you require (optional).
- Label your VPS instance and click **Deploy Now**.

### 4). Open BitVise SSH Client
- Fill in the host & username (get from the VPS control panel overview page).
- In the **Initial method** drop-down box, select **password**.
- Paste your password in the password field (get from the VPS control panel overview page).
- Make sure *Store encrypted password in profile* is ticked.
- Click **Save profile as** and save.
- Click **Login**. You will be prompted to accept and save a host key. Click **Accept and Save**.
- Click the **New Terminal Console** button.

### 5). Enter Commands into the SSH Terminal (in order)
| Command                                                                               | Description                            |
|---------------------------------------------------------------------------------------|----------------------------------------|
| `sudo dpkg --add-architecture i386`                                                   | Add multiarch support.                 |
| `wget -nc https://dl.winehq.org/wine-builds/winehq.key`                               | Add the WineHQ Ubuntu repository.      |
| `sudo -H gpg -o /etc/apt/trusted.gpg.d/winehq.key.gpg --dearmor winehq.key`           | Get and install the repository key.    |
| `sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ impish main'` | Add the repository.                    |
| `sudo apt update`                                                                     | Update the package database.           |
| `sudo apt install --install-recommends winehq-stable`                                 | Install Wine.                          |
| `wine --version`                                                                      | Verify the installation has succeeded. |

### 6). Installing TightVNC Server
| Command                                          | Description                                                                                                                                           |
|--------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| `apt install xfce4 xfce4-goodies tightvncserver` | Install the graphical environment and TightVNC Server.                                                                                                |
| `vncserver`                                      | Start the TightVNC Server for the first time and create a password. If you need to restrict remote desktop control, select a read-only password.      |
| `vncserver -kill :1`                             | Stop your TightVNC session to adjust other settings.                                                                                                  |
| `nano ~/.vnc/xstartup`                           | Open the TightVNC config file. Add the following line to the end: `startxfce4`.<br><br>**To save and exit nano, press CTRL-S (save), CTRL-X (exit).** |

### 7). Set Up Autorun for VNC Server
| Command                                      | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
|----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `nano /etc/systemd/system/vncserver.service` | Create a new unit in systemd. Insert the following config: <br> <br>[Unit]<br>Description=TightVNC server<br>After=syslog.target network.target<br><br>[Service]<br>Type=forking<br>User=root<br>PAMName=login<br>PIDFile=/root/.vnc/%H:1.pid<br>ExecStartPre=-/usr/bin/vncserver -kill :1 > /dev/null 2>&1<br>ExecStart=/usr/bin/vncserver -geometry 1920x1080<br>ExecStop=/usr/bin/vncserver -kill :1<br><br>[Install]<br>WantedBy=multi-user.target<br><br>**To save and exit nano, press CTRL-S (save), CTRL-X (exit).** |
| `systemctl daemon-reload`                    | Reload systemd.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `systemctl enable --now vncserver`           | Enable autorun of the TightVNC server and start it.                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |

### 8). Set Up UFW (Firewall)
Enable the firewall so that only certain ports are accessible from the outside world.
| Command | Description |
| ------- | ----------- |
| `sudo ufw allow 2302:2303/udp` | Allow UDP connections for Halo on ports 2302, 2303. |
| `sudo ufw allow 2310:2312/udp` | Allow UDP connections for server ports (or any port range you desire). |
| `ufw allow 5901/tcp` | Allow connections to port 5901 if you don't have a static IP. |
| `ufw allow from 0.0.0.0 to any port 5901` | Optionally allow your specific IP Address and reject all others. Replace `0.0.0.0` with your own IPv4 address. |
| `ufw default deny incoming` | Deny other inbound connections if you did the previous step. |
| `sudo ufw enable` | Enable the UFW. |

### 9). Change SSH Port (Optional but Recommended)
Make a note of the new SSH port you create, as you'll need it for future connections to BitVise.
| Command | Description |
| ------- | ----------- |
| `nano /etc/ssh/sshd_config` | Change the default SSH port for added security. Locate the line `#Port 22` and uncomment it. Change the value to an appropriate port number (e.g., `Port 22000`). **To save and exit nano, press CTRL-S (save), CTRL-X (exit).** |
| `systemctl restart sshd` | Restart the SSH server. |
| `apt install net-tools` | Install net-tools. |
| `netstat -tulpn | grep ssh` | Verify that the SSH daemon listens on the new port. |
| `sudo ufw allow 22000/tcp` | Add a rule to allow the new SSH port. You will need to specify the port in the BitVise port field for future SSH connections. |

### 10). Enable fail2ban (Optional but Recommended)
**Fail2ban** will monitor incoming traffic and automatically block suspicious IPs.
| Command | Description |
| ------- | ----------- |
| `apt install fail2ban -y` | Install Fail2Ban. |
| `systemctl enable fail2ban` | Ensure the Fail2Ban service starts automatically when the VPS is restarted. |

### 11). Uploading Server Files
- Open BitVise and log in.
- Click the **New SFTP Window** button.
- Navigate to */root/Desktop*.
- Transfer the server folder that you extracted (HPC Server or HCE Server).

### 12). Launching Your Server(s)
- Navigate to the server folder you uploaded (e.g., `cd ~/Desktop/HPC Server/Wine Launch Files`)
- Double-click on `run.desktop` to launch your server. Upon the first launch, you may be prompted to install some mono software in order to launch the server. Follow the on-screen prompts to do this.

## Remote Connecting with Tight VNC Client
- Open TightVNC Viewer and enter your VPS IP followed by the port you set during TightVNC Server setup, e.g., `127.0.0.1:5901`.
- Click Connect and enter the password you set during TightVNC Server setup.
- You should now see your Ubuntu desktop.