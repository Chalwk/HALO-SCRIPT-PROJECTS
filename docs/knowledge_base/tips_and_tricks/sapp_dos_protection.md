## SAPP's "DoS" Protection: Explained

Let's be precise: SAPP offers **DoS (Denial-of-Service)** protection, which is different from **DDoS (Distributed
Denial-of-Service)**. The key difference is one attacker vs. many.

### What SAPP Does Well (The Good):

SAPP is excellent at mitigating the most common nuisances and basic attacks that Halo servers face:

1. **Packet Flooding:** The `packet_limit` command (default: 1000 packets/second per IP) is very effective. It instantly
   kicks any single IP that exceeds this threshold. This will stop simple UDP floods from a single machine or a small
   botnet that isn't masking its IPs.
2. **Join Spamming:** The `antihalofp` feature is crucial. It automatically IP bans players who attempt to join too
   frequently in a short time. This completely neutralizes tools like "Halo Flood Prevent" which spam join requests to
   crash the server.
3. **RCON Brute-Force Protection:** After 4 failed RCON password attempts, the offending IP is banned for **one hour**.
   This makes guessing the password via automation practically impossible.
4. **Resource Management:** Its core fixes, reducing CPU usage and fixing memory leaks, make the server more resilient
   overall, helping it handle higher loads without crashing, which is a form of mitigation in itself.

### Where It Falls Short (The Limitations):

A true, large-scale **D**DoS attack will overwhelm SAPP's protections:

* **No Volume-Based Mitigation:** SAPP's `packet_limit` works per IP. A sophisticated DDoS uses thousands of unique IP
  addresses (a botnet). SAPP will see each one as a separate "player" sending a "normal" amount of traffic and won't
  block them. The server's network port still gets saturated, causing a crash or lag for everyone.
* **Application Layer vs. Network Layer:** SAPP's protection works at the **application layer** (it understands Halo's
  protocol). It can't filter traffic at the **network layer**. It can't tell the difference between a legitimate game
  packet and a malicious garbage packet designed to fill your bandwidth; it just sees incoming data.
* **On-Server Only:** All protection is handled by the Halo process on your server itself. If the attack traffic is
  large enough, it can saturate your server's network card *before* SAPP even gets a chance to process the packets and
  decide to block them.

### Summary

| For This...                                                          | SAPP is...                                                           |
|----------------------------------------------------------------------|----------------------------------------------------------------------|
| **✅ Script Kiddies** using public flooding tools                     | **Excellent.** It will stop them cold.                               |
| **✅ Join Spammers** trying to crash the server with fake players     | **Excellent.** `antihalofp` is built for this.                       |
| **✅ RCON Brute-Forcers** trying to guess your password               | **Excellent.** The 4-strike rule is perfect.                         |
| **✅ Small, simple DoS attacks** from a single IP or a handful of IPs | **Very Good.** `packet_limit` handles this well.                     |
| **❌ Large-Scale DDoS** from a massive botnet (100s/1000s of IPs)     | **Not Sufficient.** It will not stop a saturated network connection. |

**Recommendations:**

1. **For most server hosts:** SAPP's protections are **enough**. They handle 99% of the "attacks" you'll ever see, which
   are usually just kids with basic tools.
2. **If you're a high-profile target:** (e.g., a popular scrim server, a tournament server), you **must** have
   additional protection:
    * Use a game server provider that offers **DDoS mitigation** at the network level.
    * Look into **proxy services** like Cloudflare (though setting this up for game traffic is complex and not supported
      by most standard proxies).
    * Ensure your **server host** has infrastructure to absorb and filter large-scale attacks.

**In short: SAPP's protection is far from rudimentary, it's expertly tailored for the specific threats a Halo server
faces. However, it is not a magic shield against a determined, well-resourced attacker with a large botnet.** You should
enable all its features (`packet_limit`, `antihalofp`, etc.) and consider them your essential first line of defense.