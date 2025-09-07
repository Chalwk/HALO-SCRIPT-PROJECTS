### 🎨 SAPP Console Color Tutorial (`cprint` / `set_ccolor`)

Understanding how to use colors in SAPP's console and messages can make your server logs, automated messages, and scripts much more readable and organized. The system is based on the classic Windows console color attributes.

---

#### **1. The Basics: The Color Number**

The color is defined by a single number. This number is calculated by combining a **Foreground** color and a **Background** color.

The formula is:
`Color Number = Foreground_Color + (Background_Color * 16)`

*   The **Foreground** is the color of the text itself. Its value can be from **0 to 15**.
*   The **Background** is the color behind the text. Its value can also be from **0 to 15**, but you must multiply it by 16 before adding it to the foreground.

**Example:**
*   You want **Green text (Foreground 10)** on a **Black background (Background 0)**.
    *   Calculation: `10 + (0 * 16) = 10`
    *   So, `cprint("Hello", 10)` prints green text.

*   You want **Red text (Foreground 12)** on a **Light Aqua background (Background 11)**.
    *   Calculation: `12 + (11 * 16) = 12 + 176 = 188`
    *   So, `cprint("Warning!", 188)` prints red text on a light blue background.

---

#### **2. The Color Code Table**

Here are all the possible values for the foreground and background. The "Value" is the number you use in the formula above.

| Color Name       | Value | Example & Code                |
|------------------|:-----:|-------------------------------|
| **Black**        |   0   | `cprint("text", 0)`           |
| **Dark Blue**    |   1   | `cprint("text", 1)`           |
| **Dark Green**   |   2   | `cprint("text", 2)`           |
| **Dark Aqua**    |   3   | `cprint("text", 3)`           |
| **Dark Red**     |   4   | `cprint("text", 4)`           |
| **Dark Purple**  |   5   | `cprint("text", 5)`           |
| **Dark Yellow**  |   6   | `cprint("text", 6)`           |
| **Light Gray**   |   7   | `cprint("text", 7)` (Default) |
| **Gray**         |   8   | `cprint("text", 8)`           |
| **Blue**         |   9   | `cprint("text", 9)`           |
| **Green**        |  10   | `cprint("text", 10)`          |
| **Aqua**         |  11   | `cprint("text", 11)`          |
| **Red**          |  12   | `cprint("text", 12)`          |
| **Light Purple** |  13   | `cprint("text", 13)`          |
| **Yellow**       |  14   | `cprint("text", 14)`          |
| **White**        |  15   | `cprint("text", 15)`          |

*Note: The background colors use these same values, just multiplied by 16.*

---

#### **3. How to Use It**

**A) In Lua Scripts with `cprint`**
The `cprint` function sends a colored message to the **server's console**. It's perfect for logging script events.
```lua
cprint("Script loaded successfully!", 10) -- Green success message
cprint("Player connected.", 14) -- Yellow connection message
cprint("ERROR: Invalid command!", 12 + (14*16)) -- Red text on Yellow background (Value: 236)
```

**B) With the `set_ccolor` Command**
This command changes the default color of the **entire server console** until it's changed again or the server restarts. This is done from the console or RCON.
```
set_ccolor 11
```
The above command would set the entire console to **Aqua text on a Black background**.

---

#### **4. Common Color Combinations & Tips**

*   **Success:** Green (`10`)
*   **Info / Notification:** Aqua (`11`) or Yellow (`14`)
*   **Warning:** Yellow (`14`) on Black (`0`) -> `14`
*   **Error / Alert:** Red (`12`)
*   **Admin Message:** Light Purple (`13`)
*   **Debug Data:** Gray (`8`)

**Pro Tip:** Avoid using high-intensity background colors (like White `15`) for large blocks of text, as it can be hard to read. Use them sparingly for important warnings.

**Resetting:** If you change the console with `set_ccolor` and want to go back to the default (Light Gray on Black), use `set_ccolor 7`.

---