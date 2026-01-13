# Atari Breakout Arcade Game 🎮

## Course
EL2003 – Computer Organization & Assembly Language  
FAST-NUCES | Fall 2025

## Project Overview
This project is a faithful recreation of the classic **Atari Breakout**
arcade game, implemented entirely in **16-bit x86 Assembly Language**
for DOS.

The game demonstrates low-level programming concepts including
interrupt handling, direct memory access, real-time graphics,
and hardware interaction.

---

## Key Features
- Full brick-breaking gameplay
- Real-time score, lives, and timer
- Ball physics and collision detection
- Keyboard-controlled paddle
- Sound effects using PC speaker
- Win and Game Over screens

---

## Technical Highlights
- 100% x86 Assembly (Real Mode)
- Keyboard Interrupt (INT 09h)
- Timer Interrupt (INT 08h)
- Direct video memory access
- Custom sound system via port 61h
- Proper ISR preservation and restoration

---

## Controls
- ⬅️ Left Arrow – Move paddle left
- ➡️ Right Arrow – Move paddle right
- ESC – Exit game

---

## How to Run
1. Open DOSBox
2. Mount project folder
3. Assemble and link:
   ```asm
   tasm breakout.asm
   tlink breakout.obj
   breakout.exe
