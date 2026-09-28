#include "io.h"
#include <stdio.h>
#include "system.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "altera_avalon_timer_regs.h"
#include "altera_avalon_timer.h"

#define HEX0_REG (*(volatile unsigned int *)HEX0_BASE)
#define KEY_REG  (*(volatile unsigned int *)PUSHBUTTONS_BASE)
#define SW_REG   (*(volatile unsigned int *)SWITCHES_BASE)
static const unsigned char hex0[10] = {0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00, 0x10};
#define KEY1_MASK 0x2
#define SW0_MASK  0x1
int index = 0;


void key_isr(void *context){
	KEY_REG = 1;
    HEX0_REG = hex0[index];

	unsigned int key_state = KEY_REG;

	if ((key_state & KEY1_MASK) == 0) {
		unsigned int sw_state = SW_REG;

		if (sw_state & SW0_MASK) {
			if (index < 9){
				index++;
			}
		}
		else {
			if (index > 0){
				index--;
			}
		}

		HEX0_REG = hex0[index];
	}

    return;
}

int main(void) {
	HEX0_REG = hex0[index];
	
	alt_ic_isr_register(PUSHBUTTONS_IRQ_INTERRUPT_CONTROLLER_ID, PUSHBUTTONS_IRQ, key_isr, 0, 0);
	
	while(1);
    return 0;
}
