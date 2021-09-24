			.cdecls C,LIST,"msp430.h"       ; Include device header file
			.global AVERAGE,COPY,LED0_ON,LED0_OFF

			.text

AVERAGE     ;; AVERAGE: finds the average of a and b
			;; uses the floor if true answer is non-integer
			;;
			;; Arguments: r5 - a, r6 - b
			;; Uses: r4 - return value
			;;
			;; Internal: r7 - temp
			.asmfunc
			pushm.a	#3,	r7

			cmpx.a	r6, r5
			jn		AVG_LOOP

SWAP		movx.a	r5, r7
			movx.a	r6, r5
			movx.a	r7, r6

AVG_LOOP	cmpx.a	r6, r5
			jz 		AVERAGE_END
			decx.a	r6
			cmpx.a 	r6, r5
			jz		AVERAGE_END
			incx.a	r5
			cmpx.a	r6, r5
			jz		AVERAGE_END
			jmp		AVG_LOOP

AVERAGE_END movx.a	r5, r4
			popm.a	#3,	r7
			ret
			.endasmfunc


COPY		;; COPY: copies n bytes from a to b
			;;
			;; Arguments: r5 - a, r6 - b, r7 - n
			;; Uses: none
			;;
			;; Internal:
			.asmfunc
			pushm.a	#3,	r7
			call	#LED0_ON

			tstx.a	r7
COPY_I		jz		COPY_D
			movx.b	@r5+, 0(r6)
			incx.a	r6
			decx.a	r7
			jmp		COPY_I

COPY_D		call	#LED0_OFF
			popm.a	#3, r7
			ret
			.endasmfunc
