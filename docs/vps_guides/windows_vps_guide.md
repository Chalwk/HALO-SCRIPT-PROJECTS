**Last Updated: 29 Aug 2025**

# Windows VPS Setup for Halo PC / Halo CE (SAPP Servers)

This guide provides instructions for setting up a **Windows-based** VPS on Vultr to host a Halo Custom Edition or Combat
Evolved (PC) dedicated server using the SAPP mod. This method uses the native Windows environment for simplicity.

---

## Prerequisite Applications

| Application                                                                                                                                     | Description                                                         |
|:------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------|
| [Remote Desktop Connection (mstsc)](https://support.microsoft.com/en-us/windows/how-to-use-remote-desktop-5fe128d5-8fb1-7a23-3b8a-41e636865e8c) | Built into Windows for connecting to your server's desktop.         |
| [FileZilla Client](https://filezilla-project.org/)                                                                                              | A familiar FTP/SFTP client for transferring server files .          |
| [HPC/CE Server Template](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/ReadyToGo)                                                 | Pre-configured SAPP server files for Windows.                       |
| [7-Zip](https://www.7-zip.org/) (Optional)                                                                                                      | For extracting files if your Windows version lacks a built-in tool. |

### ⚠️ Important Notes Before You Begin

- **Cost & Plan Type:** Windows Server licenses are included but increase the cost. You must select a **Cloud GPU** plan
  type, as Windows is not available on Shared CPU plans. The cheapest viable option is typically the **$36/mo** plan (2
  vCPU, 4GB RAM) .
- **OS Selection:** For a game server, a GUI is essential. **The recommended choice is `Windows 2022 Standard x64`** (
  the non-"Core" version). It is the current Long-Term Servicing Channel (LTSC) version, offering the best balance of
  long-term stability and support.
- **Ports:** You must open the standard Halo ports (**UDP 2302-2303**) **AND** your custom server port (defined in
  `RUN.bat`) in the firewall.

---

## Steps

### 1. Download and Prepare the Server Template

1. Download
   the [HPC.Server.zip or HCE.Server.zip](https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/ReadyToGo) file.
2. Extract the ZIP file on your local computer using your preferred tool (Windows built-in extractor or 7-Zip). You will
   have a folder named `HPC Server` or `HCE Server`.

### 2. Deploying a New Windows VPS on Vultr

1. Navigate to the [Vultr Deploy](https://my.vultr.com/deploy/) page.
2. For **Server Type**, select **Cloud GPU**.
3. Choose a server location closest to you and your players.
4. Select a plan.
5. **Click the "Configure" button** on the bottom-right of the page.
6. On the operating system selection page, **Select `Windows 2022 Standard x64`** from the list. (Avoid "Core" versions
   as they have no graphical interface).
7. Click **Deploy Now**. Wait for the status to show "Running". This can take 10-15 minutes.

### 3. Retrieve Your Administrator Password

1. From your Vultr control panel, click on your new Windows server instance.
2. Go to the **Overview** tab.
3. In the **Server Information** section, click the **eye icon** to reveal the **Administrator password**. **Copy this
   password immediately** and store it securely.

### 4. Connect via Remote Desktop (RDP)

1. On your local Windows PC, open the **Remote Desktop Connection** app.
2. In the "Computer" field, enter the **IP Address** of your VPS.
3. Click **Show Options** and enter the username: `Administrator`.
4. (Optional) Click "Save As" to save this connection for later.
5. Click **Connect**. You will be warned about certificates; check "Don't ask me again..." and click "Yes".
6. Enter the **Administrator password** you retrieved and click "OK".
7. You are now connected to your Windows Server desktop.

### 5. Initial Windows Setup & Security

Upon first login, you will be greeted with a server manager dashboard.

1. **Windows Update:** Search for "Check for updates" and install all available critical updates. The server may need to
   restart. Reconnect via RDP afterward.
2. **Disable IE Enhanced Security:** This feature blocks downloads.
    - In the **Server Manager** dashboard, click on **Local Server**.
    - Find **IE Enhanced Security Configuration** and click "On". Set it to "Off" for administrators. Click OK.
3. **Set a Static Page File (Highly Recommended):** The default plan has limited disk space. A dynamic page file can
   fill it up.
    - Press `Win + R`, type `sysdm.cpl`, and press Enter.
    - Go to the **Advanced** tab > **Performance Settings** > **Advanced** tab > **Change...**.
    - **Uncheck** "Automatically manage paging file size for all drives".
    - Select the `C:` drive.
    - Select **Custom size** and set both **Initial size** and **Maximum size** to `2048` MB.
    - Click **Set**, then **OK**. Restart the server when prompted.

### 6. Configure Your Halo Server Port

**This is a critical step. The server port is configured in the `RUN.bat` file.**

1. **On your local PC**, before uploading, open the `HPC Server` or `HCE Server` folder.
2. Find the `RUN.bat` file and open it with Notepad.
3. Locate the line that says `set port=2301` (or similar). The default port is typically **2301**.
4. Change the number to your desired custom port (e.g., `set port=2402`). **Make a note of this port number.**
5. Save the file.

### 7. Upload Server Files with FileZilla

1. **On your local PC**, open FileZilla.
2. In the top bar, enter:
    - **Host:** `sftp://[Your VPS IP Address]` (The `sftp://` prefix is crucial for security).
    - **Username:** `Administrator`
    - **Password:** Your VPS password
    - **Port:** `22`
3. Click **Quickconnect**. Accept the server's host key if prompted.
4. On the right (Remote site), navigate to `C:\Users\Administrator\Desktop`.
5. On the left (Local site), navigate to your extracted `HPC Server` or `HCE Server` folder.
6. **Drag the entire folder** from the left pane to the right pane to upload it to the VPS desktop. This will take
   several minutes.

### 8. Configure the Windows Firewall

You must open **both** the standard game ports **and your server's custom port** from the `RUN.bat` file.

1. **On the VPS**, press `Win + R`, type `wf.msc`, and press Enter to open **Windows Defender Firewall with Advanced
   Security**.
2. Click on **Inbound Rules** > **New Rule...**.
3. **Rule Type:** Select `Port` and click Next.
4. **Protocol:** Select `UDP` and specify **`2302-2303`**. Click Next.
5. **Action:** Select `Allow the connection`. Click Next.
6. **Profile:** Select all three (Domain, Private, Public). Click Next.
7. **Name:** Name it clearly, e.g., `Halo UDP 2302-2303`. Click Finish.
8. **Repeat Steps 2-7** to create a rule for your **custom server port** (e.g., UDP port **`2402`**).

### 9. Install and Run Your Halo Server

1. **On the VPS**, on your desktop, open the server folder you uploaded.
2. **Double-click the `RUN.bat`** file to launch your server. A console window will open. You may see firewall pop-ups;
   allow access.
3. Your server is now live on the IP and port of your VPS.

### 10. (Optional) Install as a Service

For reliability (so the server runs after you log out of RDP),
use [NSSM (the Non-Sucking Service Manager)](https://nssm.cc/).

1. Download NSSM on the VPS and unzip it.
2. Open a Command Prompt as Administrator.
3. Navigate to the NSSM folder (e.g., `cd C:\Users\Administrator\Downloads\nssm\win64`).
4. Install the service (adjust paths to your server's `haloded.exe`):
   ```cmd
   nssm install "Halo Server" "C:\Users\Administrator\Desktop\HPC Server\haloded.exe"
   nssm set "Halo Server" AppDirectory "C:\Users\Administrator\Desktop\HPC Server"
   ```
5. Start the service from the Windows "Services" application (`services.msc`) or with `nssm start "Halo Server"`.

---