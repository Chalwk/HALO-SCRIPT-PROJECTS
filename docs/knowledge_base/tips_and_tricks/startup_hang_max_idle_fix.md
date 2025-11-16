Add this line to your SAPP `init.txt` (the one in the SAPP folder):

```
max_idle 1
```

This prevents the default 60-second idle/mapcycle behavior that commonly shows up as a 60s "hang" on boot.

* **SAPP docs - `max_idle` behavior:** SAPP’s `max_idle` sets how many seconds of server idle before SAPP restarts the
  mapcycle. The default is 60 seconds. Changing it to `1` makes that restart happen almost immediately instead of
  waiting 60s.
* **Where to put it:** SAPP/ Halo servers can use two `init.txt` files (one opened by the dedicated server at start, and
  another loaded when SAPP starts). Putting `max_idle 1` in the SAPP `init.txt` is recommend to avoid the 60s delay when
  SAPP finishes loading.

### Short caveats & notes

* `max_idle` affects how SAPP handles *idle* servers (mapcycle restarts). Setting it to `1` avoids the perceived startup
  pause, but if you rely on idle mapcycle behavior for other reasons you may want to test the change first.
* Make sure you edit the correct `init.txt` (the SAPP one) - some installs have two `init.txt` files (server vs. SAPP).