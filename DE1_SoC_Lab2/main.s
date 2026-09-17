.section .data
HEX0:
    byte 0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x2, 0x78, 0x0, 0x18


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

get_button:
	ldwio	r6, 0(r3)
    andi    r7, r6, 0x2
	bne     r7, r0, get_button

get_switch:
    ldwio   r6, 0(r4)
    andi    r7, r6, 0x1
    beq     r7, r0, decrement_path

