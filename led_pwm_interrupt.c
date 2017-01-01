
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include <util/delay.h>

#include "pwm.h"

char duty_cycle = 0;

int main(void)
{
	SET_PWM_DDR;
	SET_TCCR_COM;
	SET_TCCR_WGM;
	SET_TIMER_MASK;

	SET_OCR(duty_cycle * 255 / 100);

	sei();

	SET_TCCR_CLOCK;

	bool counting_up = true;

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
	}

	return 0;
}

ISR(TIM0_OVF_vect)
{
	SET_OCR(duty_cycle * 255 / 100);
}