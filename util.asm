            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .global AVERAGE,COPY,LED0_ON,LED0_OFF,VERIFY_SORT,POWER_DOWN

            .text

AVERAGE     ;; AVERAGE: finds the average of a and b
            ;; uses the floor if true answer is non-integer
            ;;
            ;; Arguments: R5 - a
            ;;            R6 - b
            ;;
            ;; Uses:      R4 - return value
            ;;
            ;; Internal:  R7 - temp
            .asmfunc
            pushm.a #3, R7          ;; SAVE R5, R6, R7

            cmpx.a  R6, R5          ;; if (b > a), we're good to go
            jn      AVG_LOOP

            ;; if (b <= a), need to swap b and a
SWAP        movx.a  R5, R7
            movx.a  R6, R5
            movx.a  R7, R6

AVG_LOOP    cmpx.a  R6, R5          ;; If we've met in the middle,
            jz      AVERAGE_END     ;; We're done, that's the avg
            decx.a  R6              ;; First, decrement B (floor)
            cmpx.a  R6, R5
            jz      AVERAGE_END
            incx.a  R5              ;; Next, increment A
            cmpx.a  R6, R5
            jz      AVERAGE_END
            jmp     AVG_LOOP        ;; Rinse and repeat

AVERAGE_END movx.a  R5, R4          ;; Copy average to R4 (R5 == R6)
            popm.a  #3, R7          ;; RESTORE R5, R6, R7
            ret
            .endasmfunc


COPY        ;; COPY: copies n bytes from a to b
            ;;
            ;; Arguments: R5 - a
            ;;            R6 - b
            ;;            R7 - n
            ;;
            ;; Uses:      none
            ;;
            ;; Internal:  R5 - src index
            ;;            R6 - dst index
            ;;            R7 - remaining (bytes)
            .asmfunc
            pushm.a #3, R7          ;; SAVE R5, R6, R7
            call    #LED0_ON        ;; "HDD Light" -- show activity

            tstx.a  R7              ;; If none remaining,
COPY_I      jz      COPY_D          ;; Done
            movx.b  @R5+, 0(R6)     ;; Perform byte copy & increment src index
            incx.a  R6              ;; Increment dst index
            decx.a  R7              ;; Decrement bytes remaining
            jmp     COPY_I          ;; Rinse and repeat

COPY_D      call    #LED0_OFF       ;; "HDD Light" off
            popm.a  #3, R7          ;; RESTORE R5, R6, R7
            ret
            .endasmfunc


VERIFY_SORT ;; VERIFY_SORT: check that a list is sorted
            ;;
            ;; Arguments: R5 - the list,
            ;;            R6 - list length,
            ;;            R7 - element size
            ;;
            ;; Uses:      SR - return value (Z)
            ;;
            ;; Internal:  R5 - cur list ptr
            ;;            R6 - remaining length
            ;;            R7 - element size
            ;;            R8 - el1
            ;;            R9 - el2
            ;;           R10 - cur list + 1 ptr
            .asmfunc
            pushm.a #6,     R10     ;; SAVE r5 - r10
            movx.a  R5,     R10

            cmp.b   #16,    R7      ;; Check if in word mode
            jeq     VS_S16

VS_S8       incx.a  R10             ;; Increment "+1" ptr
            jmp     VS_CHK
VS_S16      incdx.a R10             ;; Increment "+1" ptr (by two!) -- word mode

VS_CHK      decx.a  R6              ;; Decrease length by 1 (since we check two at a time)
            tstx.a  R6
            jz      VS_SUCCESS      ;; If we're at the end of the list w/o failing, we're done

            cmp.b   #16,    R7      ;; Check if in word mode
            jz      VS_CMP_16

            movx.b  @R5+,   R8      ;; Get [i] and increment(byte)
            movx.b  @R10+,  R9      ;; Get [i + 1] and increment(byte)
            cmp.b   R8,     R9
            jmp     VS_RESOLVE

VS_CMP_16   movx.w  @R5,    R8      ;; Get [i](word)
            movx.w  @R10,   R9      ;; Get [i + 1](word)
            incdx.a R5              ;; Increment src ptr (by two!)
            incdx.a R10             ;; Increment dst ptr (by two!)
            cmp.w   R8,     R9

VS_RESOLVE  jlo     VS_FAILURE      ;; If [i + 1] < [i], fail
            jmp     VS_CHK          ;; All else is ok

VS_SUCCESS  setz                    ;; SUCCESS = 0
            jmp     VS_DONE
VS_FAILURE  clrz                    ;; FAILURE = !0
VS_DONE     popm.a  #6,     R10     ;; RESTORE r5 - r10
            ret
            .endasmfunc


POWER_DOWN  ;; POWERDOWN: put the CPU into LPM4
            .asmfunc
            nop
            bis.w #GIE|CPUOFF|OSCOFF|SCG1|SCG0, SR
            nop
            ret
            .endasmfunc
