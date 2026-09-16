.section .text

.equ HEX0_BASE, 0x11000
.equ SWITCHES_BASE, 0x11020
.equ PUSHBUTTONS_BASE, 0x11010

.global main
.type main, function

main:
    movia   r2, HEX0_BASE	   # load the hex0 PIO base address into r2
    movia   r3, PUSHBUTTONS_BASE
    movia   r4, SWITCHES_BASE
    movi    r5, 0x40           # segment pattern for digit '0' (active-low)
    stwio   r5, 0(r2)          # store the pattern to the hex0 PIO register

loop:
	ldwio	r6, 0(r3)
	cmp		r6, 0
	br loop

