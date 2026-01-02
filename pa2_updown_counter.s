.global _start

//Constants
.equ SWITCH_BASE, 0xFF200040
.equ SEG_BASE,    0xFF200020
.equ KEY_BASE,    0xFF200050

_start:
//Addresses
    LDR r0, =SWITCH_BASE
    LDR r1, =SEG_BASE
    LDR r10, =KEY_BASE
    LDR r2, =SEG_PATTERNS
    
//Variables
    MOV r3, #0                   // Ones Digit (0-9)
    MOV r4, #0                   // Tens Digit (0-5)
    MOV r11, #1


MAIN_LOOP:

//DISPLAY UPDATE
    LDR r5, [r2, r3, LSL #2]     // Load Ones Pattern
    LDR r6, [r2, r4, LSL #2]     // Load Tens Pattern
    LSL r6, r6, #8               // Shift Tens to left
    ORR r8, r5, r6               // Combine
    STR r8, [r1]                 // Write to HEX Display


//DELAY & INPUT CHECK LOOP
    LDR r7, =500000             //Delay Counter

DELAY_CHECK:
    LDR r9, [r10]                // Read Keys

    //Check KEY0
    TST r9, #1                   // Check Bit 0
    BNE KEY0_HANDLER

    //Check KEY1
    TST r9, #2                   // Check Bit 1
    BNE KEY1_HANDLER

    //Check Pause
    CMP r11, #1                  // Are we Paused?
    BEQ DELAY_CHECK              // If YES, spin here forever

    //Decrement Timer
    SUBS r7, r7, #1
    BNE DELAY_CHECK


//COUNTING LOGIC
    LDR r9, [r0]                 // Read Switches
    TST r9, #1                   // Check SW0
    BNE COUNT_DOWN               // If SW0=1, Go Down

COUNT_UP:
    ADD r3, r3, #1               // Ones++
    CMP r3, #10
    BLT MAIN_LOOP                // If < 10, done
    
    MOV r3, #0                   // Reset Ones
    ADD r4, r4, #1               // Tens++
    CMP r4, #6
    BLT MAIN_LOOP                // If < 6, done
    
    MOV r4, #0                   // Reset Tens (59 -> 00)
    B MAIN_LOOP

COUNT_DOWN:
    SUBS r3, r3, #1              // Ones--
    BGE MAIN_LOOP                // If >= 0, done
    
    MOV r3, #9                   // Wrap Ones (0 -> 9)
    SUBS r4, r4, #1              // Tens--
    BGE MAIN_LOOP                // If >= 0, done
    
    MOV r4, #5                   // Wrap Tens (00 -> 59)
    B MAIN_LOOP

//BUTTON HANDLERS
KEY0_HANDLER:  // Start/Stop
    BL  DEBOUNCE_WAIT            // Wait for stable press
    EOR r11, r11, #1             // Flip State (0->1 or 1->0)
    B   DELAY_CHECK

KEY1_HANDLER:  //Reset
    BL  DEBOUNCE_WAIT            // Wait for stable press
    MOV r3, #0                   // Reset Counters
    MOV r4, #0
    B   MAIN_LOOP                


DEBOUNCE_WAIT:
    PUSH {r0, r9, lr}
    
//Wait 20ms (Debounce noise)
    LDR r0, =20000
d_loop: SUBS r0, r0, #1
    BNE d_loop

//B. Wait for Release
r_loop: LDR r9, [r10]
    TST r9, #3                   // Check if ANY key is still down
    BNE r_loop
    
    POP {r0, r9, pc}

//7Segment
.align 2
SEG_PATTERNS:
    .word 0x3F  // 0: abcdef
    .word 0x06  // 1: bc
    .word 0x5B  // 2: abdeg
    .word 0x4F  // 3: abcdg
    .word 0x66  // 4: bcfg
    .word 0x6D  // 5: acdfg
    .word 0x7D  // 6: acdefg
    .word 0x07  // 7: abc
    .word 0x7F  // 8: abcdefg
    .word 0x6F  // 9: abcdfg
    .word 0x77  // A: abcefg
    .word 0x7C  // b: cdefg
    .word 0x39  // C: adef
    .word 0x5E  // d: bcdeg
    .word 0x79  // E: adefg
    .word 0x71  // F: aefg

.end