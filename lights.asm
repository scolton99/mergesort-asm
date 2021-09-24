            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .global LED0_ON,LED1_ON,LED0_OFF,LED1_OFF

            .text

LED0_ON     ;; LED0_ON: turn on LED 0
            .asmfunc
            bis.b   #BIT0,  &P1OUT
            ret
            .endasmfunc


LED1_ON     ;; LED1_ON: turn on LED 1
            .asmfunc
            bis.b   #BIT1,  &P1OUT
            ret
            .endasmfunc


LED0_OFF    ;; LED0_OFF: turn off LED 0
            .asmfunc
            bic.b   #BIT0,  &P1OUT
            ret
            .endasmfunc


LED1_OFF    ;; LED1_OFF: turn off LED 1
            .asmfunc
            bic.b   #BIT1,  &P1OUT
            ret
            .endasmfunc
