;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"           ; Include device header file
            .global MERGESORT,INPUT_ARR,OUTPUT_ARR,ARR_SIZE,EL_SIZE
            .global LED0_ON,LED1_ON,VERIFY_SORT,POWER_DOWN,SETUP

;-------------------------------------------------------------------------------
            .def    RESET                       ; Export program entry-point to
                                                ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                               ; Assemble into program memory.
            .retain                             ; Override ELF conditional linking
                                                ; and retain current section.
            .retainrefs                         ; And retain any sections that have
                                                ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,   SP          ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD, &WDTCTL     ; Stop watchdog timer
            call    #SETUP
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
            movx.b  &EL_SIZE,       R4
            movx.a  #INPUT_ARR,     R5
            movx.a  #OUTPUT_ARR,    R6
            movx.a  &ARR_SIZE,      R7
            call    #MERGESORT                  ; mergesort(el_size, in_arr, out_arr, arr_size)

            movx.a  #OUTPUT_ARR,R5
            movx.w  &ARR_SIZE,R6
            movx.b  &EL_SIZE,R7
            call    #VERIFY_SORT                ; verify_sort(arr, arr_size, el_size)

            jz      SUCCESS
            call    #LED0_ON                    ; Turn on the red LED -- failed
            jmp     AEND
SUCCESS     call    #LED1_ON                    ; Turn on the green LED -- success
AEND        call    #POWER_DOWN

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
