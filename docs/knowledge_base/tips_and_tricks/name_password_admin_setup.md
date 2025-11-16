I generally **do not recommend adding users as hash-admins**, since many players are using pirated clients. Similarly,
because most players have **dynamic IP addresses**, assigning them as IP-admins is often impractical.

For these members, I advise using the **Name/Password system** instead.

### How to Set Up Name/Password Admins:

1. **Add the admin** using the command:
   `admin_add <player_name> <password> <level>`

    * `<player_name>`: The exact in-game name the player uses to join the server.
    * `<password>`: A password you set for them.
    * `<level>`: Their admin level (1–4).
      **Example:**
      `admin_add Chalwk mySecurePassword123 3`
2. **Activating admin privileges**:
   After joining the server, your admins must enter:
   `login <password>`
   in the in-game chat to activate their privileges. The password used here is the one set in step 1.
   **Security Recommendations:**

* Assign a **unique password for each admin**. This ensures that if one password is compromised, it does not affect
  other users.
* Admins do **not need to log in every time**, unless the server is restarted or their IP address changes.

For users with **legitimate CD Keys**, the **hash-based system** remains the recommended method.