# COE513-PA2
Mechanical Switch bounce occurs when a button is pressed, causing the contacts to not close instantly but instead bounce or vibrate apart. To a high-speed processor, it is interpreted as multiple button presses.
Active-LOW means the default state of the button is a Logic 1 (High Voltage), and pressing the button pulls the signal down to Logic 0 (Low Voltage/Ground). By logic, it behaves like a normally closed switch (ON by default).
Software debouncing detects a signal change and then pauses execution for a short delay, allowing the physical bouncing to stop. It cancels out all the unnecessary multiple presses.

Debouncing is important to filter out electrical noise from mechanical contacts. Without it, the processor would interpret a single physical press as dozens of rapid on/off signals.
I implemented a Delay + Wait-for-Release method, using a delay loop to let the signal settle, followed by a loop that blocks execution until the key is released to prevent auto-repeating

Youtube Link: https://youtu.be/Q3_CmWNkPag
