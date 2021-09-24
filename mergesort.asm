            .cdecls C,LIST,"msp430.h"
            .global MERGESORT,AVERAGE,COPY

            .text

MERGESORT   ;; MERGESORT: mergesort implementation
            ;;
            ;; Arguments: R4 - element size
            ;;            R5 - input list pointer
            ;;            R6 - output list pointer
            ;;            R7 - list length
            ;;
            ;; Uses:      none
            ;;
            ;; Internal:  R7 - start point (0)
            ;;            R8 - end point (end: length [r7])
            .asmfunc
            pushm.a #2, R8
            movx.a  R7, R8  ;; length == end, move to r8
            xorx.a  R7, R7  ;; r7 == start == 0, clear
            call    #MI
            popm.a  #2, R8
            ret
            .endasmfunc


MI          ;; MI: mergesort internal helper
            ;;
            ;; Arguments: R4 - element size
            ;;            R5 - input list pointer
            ;;            R6 - output list pointer
            ;;            R7 - start
            ;;            R8 - end
            ;;
            ;; Uses:      none
            ;;
            ;; Internal:  R9 - temp
            .asmfunc
            pushm.a #12,    R15     ;; SAVE r4 - r15

            ;; Check if we can return early
            movx.a  R8,     R9
            decx.a  R9              ;; r9 <-- end - 1
            cmpx.a  R7,     R9
            jnz     MI_BEGIN
            jmp     MI_END          ;; if (end - 1 == start), early return

            ;; Find the midpoint
MI_BEGIN    pushm.a #3,     R6      ;; SAVE r4, r5, r6
            movx.a  R7,     R5
            movx.a  R8,     R6
            call    #AVERAGE
            movx.a  R4,     R9      ;; r9 = average(start, end)(mid)
            popm.a  #3,     R6      ;; RESTORE r4, r5, r6

            ;; Sort the first half
            pushm.a #3,     R9      ;; SAVE r7, r8, r9
            movx.a  R9,     R8
            call    #MI             ;; mergesort(in_arr, out_arr, start, mid)
            popm.a  #3,     R9      ;; RESTORE r7, r8, r9

            ;; Sort the second half
            pushm.a #3,     R9      ;; SAVE r7, r8, r9
            movx.a  R9,     R7
            call    #MI             ;; mergesort(in_arr, out_arr, mid, end)
            popm.a  #3,     R9      ;; RESTORE r7, r8, r9

            ;; At this point (in theory), for the input array:
            ;;     [ start, mid ) is sorted
            ;;     [ mid,   end ) is sorted

            ;; Check if we're in word mode
            cmp.b   #16,    R4
            jnz     MI_GO

            ;; Double offsets in word mode
            rlax.a  R7
            rlax.a  R8
            rlax.a  R9

            ;; Setup pointers for main loop
MI_GO       movx.a  R6,     R10
            addx.a  R7,     R10     ;; r10 <-- next pointer(dest)

            movx.a  R9,     R11
            subx.a  R7,     R11     ;; r11 <-- left  size (bytes)
            movx.a  R8,     R12
            subx.a  R9,     R12     ;; r12 <-- right size (bytes)

            xorx.a  R13,    R13     ;; r13 <-- left  index (byte)
            xorx.a  R14,    R14     ;; r14 <-- right index (byte)

            ;; Main loop condition
MI_LP_CHK   cmpx.a  R13,    R11     ;; check left_index < left_size
            jne     MI_LP_L         ;; If we have remaining in left, go to main loop
            cmpx.a  R14,    R12     ;; If none in left, check right_index < right_size
            jeq     MI_COPY         ;; If we having none remaining in either, we're done

            ;; Check to see if we are out of lefts
MI_LP_L     cmpx.a  R13,    R11     ;; if so, pick a right directly
            jne     MI_LP_R         ;; else, perform same check on right
            movx.a  R5,     R15
            addx.a  R9,     R15
            addx.a  R14,    R15     ;; r15 <-- ptr to next right

            cmp.b   #16,    R4      ;; Check if in word mode
            jeq     MI_LP_L16

            ;; Copy right to destination (byte)
            movx.b  @R15,   0(R10)  ;; perform copy
            incx.a  R10             ;; increment dest addr
            incx.a  R14             ;; increment right index
            jmp     MI_LP_CHK

            ;; Copy right to destination (word)
MI_LP_L16   movx.w  @R15,   0(R10)  ;; perform copy
            incdx.a R10             ;; increment dest addr (by two!)
            incdx.a R14             ;; increment right index (by two!)
            jmp     MI_LP_CHK

            ;; Check to see if we are out of rights
MI_LP_R     cmpx.a  R14,    R12     ;; if so, pick a left directly
            jne     MI_LP_CMP       ;; else, we have to compare values
            movx.a  R5,     R15
            addx.a  R7,     R15
            addx.a  R13,    R15     ;; r15 <-- ptr to next left

            cmp.b   #16,    R4      ;; Check if in word mode
            jeq     MI_LP_R16

            ;; Copy left to destination (byte)
            movx.b  @R15,   0(R10)  ;; perform copy
            incx.a  R10             ;; increment dest addr
            incx.a  R13             ;; increment left index
            jmp     MI_LP_CHK

            ;; Copy left to destination (word)
MI_LP_R16   movx.w  @R15,   0(R10)  ;; perform copy
            incdx.a R10             ;; increment dest addr (by two!)
            incdx.a R13             ;; increment right index (by two!)
            jmp     MI_LP_CHK

            ;; We're not out of either, time to compare values
MI_LP_CMP   pushm.a #2,     R12     ;; Save r11 and r12 (subarray sizes)
                                    ;; We need these regs for val comparison

            ;; Get the next left
            movx.a  R5,     R11     ;; Src pointer
            addx.a  R7,     R11     ;; Start pos (byte) [left begin]
            addx.a  R13,    R11     ;; Current left index

            cmp.b   #16,    R4      ;; Check if we are in word mode
            jeq     MI_LPTR16
            movx.b  @R11,   R11     ;; Fetch left byte into r11
            jmp     MI_RPTR
MI_LPTR16   movx.w  @R11,   R11     ;; Fetch left word into r11

            ;; Get the next right
MI_RPTR     movx.a  R5,     R12     ;; Src pointer
            addx.a  R9,     R12     ;; Mid pos (byte) [right begin]
            addx.a  R14,    R12     ;; Current right index

            cmp.b   #16,    R4      ;; Check if we are in word mode
            jeq     MI_RPTR16
            movx.b  @R12,   R12     ;; Fetch right byte into r12
            jmp     MI_PTRS8
MI_RPTR16   movx.w  @R12,   R12     ;; Fetch right word into r12
            jmp     MI_PTRS16

            ;; Compare values (byte)
MI_PTRS8    cmp.b   R12,    R11
            jlo     MI_PICK_L8      ;; Left is less -- pick left
            jmp     MI_PICK_R8      ;; Otherwise-- pick right

            ;; Compare values (word)
MI_PTRS16   cmp.w   R12,    R11
            jlo     MI_PICK_L16     ;; Left is less -- pick left
            jmp     MI_PICK_R16     ;; Otherwise-- pick right

            ;; Copy left (byte)
MI_PICK_L8  movx.b  R11,    0(R10)  ;; Copy byte
            incx.a  R13             ;; Increment left index
            jmp     MI_RES_8

            ;; Copy right (byte)
MI_PICK_R8  movx.b  R12,    0(R10)  ;; Copy byte
            incx.a  R14             ;; Increment right index

            ;; Increment dest pointer, restore registers (byte)
MI_RES_8    incx.a  R10
            popm.a  #2,     R12
            jmp     MI_LP_CHK

            ;; Copy left (word)
MI_PICK_L16 movx.w  R11,    0(R10)  ;; Copy word
            incdx.a R13             ;; Increment left index (by two!)
            jmp     MI_RES_16

            ;; Copy right (word)
MI_PICK_R16 movx.w  R12,    0(R10)  ;; Copy word
            incdx.a R14             ;; Increment right index (by two!)

            ;; Increment dest pointer (by two!), restore registers (word)
MI_RES_16   incdx.a R10
            popm.a  #2,     R12
            jmp     MI_LP_CHK

            ;; We're done, copy dest back to source
MI_COPY     movx.a  R7,     R9      ;; Save start pos
            movx.a  R8,     R7
            subx.a  R9,     R7      ;; r7 <-- length (bytes)
            movx.a  R6,     R10     ;; Save dest ptr
            movx.a  R5,     R6
            movx.a  R10,    R5      ;; Swap src and dest ptrs for copying dst --> src
            addx.a  R9,     R5
            addx.a  R9,     R6      ;; Get correct start in both arrays by adding start
            call    #COPY

MI_END      popm.a  #12,    R15     ;; RESTORE r4 - r15
            ret
            .endasmfunc
