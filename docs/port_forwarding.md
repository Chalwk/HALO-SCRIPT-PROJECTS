### How to Set Up Port Forwarding for Your SAPP/Phasor Halo PC/CE Server

**Why?**
Port forwarding is essential to allow players outside your local network to connect to your game server. It directs incoming traffic on specific ports from your router to the machine hosting the server.

---

### Step 1: Find Your Server's Local IP Address

This step is identical regardless of your server's operating system. You need the local (LAN) IP address of the machine running the Halo server.

*   **Windows:**
    *   Press `Win + R`, type `cmd`, and press Enter.
    *   In the Command Prompt, type `ipconfig` and press Enter.
    *   Look for the **IPv4 Address** under your active network adapter (e.g., `192.168.1.100` or `10.0.0.50`). This is your server's local IP.

*   **Linux (Terminal):**
    *   Open a terminal window.
    *   Type the command `ip addr show` or `hostname -I` and press Enter.
    *   Look for the `inet` address on your main network interface (usually `eth0` or `wlan0`). It will typically be in the `192.168.x.x` or `10.0.x.x` range.

---

### Step 2: Log Into Your Router's Admin Page

This step is performed from any web browser on a device connected to your network and is OS-agnostic.

1.  Open a web browser (Chrome, Firefox, Edge, etc.).
2.  Enter your router's gateway IP address into the address bar. Common addresses include:
    *   `192.168.1.1`
    *   `192.168.0.1`
    *   `10.0.0.1`
    *   (You can often find this on Windows by running `ipconfig` and looking for the "Default Gateway" value).
3.  Enter the administrator username and password when prompted.
    *   These are often printed on a sticker on the router itself (e.g., "admin/password").
    *   If you've changed them and forgotten, you may need to reset your router.

---

### Step 3: Find Port Forwarding Settings

The location of this setting varies significantly by router manufacturer.

*   **Common Labels:** Look for sections named **Port Forwarding**, **Virtual Server**, **NAT Forwarding**, **Firewall**, or **Applications & Gaming**.
*   **Consult Manual:** If you can't find it, a quick web search for "*[Your Router Model]* port forwarding setup" will usually yield a guide.

---

### Step 4: Create Port Forwarding Rules

You need to forward **both ports** below for the server to work correctly. Create two separate rules.

| Field             | Value                                  |
|:------------------|:---------------------------------------|
| **Service Name**  | `Halo (Game Port)`                     |
| **Protocol**      | `UDP`                                  |
| **External Port** | `2302`                                 |
| **Internal Port** | `2302`                                 |
| **Internal IP**   | `Your server's local IP (from Step 1)` |

| Field             | Value                                  |
|:------------------|:---------------------------------------|
| **Service Name**  | `Halo Server Port`                     |
| **Protocol**      | `UDP`                                  |
| **External Port** | `Your chosen server port (e.g., 2310)` |
| **Internal Port** | `Your chosen server port (e.g., 2310)` |
| **Internal IP**   | `Your server's local IP (from Step 1)` |

> **⚠️ Important Note on Ports:**
> The server port can be **any 4-digit number** (e.g., 2305, 2310, 2400), but it **must match** your servers port in the SAPP/Phasor configuration.
>
> **If you play Halo on the same PC as your server**, you must avoid a port conflict. To do this:
> 1.  Launch Halo Custom Edition.
> 2.  Go to **Settings -> Network Setup**.
> 3.  Set your **Client Port** to `0`. This lets Halo choose a random, unused port.
      > This ensures your game client and server aren't both trying to use the same port number.

---

### Step 5: Save and Apply

*   Click **Save**, **Apply**, or **OK**. Your router will likely process the changes and may briefly disconnect.
*   A router restart is sometimes required for changes to take full effect.

---

### Step 6: Configure the Firewall (OS Specific)

The server machine must allow incoming traffic on the two UDP ports. This is where instructions differ.

#### For Windows Firewall:

Create **one inbound rule** that covers **both UDP ports**.

1.  Press `Win + R`, type `wf.msc`, and press Enter to open Windows Firewall with Advanced Security.
2.  Click on **Inbound Rules** in the left pane.
3.  Click **New Rule...** in the right pane.
4.  Select **Port** and click **Next**.
5.  Select **UDP** and enter **Specific local ports**: `2302, <your server port>` (e.g., `2302, 2310`). Click **Next**.
6.  Select **Allow the connection**. Click **Next**.
7.  Select all three profiles (Domain, Private, Public). Click **Next**.
8.  Give the rule a descriptive name, e.g., `Halo SAPP Server (Ports 2302, 2310)`. Click **Finish**.

#### For Linux Firewalls:

**Method A: Using `ufw` (Uncomplicated Firewall - common on Ubuntu, Mint, Debian)**
```bash
# Allow the specific UDP ports through the firewall
sudo ufw allow 2302/udp
sudo ufw allow 2310/udp  # Replace 2310 with your chosen server port

# Enable the firewall if it's not already active
sudo ufw enable

# Verify the rules were added
sudo ufw status verbose
```

**Method B: Using `firewalld` (common on Fedora, CentOS, RHEL)**
```bash
# Permanently add the UDP ports to the public zone (or your active zone)
sudo firewall-cmd --permanent --add-port=2302/udp
sudo firewall-cmd --permanent --add-port=2310/udp  # Replace 2310 with your chosen server port

# Reload the firewall to apply changes
sudo firewall-cmd --reload

# List open ports to confirm
sudo firewall-cmd --list-ports
```

**Method C: Using `iptables` (Direct Configuration - universal)**
```bash
# Add rules to accept incoming UDP packets on the required ports
sudo iptables -A INPUT -p udp --dport 2302 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 2310 -j ACCEPT  # Replace 2310 with your chosen server port

# To make these rules persistent across reboots, you need to save them.
# The command for this varies by distribution:
sudo netfilter-persistent save  # On Debian/Ubuntu (if installed)
# or
sudo service iptables save      # On some older distributions like CentOS 6
```

---

### Bonus Tips & Troubleshooting

*   **Static IP/ DHCP Reservation:** To prevent your server's local IP from changing, assign it a **static IP** on the machine itself or, even better, set up a **DHCP reservation** in your router's settings. This ties the IP address to your server's MAC address.
*   **Double NAT:** If you are behind multiple routers (e.g., a ISP modem/router and your own router), you must forward ports on **both devices**. This is called "Double NAT" and is often best solved by putting the ISP modem into "Bridge Mode."
*   **Check Your Work:** Use a website like **https://www.yougetsignal.com/tools/open-ports/** to check if your external IP has the UDP ports open. You will need to know your public IP (just google "what is my ip").
*   **Antivirus:** Ensure any third-party antivirus or security suite is also configured to allow traffic on these ports.