real-dcpu
=========

My effort to create an FPGA implementation of the dcpu computer from the hypothetical game 0x10c (http://0x10c.com).
When finished, the system is supposed to implement the specification found at http://dcpu.com with at least Keyboard, Screen and Clock as hardware devices (maybe some kind of floppy replacement, i.e. SD cards accessed in the same way as the floppy in the specification, but I have no idea yet if or how that would work). The result should be a fully usable (if somewhat retro) computer independent of other machines (otherwise I would just use an emulator) [I could probably also up the clock speed to a few MHz to make it more usable]

!!! the project is still very early in development so I haven't completely figured out the architecture for the system !!!
(also I'm not very experienced so both my development practices and my coding style are probably awful)

I own an Altera DE2-115 FPGA board so that is what I'm currently developing for, but I hope that in the future the project will be not-too-difficult to adapt to other fpga board types / chips.
As a consequence:
- I use Altera's Quartus II development environment (which is free by the way)
- to make proper use of the FPGA chip, I use their 'Megafunction' library to get access to the builtin RAM and multipliers
- the RAM modules can be configured to be dual-port which is immensly useful and I will definitely take advantage of that in the architecture
