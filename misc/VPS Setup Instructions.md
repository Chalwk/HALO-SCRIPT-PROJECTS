# VPS Setup Instructions

This is a step-by-step tutorial that covers the installation of a Ubuntu VPS with Wine and a VNC server for remote
connection.<br/>The hosting company I will be using in this tutorial is [Vultr](https://www.vultr.com/).

Quality of life advice:<br/>
Copy & paste commands into the SSH Terminal by highlighting the command/text block in this guide, press CTRL-C to copy,
and then right-click into the SSH Terminal. This method will save a lot of time so you don't have to write out each
command letter-by-letter.

****

# Prerequisite applications:

 Application                                                                                     | Description                                                    
-------------------------------------------------------------------------------------------------|----------------------------------------------------------------
 [BitVise SSH Client](https://www.bitvise.com/ssh-client-download)                               | For remote access to the terminal and to upload files via SFTP 
 [TightVNC (client)](https://www.tightvnc.com/download.php)                                      | For remote desktop connections                                 
 [HPC/CE Server Template](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/ReadyToGo) | These are compatible with Linux                                

#### Technical note on [Vultr](https://www.vultr.com/) subscription plans:

You pay for whatever you need.<br/>
However, you need at least 150 MiB RAM *per server* to cover peak times.<br/>
Multiply that by the number of servers you need and that'll tell you much you should expect to pay.<br/>
Note that each plan allocates you a defined amount of storage space. You may need more depending on how many maps you
intend to upload.

****

## STEPS:

### 1). Download the server template of your choice (linked above).

Note: You will need a file decompression tool like [WinRAR](https://www.win-rar.com/start.html?&L=0)
or [7-zip](https://www.7-zip.org/download.html) to extract
the [HPC.Server.zip](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/download/ReadyToGo/HPC.Server.zip)
or [HCE.Server.zip](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/download/ReadyToGo/HCE.Server.zip).

Please see [this page](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/ReadyToGo) for full information about
these server templates.

### 2). Download and install [BitVise SSH Client](https://www.bitvise.com/ssh-client-download) and [TightVNC (client)](https://www.tightvnc.com/download.php) to your PC.

### 3). Deploying a new VPS on Vultr:

- Navigate to the [Deploy](https://my.vultr.com/deploy/) page on Vultr
- Select Cloud Compute
- Choose your server location
- Under Server Type, select **Ubuntu 23.04 x64**
- Choose your monthly subscription plan
- Select any Additional Features you require (optional)
- Label your VPS instance and click **Deploy Now**

### 4). Open BitVise SSH Client:

- Fill in the host & username (get from the VPS control panel overview page).
- Set the port field to **22**.
- In the **Initial method** drop-down box, select *password*.<br/>Paste your password in the password field (get from
  the VPS control panel overview page).<br/>Make sure *Store encrypted password in profile* is ticked.<br/>Click **Save
  profile as** and save.
- Click login.<br/>You will be prompted to accept and save a host key. Click accept and save.
- Click the "New Terminal Console" button.

### 5). Enter the following commands into the SSH Terminal (in order):

 Command                                                                             | Description                                                                                                                                                            
-------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 sudo dpkg --add-architecture i386                                                   | Add multiarch support                                                                                                                                                  
 wget -nc https://dl.winehq.org/wine-builds/winehq.key                               | Add the WineHQ Ubuntu repository                                                                                                                                       
 sudo -H gpg -o /etc/apt/trusted.gpg.d/winehq.key.gpg --dearmor winehq.key           | Get and install the repository key.                                                                                                                                    
 sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ impish main' | Add the repository.                                                                                                                                                    
 sudo apt update                                                                     | Update the package database.                                                                                                                                           
 apt install wine                                                                    | Install Wine.<br><br>A **Pending Kernel Upgrade** page may appear - click OK.<br><br>Another window (Deamons using outdated libraries) may appear - click cancel.<br/> 
 wine --version                                                                      | Verify the installation has succeeded.                                                                                                                                 

### 6). Installing TightVNC Server:

 Command                                        | Description                                                                                                                                                                                                                                                                                                                                                                                                 
------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 apt install xfce4 xfce4-goodies tightvncserver | The graphical environment is not installed by default on server versions of Ubuntu.<br/>Therefore, if we want to connect to a remote desktop, we need to install a graphical shell.<br/>Let's install the TightVNC Server itself at the same time.<br><br>A **Pending Kernel Upgrade** page may appear - click OK.<br><br>Another window (Deamons using outdated libraries) may appear - click cancel.<br/> 
 vncserver                                      | Start the TightVNC Server for the first time.<br/>It will create the files necessary for work and ask you to create a password.<br/>If you need to restrict remote desktop control, select a read-only password.                                                                                                                                                                                            
 vncserver -kill :1                             | Now stop your TightVNC session to adjust other settings:                                                                                                                                                                                                                                                                                                                                                    
 nano ~/.vnc/xstartup                           | Open the TightVNC config file.<br/><br/>*Add the following line to the end:*<br/>**startxfce4**<br/><br/>**Technical note: To save and exit nano screen, press CTRL-S (save), CTRL-X (exit).**                                                                                                                                                                                                              

### 7). Setting up autorun for VNC Server:

 Command                                    | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
--------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 nano /etc/systemd/system/vncserver.service | By default, TightVNC does not have a daemon and does not turn on after a system reboot.<br/>To fix this, let's create a new unit in systemd.<br/><---Execute this command.<br/><br/>**Technical note: To save and exit nano screen, press CTRL-S (save), CTRL-X (exit).**<br/><br/>*Insert the following config there:*<br/>**<br/>[Unit]<br/>Description=TightVNC server<br/>After=syslog.target network.target<br/><br/>[Service]<br/>Type=forking<br/>User=root<br/>PAMName=login<br/>PIDFile=/root/.vnc/%H:1.pid<br/>ExecStartPre=-/usr/bin/vncserver -kill :1 > /dev/null 2>&1<br/>ExecStart=/usr/bin/vncserver -geometry 1920x1080<br/>ExecStop=/usr/bin/vncserver -kill :1<br/><br/>[Install]<br/>WantedBy=multi-user.target** 
 systemctl daemon-reload                    | Reload systemd                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
 systemctl enable --now vncserver           | Enable autorun of the TightVNC server and start it.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   

### 8). Set up UFW (firewall) **READ DESCRIPTIONS ON THIS STEP CAREFULLY**

We need to enable the firewall so that only certain ports are accessible from the outside world.
Command | Description
-- | --
sudo ufw allow 2302:2303/udp|Allow UDP connections for Halo on ports 2302, 2303
sudo ufw allow 2310:2312/udp|Allow UDP connections for server ports (or any port range you desire)
ufw allow 5901/tcp|If you don't have a static IP, do this command (and skip the next two commands).
ufw allow from 0.0.0.0 to any port 5901|Optionally allow your IP Address and reject all others.<br/>This will make it so
that only the specified IP(s) can connect to the vnc server.<br/><br/>Replace 0.0.0.0 with your own ipv4 address.
ufw default deny incoming|If you executed the previous command, then we also need to deny other inbound connections. If
you didn't execute the previous command, skip to the next one below.
sudo ufw enable|Enable the UFW

### 9). Change SSH Port (optional but recommended):

Make a note of the new SSH port you create because you will need it for future connections to BitVise.

 Command                    | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 nano /etc/ssh/sshd_config  | By default, SSH listens on port 22.<br/>Changing the default SSH port adds an extra layer of security to your server by reducing the risk of automated attacks.<br/><br/>To change the default SSH port in Ubuntu, Open the **sshd_config** file this command.<br/><br/>**Technical note: To save and exit nano screen, press CTRL-S (save), CTRL-X (exit).**<br/><br/>*Locate this line:*<br/>**#Port 22**<br/><br/>*Uncomment (remove the leading # character) it and change the value with an appropriate port number (for example, 22000):*<br/>**Port 22000** 
 systemctl restart sshd     | Restart the SSH server                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
 apt install net-tools      | Install net-tools<br><br>A **Pending Kernel Upgrade** page may appear - click OK.<br><br>Another window (Deamons using outdated libraries) may appear - click cancel.<br/>                                                                                                                                                                                                                                                                                                                                                                                         
 netstat -tulpn \| grep ssh | After that, run the netstat command and make sure that the ssh daemon now listens on the new ssh port                                                                                                                                                                                                                                                                                                                                                                                                                                                              
 sudo ufw allow 22000/tcp   | Add a rule to allow new SSH port.<br/>Furthermore, future SSH connections with BitVise will require you to specify the port in the port field.<br/><br/>Use the port you decided on in command 1 of step 9.                                                                                                                                                                                                                                                                                                                                                        

### 10). Enable fail2ban (optional but recommended):

fail2ban will monitor all incoming traffic.<br/> There are often a lot of bots trying to see if you have any open
loopholes within your VPS to see if they can exploit something.<br/>One of the features of fail2ban is to automatically
monitor those types of IPs and block them from connecting in general.

In a BitVise SSH terminal window, execute the following commands:

 Command                   | Description                                                                      
---------------------------|----------------------------------------------------------------------------------
 apt install fail2ban -y   | Install Fail 2 Ban                                                               
 systemctl enable fail2ban | Ensures the fail2ban service is started automatically when the VPS is restarted. 

### 11). Uploading Servers Files:

- Open BitVise and log in.
- Click **New SFTP window** button.
- Navigate to */root/Desktop*.
- Transfer the server folder that you extracted (HPC Server or HCE Server).

### 12). Launching your server(s):

- Navigate to */root/Desktop/\<server folder>/Wine Launch Files*
- Double-click on *run.desktop* to launch your server.<br/>
  Upon the first launch, you may be prompted to install some mono software in order to launch the server.<br/>
  Follow the on-screen prompts to do this. It's straightforward.

----

### REMOTE CONNECTING WITH TIGHT VNC CLIENT:<br/>

When filling in the IP Address field on TightVNC Client, be sure to suffix the IP with Display Port **:5901**<br/>
For example: **127.0.0.1:5901**

Use the password created in step 6.
