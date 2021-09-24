;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .global MERGESORT,INPUT_ARR,OUTPUT_ARR,ARR_SIZE,EL_SIZE,LED0_ON,LED1_ON

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
			and.w 	#~LOCKLPM5,&PM5CTL0						; Turn off high-impedance mode
			mov.w	#0,&P1OUT
			mov.w	#BIT1|BIT0,&P1DIR						; Setup LED output

			movx.a	#INPUT_ARR,		r5
			movx.a	#OUTPUT_ARR,	r6
			movx.a	&ARR_SIZE,		r7
			movx.b	&EL_SIZE,		r8
			call	#MERGESORT

			movx.a	#OUTPUT_ARR,	r5
			movx.w	&ARR_SIZE,		r6
			call	#VERIFY_SORT

			jz		SUCCESS
			call	#LED0_ON
			jmp 	AEND
SUCCESS		call	#LED1_ON
AEND		nop
			jmp		AEND


VERIFY_SORT	;; VERIFY_SORT: check that a list is sorted
			;;
			;; Arguments: r5 - the list, r6 - list length
			;; Uses: SR(Z) to return a value
			;;
			;; Internal:
			.asmfunc
			pushm.a		#5,		r9
			movx.a		r5, 	r7
			incx.a		r7

VS_CHK		decx.a		r6
			tstx.a		r6
			jz			VS_SUCCESS

			movx.b		@r5+,	r8
			movx.b		@r7+,	r9

			cmp.b		r8,		r9
			jlo			VS_FAILURE
			jmp			VS_CHK

VS_SUCCESS	setz
			jmp 		VS_DONE
VS_FAILURE	clrz
VS_DONE		popm.a		#5,		r9
			ret
			.endasmfunc

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
            
