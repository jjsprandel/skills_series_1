// Flashing the LED with Timer_A, up mode, via polling
#include "/opt/ti/ccs/ccs_base/msp430/include/msp430fr6989.h"
#define redLED BIT0 // Red LED at P1.0
#define greenLED BIT7 // Green LED at P9.7

void main(void) {
    // Stop the Watchdog timer
    WDTCTL = WDTPW | WDTHOLD; // Stop the Watchdog timer
    // Unlock the GPIO pins
    PM5CTL0 &= ~LOCKLPM5; // Enable the GPIO pins
    // Configure the LEDs as output
    P1DIR |= redLED; // Direct pin as output
    P9DIR |= greenLED; // Direct pin as output
    P1OUT &= ~redLED; // Turn LED Off
    P9OUT &= ~greenLED; // Turn LED Off
    // Configure ACLK to the 32 KHz crystal (function call)
    void config_ACLK_to_32KHz_crystal();
    // Configure Timer_A
    /// Flashing the red LED with Timer_A, up mode, via polling
    TA0CCR0 = 32678-1;
    TA0CTL = TASSEL_1 | ID_0 | MC_1 | TACLR;
    // Ensure flag is cleared at the start
    TA0CTL &= ~TAIFG;
    // Infinite loop
    for(;;) {
        // Wait in this empty loop for the flag to raise
        while((TA0CTL & TAIFG) == 0 ) {}
        // Do the action here
        P1OUT ^= redLED;
        TA0CTL &= ~TAIFG;
    }
}

// Configures ACLK to 32 KHz crystal
void config_ACLK_to_32KHz_crystal() {
    // By default, ACLK runs on LFMODCLK at 5MHz/128 = 39 KHz
    // Reroute pins to LFXIN/LFXOUT functionality
     PJSEL1 &= ~BIT4;
     PJSEL0 |= ~BIT4;
    // Wait until the oscillator fault flags remain cleared
     CSCTL0 = CSKEY; // Unlock CS registers
     do {
     CSCTL5 &= ~LFXTOFFG; // Local fault flag
     SFRIFG1 &= ~OFIFG; // Global fault flag
     } while((CSCTL5 & LFXTOFFG) != 0);
     CSCTL0_H = 0; // Lock CS registers
    return;
}
