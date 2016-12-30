
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include <util/delay.h>

char duty_cycle = 0;

int main(void)
{
	DDRB |= _BV(PINB2);
	TCCR0A |= _BV(COM0A1) | _BV(WGM00) | _BV(WGM01);
	// TIMSK0 |= _BV(TOIE0);

	char duty_cycle = 0;
	bool counting_up = true;

	OCR0A = duty_cycle * 255 / 100;

	// sei();

	TCCR0B |= _BV(CS00); // | _BV(CS01);

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

// ISR(TIM0_OVF_vect)
// {
// 	OCR0A = duty_cycle * 255 / 100;
// }