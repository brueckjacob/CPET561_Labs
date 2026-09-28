#include <stdio.h>
#include "system.h"

#define HEX0_REG (*(volatile unsigned int *)HEX0_BASE)
#define KEY_REG  (*(volatile unsigned int *)PUSHBUTTONS_BASE)
#define SW_REG   (*(volatile unsigned int *)SWITCHES_BASE)
static const unsigned char hex0[10] = {0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00, 0x10};
#define KEY1_MASK 0x2
#define SW0_MASK  0x1

int main(void) {
    int index = 0;
    HEX0_REG = hex0[index];

    while(1) {
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

            while ((KEY_REG & KEY1_MASK) == 0){

            }
        }
    }

    return 0;
}
