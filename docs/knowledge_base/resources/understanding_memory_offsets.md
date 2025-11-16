To effectively manipulate game behavior, it is crucial to understand how to locate and utilize memory addresses and
offsets.

Here is a breakdown:

* **Memory Address**: A specific location in the game's memory where data is stored.
* **Offset**: A value added to a base address to reach a particular data point.

For example, if a base address is `0x40440000`, and an offset is `0x28`, the target address would be `0x40440028`.

See [Kavawuvi](https://opencarnage.net/index.php?/topic/6693-halo-map-file-structure-revision-212/#comment-88743)'s post
on OpenCarnage for more information.

---

# Tools for Finding Offsets

Here are some tools commonly used in the Halo PC/CE modding community:

* **Cheat Engine**: A powerful tool for scanning and modifying memory addresses in real-time.
* **IDA Pro**: A disassembler and debugger for analyzing executable files.
* **Halo Map Tools 3**: A utility that simplifies the process of finding and modifying offsets within Halo maps.

# Tutorials and Resources

To get started with finding and using offsets in Halo PC/CE, consider the following resources:

* **[How To Find Offsets, Entity Addresses & Pointers - YouTube](https://www.youtube.com/watch?v=YaFlh2pIKAg)**: A video
  tutorial that walks through the process of locating offsets using Cheat Engine.
* *
  *[Tutorial: Finding Offsets Using Cheat Engine - UnKnoWnCheaTs](https://www.unknowncheats.me/forum/general-programming-and-reversing/200702-finding-offsets-using-cheat-engine.html)
  **: A comprehensive guide on using Cheat Engine to find memory offsets.
* **[Halo Map Tools 3 - Bungie Forums](https://forums.bungie.org/halo/archive13.pl?read=390998)**: A discussion on using
  Halo Map Tools 3 for offset manipulation.

---

# Practical Tips

* **Start with Known Values**: Identify a value in the game that you can search for, such as health or ammo count.
* **Use Cheat Engine's Scanning Features**: Utilize the "First Scan" and "Next Scan" functions to narrow down potential
  addresses.
* **Pointer Scanning**: Once you find a value, use pointer scanning to locate the base address and its offsets.