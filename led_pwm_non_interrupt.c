
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include <util/delay.h>

#include "pwm.h"

int main(void)
{
	SET_PWM_DDR;
	SET_TCCR_COM;
	SET_TCCR_WGM;

	char duty_cycle = 0;
	bool counting_up = true;

	OCR0A = duty_cycle * 255 / 100;

	SET_TCCR_CLOCK;

	while(1)
	{
		_delay_ms(100);

		if (counting_up)
		{
			duty_cycle += 10;

			if (duty_cycle >= 100) counting_up = false;
		}
		else
		{
			duty_cycle -= 10;

			if (duty_cycle <= 0) counting_up = true;
		}

		OCR0A = duty_cycle * 255 / 100;
	}

	return 0;
}