**How to Set Up Port Forwarding for Your SAPP Halo PC/CE Server**

*Why?*
Port forwarding lets external players connect by opening a communication channel through your network.

---

**Step 1: Find Your Server’s Local IP Address**

* Open Command Prompt (`Win + R`, type `cmd`, Enter)
* Type `ipconfig` and press Enter
* Find **IPv4 Address** under your active network adapter (e.g., `192.168.x.x`) - this is your server’s local IP

---

**Step 2: Log Into Your Router’s Admin Page**

* Open a browser on your network device
* Enter router IP (usually `192.168.1.1`, `192.168.0.1`, or `10.0.0.1`)
* Enter your router username/password (check router sticker/manual if unsure)

---

**Step 3: Find Port Forwarding Settings**

* Look for **Port Forwarding**, **Virtual Server**, or **NAT Settings**
* Location varies by router; check your manual if needed

---

**Step 4: Create Port Forwarding Rules**

You need to forward **both ports** below for the server to work correctly:

| Field         | Value                           |
|---------------|---------------------------------|
| Service Name  | Halo (Game Port)                |
| Protocol      | UDP                             |
| External Port | 2302                            |
| Internal Port | 2302                            |
| Internal IP   | Your server’s local IP (Step 1) |

| Field         | Value                                         |
|---------------|-----------------------------------------------|
| Service Name  | Halo SAPP Server (Server Port)                |
| Protocol      | UDP                                           |
| External Port | *Your chosen server port (for example, 2310)* |
| Internal Port | *Your chosen server port (default is 2310)*   |
| Internal IP   | Your server’s local IP (Step 1)               |

Perfect! Here’s a tidy, clear technical note you can add right after the first note in Step 4. It gently warns about port conflicts for local play — with calm, precise wording:

---

> **Note:** The server port can be **any 4-digit number**, just make sure to use the same port number in both your server configuration and your port forwarding rules.
>
> **Important:** If you play the game on the same local network as your server, ensure the server port is **different** from your client port in-game. To check your client port:
>
> 1. Launch Halo
> 2. Go to **Settings → Network Setup**
> 3. Set **Client Port** to `0`
>
> Avoid using the same port for both server and client to prevent connection conflicts.

---

**Step 5: Save and Apply**

* Save/apply the rules
* Restart router if needed

---

**Step 6: Configure Windows Firewall (Inbound Rules Only)**

Create **one inbound rule** that covers **both UDP ports 2302 and your server port**:

1. Press `Win + R`, type `wf.msc`, press Enter
2. Click **Inbound Rules** → **New Rule...**
3. Select **Port** → **Next**
4. Choose **UDP**
5. In "Specific local ports", enter: `2302,<your server port>` (e.g., `2302,2512`) → **Next**
6. Select **Allow the connection** → **Next**
7. Select profiles (Domain, Private, Public) → **Next**
8. Name it `Halo SAPP Server (Ports 2302, <your server port>)` → **Finish**

---

**Bonus Tips**

* Assign a static IP to your server or reserve one in your router to avoid IP changes.
* Make sure no other firewalls or security software block UDP ports 2302 and your chosen server port.
* If behind multiple routers (Double NAT), forward ports on each device.

---