#include "system.h"
#include "sys/alt_irq.h"

#define SERVO_IRQ         CUSTOM_SERVO_IP_0_IRQ
#define SERVO_IRQ_IC_ID   CUSTOM_SERVO_IP_0_IRQ_INTERRUPT_CONTROLLER_ID
#define KEY_IRQ           PUSHBUTTONS_IRQ
#define KEY_IRQ_IC_ID     PUSHBUTTONS_IRQ_INTERRUPT_CONTROLLER_ID

volatile unsigned int *servo_ptr = (unsigned int *) CUSTOM_SERVO_IP_0_BASE;
volatile unsigned int *key_ptr   = (unsigned int *) PUSHBUTTONS_BASE;
volatile unsigned int *sw_ptr    = (unsigned int *) SWITCHES_BASE;
volatile unsigned int *hex0_ptr  = (unsigned int *) HEX0_BASE;
volatile unsigned int *hex1_ptr  = (unsigned int *) HEX1_BASE;
volatile unsigned int *hex2_ptr  = (unsigned int *) HEX2_BASE;
volatile unsigned int *hex4_ptr  = (unsigned int *) HEX4_BASE;
volatile unsigned int *hex5_ptr  = (unsigned int *) HEX5_BASE;

#define MIN_REG       0
#define MAX_REG       1
#define PIO_DATA      0
#define PIO_IRQ_MASK  2
#define PIO_EDGE_CAP  3
#define ANGLE_LOW     45
#define ANGLE_HIGH    135
#define MIN_ANGLE_TOP 99

static const unsigned char seg7[10] = {0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00, 0x10};

#define KEY3_MASK     0x8
#define KEY2_MASK     0x4
#define SEG_BLANK     0x7F

static volatile int min_angle       = ANGLE_LOW;
static volatile int max_angle       = ANGLE_HIGH;
static volatile int display_update  = 1;

static unsigned int angle_to_count(int angle)
{
  return (unsigned int)(angle * 50000/90 + 25000);
}

static int clamp(int value, int low, int high)
{
  if (value < low)  return low;
  if (value > high) return high;
  return value;
}

static void servo_write_limits(void)
{
  *(servo_ptr + MIN_REG) = angle_to_count(min_angle);
  *(servo_ptr + MAX_REG) = angle_to_count(max_angle);
}

// ISRs
static void key_isr(void *context){
	unsigned int edges  = *(key_ptr + PIO_EDGE_CAP);
  int switches        = *(sw_ptr + PIO_DATA) & 0xFF;
  *(key_ptr + PIO_EDGE_CAP) = edges;

	if (edges & KEY3_MASK) {
    min_angle       = clamp(switches, ANGLE_LOW, MIN_ANGLE_TOP);
    display_update  = 1;
  }
  if (edges & KEY2_MASK) {
    max_angle       = clamp(switches, ANGLE_LOW, ANGLE_HIGH);
    display_update  = 1;
  }
    return;
}

static void servo_isr(void *context)
{
  servo_write_limits();
}

// display
static void update_display(void)
{
  int min = min_angle;
  int max = max_angle;
  
  *hex5_ptr = seg7[min / 10];
  *hex4_ptr = seg7[min % 10];
  *hex2_ptr = seg7[max / 100];
  *hex1_ptr = seg7[(max / 10) % 10];
  *hex0_ptr = seg7[max % 10];
}

// main
int main(void)
{
  servo_write_limits();
  
  *(key_ptr + PIO_EDGE_CAP) = 0xF;
  *(key_ptr + PIO_IRQ_MASK) = KEY3_MASK | KEY2_MASK;
  
  alt_ic_isr_register(KEY_IRQ_IC_ID,   KEY_IRQ,   key_isr, NULL, NULL);
  alt_ic_isr_register(SERVO_IRQ_IC_ID, SERVO_IRQ, servo_isr,      NULL, NULL);
  
  while (1) {
    if (display_update) {
      display_update = 0;
      update_display();
    }
  }
  
  return 0;
}
