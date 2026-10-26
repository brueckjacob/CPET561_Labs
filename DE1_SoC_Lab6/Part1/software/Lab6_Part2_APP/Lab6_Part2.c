#include "system.h"

volatile unsigned int *key_ptr 		= (unsigned int*) PUSHBUTTONS_BASE;
volatile unsigned char *led_ptr 	= (volatile unsigned char*) LEDS_BASE;

void ram_test_8(unsigned int first_addr, unsigned int num_bytes, unsigned int test_data)
{
	volatile unsigned char *ram_ptr = (volatile unsigned char*) first_addr;
	unsigned char		   expected = (unsigned char) test_data;
	unsigned int		   i;

	for (i = 0; i < num_bytes; i++)
	{
		ram_ptr[i] = expected;
	}

	for (i = 0; i < num_bytes; i++)
	{
		if (ram_ptr[i] != expected)
		{
			*led_ptr = 0xFF;
		}
	}
}

void ram_test_16(unsigned int first_addr, unsigned int num_bytes, unsigned int test_data)
{
	volatile unsigned short *ram_ptr = (volatile unsigned short*) first_addr;
	unsigned short		    expected = (unsigned short) test_data;
	unsigned int		    i;

	for (i = 0; i < num_bytes / 2; i++)
	{
		ram_ptr[i] = expected;
	}

	for (i = 0; i < num_bytes / 2; i++)
	{
		if (ram_ptr[i] != expected)
		{
			*led_ptr = 0xFF;
		}
	}
}

void ram_test_32(unsigned int first_addr, unsigned int num_bytes, unsigned int test_data)
{
	volatile unsigned int  *ram_ptr = (volatile unsigned int*) first_addr;
	unsigned int		   expected = (unsigned int) test_data;
	unsigned int		   i;

	for (i = 0; i < num_bytes / 4; i++)
	{
		ram_ptr[i] = expected;
	}

	for (i = 0; i < num_bytes / 4; i++)
	{
		if (ram_ptr[i] != expected)
		{
			*led_ptr = 0xFF;
		}
	}
}

int main(void)
{
	*led_ptr = 0x00;

	ram_test_32(INFERRED_RAM_BASE, 16384, 0x12345678);

	while(1);
	return 0;
}
