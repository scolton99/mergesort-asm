			.cdecls C,LIST,"msp430.h"
			.global MERGESORT,AVERAGE,COPY

			.text

MERGESORT	;; MERGESORT: sorts a list
			;;
			;; Arguments: r5 - input list, r6 - output list, r7 - list length, r8 - element size (bits),
			;; Uses: none
			;;
			;; Internal: none
			.asmfunc
			cmp.b	#8,  r8 	;; Check to see if we have a byte list
			jnz		MS_TRYW	;; If not, try another size
			call	#M8			;; Otherwise, handle 8-bit mergesort
			jmp		MS_END

MS_TRYW		cmp.b	#16, r8		;; Check to see if we have a word list
			jnz		MS_END		;; If not, we failed, return
			call	#M16		;; Otherwise, handle 16-bit mergesort

MS_END		ret
			.endasmfunc

M8			;; M8: mergesort for byte lists
			;;
			;; Arguments: r5 - input list pointer, r6 - output list pointer, r7 - list length
			;; Uses: none
			;;
			;; Internal:
			.asmfunc
			movx.a	r7, r8
			xorx.a	r7, r7
			call	#M8_I
			ret
			.endasmfunc

M8_I		;; M8_I: mergesort internal helper (byte)
			;;
			;; Arguments: r5 - input list pointer, r6 - output list pointer, r7 - start, r8 - end
			;; Uses: none
			;;
			;; Internal: r9 - temporary
			.asmfunc
			pushm.a	#11,	r15	;; SAVE r5, r6

			movx.a	r8, 	r9
			decx.a	r9
			cmpx.a	r7, 	r9
			jnz 	M8_BEGIN
			jmp		M8_END		;; if (end - 1 == start): early return

M8_BEGIN	pushm.a	#2, 	r6	;; SAVE r5, r6
			movx.a	r7, 	r5
			movx.a	r8, 	r6
			call	#AVERAGE
			movx.a	r4, 	r9	;; r9 = average(start, end)		(mid)
			popm.a	#2, 	r6

			pushm.a	#3,		r9	;; SAVE r7, r8, r9
			movx.a	r9, 	r8
			call	#M8_I		;; mergesort(in_arr, out_arr, start, mid)
			popm.a	#3,		r9

			pushm.a	#3,		r9	;; SAVE r7, r8, r9
			movx.a	r9,		r7
			call	#M8_I		;; mergesort(in_arr, out_arr, mid, end)
			popm.a	#3,		r9

			;; At this point (in theory), for the input array:
			;;     [ start, mid ) is sorted
			;;     [ mid,   end ) is sorted

			movx.a	r6, 	r10
			addx.a	r7,		r10	;; r10 <-- next pointer	(dest)

			movx.a	r9,		r11
			subx.a	r7,		r11	;; r11 <-- left size
			movx.a	r8,		r12
			subx.a	r9,		r12	;; r12 <-- right size

			xorx.a	r13,	r13	;; r13 <-- left index
			xorx.a	r14,	r14	;; r14 <-- right index

M8_LP_CHK	cmpx.a	r13,	r11 ;; check left_index < left_size || right_index < right_size
			jne		M8_LP
			cmpx.a	r14,	r12
			jeq		M8_COPY

M8_LP		cmpx.a	r13, 	r11	;; if we are out of lefts, pick a right
			jne		M8_LP_R
			movx.a	r5,		r15
			addx.a	r9, 	r15
			addx.a	r14,	r15	;; r15 <-- ptr to next right
			movx.b	@r15,	0(r10)	;; perform copy
			incx.a	r10			;; increment dest addr
			incx.a	r14			;; increment right index
			jmp 	M8_LP_CHK

M8_LP_R		cmpx.a	r14,	r12	;; if we are out rights, pick a left
			jne		M8_LP_CMP
			movx.a	r5,		r15
			addx.a	r7,		r15
			addx.a	r13,	r15 ;; r15 <-- ptr to next left
			movx.b	@r15,	0(r10)  ;; perform copy
			incx.a	r10			;; increment dest addr
			incx.a	r13			;; increment left index
			jmp		M8_LP_CHK

M8_LP_CMP	pushm.a	#2,		r12

			movx.a	r5,		r11
			addx.a	r7,		r11
			addx.a	r13,	r11
			movx.b	@r11,	r11	;; r11 <-- in_arr[next_left]

			movx.a	r5,		r12
			addx.a	r9,		r12
			addx.a	r14,	r12
			movx.b	@r12,	r12 ;; r12 <-- in_arr[next_right]

			cmp.b	r12, 	r11
			jlo		M8_PICK_L
			jmp		M8_PICK_R

M8_PICK_L	movx.b	r11,	0(r10)
			incx.a	r13
			jmp		M8_RESOLVE
M8_PICK_R	movx.b	r12,	0(r10)
			incx.a	r14
M8_RESOLVE	incx.a	r10
			popm.a	#2,		r12
			jmp		M8_LP_CHK

M8_COPY		movx.a	r7,		r9	;; save start pos
			movx.a	r8,		r7	;; r7 <-- end
			subx.a	r9,		r7	;; r7 <-- end - start
			movx.a	r6,		r10	;; save dest ptr
			movx.a	r5,		r6
			movx.a	r10,	r5	;; swap src and dest ptrs for copying
								;; copying dst --> src
			addx.a	r9,		r5
			addx.a	r9,		r6	;; add start to both ptrs
			call	#COPY

M8_END		popm.a	#11,	r15
			ret
			.endasmfunc

M16			;; M16: mergesort for word lists
			;;
			;; Arguments: r5 - input list pointer, r6 - output list pointer, r7 - list length
			;; Uses: none
			;;
			;; Internal: none
			.asmfunc
			ret
			.endasmfunc
