	.build_version macos, 15, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_reduce_seq                     ; -- Begin function reduce_seq
	.p2align	2
_reduce_seq:                            ; @reduce_seq
	.cfi_startproc
; %bb.0:
	cmp	w1, #1
	b.lt	LBB0_3
; %bb.1:
	mov	w9, w1
	cmp	w1, #3
	b.hi	LBB0_4
; %bb.2:
	mov	x10, #0                         ; =0x0
	mov	w8, #0                          ; =0x0
	b	LBB0_13
LBB0_3:
	mov	w8, #0                          ; =0x0
	mov	x0, x8
	ret
LBB0_4:
	cmp	w1, #16
	b.hs	LBB0_6
; %bb.5:
	mov	x10, #0                         ; =0x0
	mov	w8, #0                          ; =0x0
	b	LBB0_10
LBB0_6:
	and	x10, x9, #0x7ffffff0
	add	x8, x0, #32
	movi.2d	v0, #0000000000000000
	mov	x11, x10
	movi.2d	v1, #0000000000000000
	movi.2d	v2, #0000000000000000
	movi.2d	v3, #0000000000000000
LBB0_7:                                 ; =>This Inner Loop Header: Depth=1
	ldp	q4, q5, [x8, #-32]
	ldp	q6, q7, [x8], #64
	add.4s	v0, v4, v0
	add.4s	v1, v5, v1
	add.4s	v2, v6, v2
	add.4s	v3, v7, v3
	subs	x11, x11, #16
	b.ne	LBB0_7
; %bb.8:
	add.4s	v0, v1, v0
	add.4s	v0, v2, v0
	add.4s	v0, v3, v0
	addv.4s	s0, v0
	fmov	w8, s0
	cmp	x10, x9
	b.eq	LBB0_15
; %bb.9:
	tst	x9, #0xc
	b.eq	LBB0_13
LBB0_10:
	mov	x11, x10
	and	x10, x9, #0x7ffffffc
	movi.2d	v0, #0000000000000000
	mov.s	v0[0], w8
	add	x8, x0, x11, lsl #2
	sub	x11, x11, x10
LBB0_11:                                ; =>This Inner Loop Header: Depth=1
	ldr	q1, [x8], #16
	add.4s	v0, v1, v0
	adds	x11, x11, #4
	b.ne	LBB0_11
; %bb.12:
	addv.4s	s0, v0
	fmov	w8, s0
	cmp	x10, x9
	b.eq	LBB0_15
LBB0_13:
	add	x11, x0, x10, lsl #2
	sub	x9, x9, x10
LBB0_14:                                ; =>This Inner Loop Header: Depth=1
	ldr	w10, [x11], #4
	add	w8, w10, w8
	subs	x9, x9, #1
	b.ne	LBB0_14
LBB0_15:
	mov	x0, x8
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_scan_seq                       ; -- Begin function scan_seq
	.p2align	2
_scan_seq:                              ; @scan_seq
	.cfi_startproc
; %bb.0:
	cmp	w2, #1
	b.lt	LBB1_3
; %bb.1:
	mov	w8, w2
LBB1_2:                                 ; =>This Inner Loop Header: Depth=1
	ldr	w9, [x0], #4
	add	w3, w9, w3
	str	w3, [x1], #4
	subs	x8, x8, #1
	b.ne	LBB1_2
LBB1_3:
	mov	x0, x3
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_scan_worker                    ; -- Begin function scan_worker
	.p2align	2
_scan_worker:                           ; @scan_worker
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	add	x9, x0, #24
	mov	w8, #1                          ; =0x1
	ldadd	w8, w13, [x9]
	ldr	w9, [x0, #20]
	cmp	w13, w9
	b.ge	LBB2_35
; %bb.1:
	mov	w9, #4096                       ; =0x1000
	mov	w10, #12                        ; =0xc
	mov	w11, #2                         ; =0x2
	mov	w15, #1                         ; =0x1
	b	LBB2_4
LBB2_2:                                 ;   in Loop: Header=BB2_4 Depth=1
	mov	w15, #0                         ; =0x0
LBB2_3:                                 ;   in Loop: Header=BB2_4 Depth=1
	add	x12, x0, #24
	ldadd	w8, w13, [x12]
	ldr	w12, [x0, #20]
	cmp	w13, w12
	b.ge	LBB2_35
LBB2_4:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB2_19 Depth 2
                                        ;     Child Loop BB2_23 Depth 2
                                        ;     Child Loop BB2_26 Depth 2
                                        ;     Child Loop BB2_28 Depth 2
                                        ;       Child Loop BB2_29 Depth 3
                                        ;     Child Loop BB2_34 Depth 2
                                        ;     Child Loop BB2_16 Depth 2
	lsl	w16, w13, #12
	ldr	w12, [x0, #16]
	sub	w14, w12, w16
	cmp	w14, #1, lsl #12                ; =4096
	csel	w12, w14, w9, lt
	tbz	w15, #0, LBB2_8
; %bb.5:                                ;   in Loop: Header=BB2_4 Depth=1
	cbz	w13, LBB2_14
; %bb.6:                                ;   in Loop: Header=BB2_4 Depth=1
	ldr	x17, [x0, #32]
	mov	x15, x13
	sxtw	x15, w15
	sub	x15, x15, #1
	madd	x17, x15, x10, x17
	ldapr	w17, [x17]
	cmp	w17, #2
	b.ne	LBB2_8
; %bb.7:                                ;   in Loop: Header=BB2_4 Depth=1
	ldr	x17, [x0, #32]
	madd	x15, x15, x10, x17
	ldr	w15, [x15, #8]
	cmp	w14, #1
	b.ge	LBB2_15
	b	LBB2_17
LBB2_8:                                 ;   in Loop: Header=BB2_4 Depth=1
	sxtw	x15, w16
	cmp	w14, #1
	b.lt	LBB2_11
; %bb.9:                                ;   in Loop: Header=BB2_4 Depth=1
	ldr	x16, [x0]
	cmp	w14, #4
	b.ge	LBB2_12
; %bb.10:                               ;   in Loop: Header=BB2_4 Depth=1
	mov	x1, #0                          ; =0x0
	mov	w17, #0                         ; =0x0
	b	LBB2_25
LBB2_11:                                ;   in Loop: Header=BB2_4 Depth=1
	mov	w17, #0                         ; =0x0
	b	LBB2_27
LBB2_12:                                ;   in Loop: Header=BB2_4 Depth=1
	cmp	w14, #16
	b.ge	LBB2_18
; %bb.13:                               ;   in Loop: Header=BB2_4 Depth=1
	mov	x1, #0                          ; =0x0
	mov	w17, #0                         ; =0x0
	b	LBB2_22
LBB2_14:                                ;   in Loop: Header=BB2_4 Depth=1
	mov	w15, #0                         ; =0x0
	cmp	w14, #1
	b.lt	LBB2_17
LBB2_15:                                ;   in Loop: Header=BB2_4 Depth=1
	sbfiz	x16, x16, #2, #32
	ldp	x14, x17, [x0]
	add	x14, x14, x16
	add	x16, x17, x16
LBB2_16:                                ;   Parent Loop BB2_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w17, [x14], #4
	add	w15, w17, w15
	str	w15, [x16], #4
	subs	x12, x12, #1
	b.ne	LBB2_16
LBB2_17:                                ;   in Loop: Header=BB2_4 Depth=1
	ldr	x12, [x0, #32]
	smaddl	x12, w13, w10, x12
	str	w15, [x12, #8]
	stlr	w11, [x12]
	mov	w15, #1                         ; =0x1
	b	LBB2_3
LBB2_18:                                ;   in Loop: Header=BB2_4 Depth=1
	and	x1, x12, #0x1ff0
	add	x17, x16, x15, lsl #2
	add	x17, x17, #32
	movi.2d	v0, #0000000000000000
	mov	x2, x1
	movi.2d	v1, #0000000000000000
	movi.2d	v2, #0000000000000000
	movi.2d	v3, #0000000000000000
LBB2_19:                                ;   Parent Loop BB2_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldp	q4, q5, [x17, #-32]
	ldp	q6, q7, [x17], #64
	add.4s	v0, v4, v0
	add.4s	v1, v5, v1
	add.4s	v2, v6, v2
	add.4s	v3, v7, v3
	subs	x2, x2, #16
	b.ne	LBB2_19
; %bb.20:                               ;   in Loop: Header=BB2_4 Depth=1
	add.4s	v0, v1, v0
	add.4s	v0, v2, v0
	add.4s	v0, v3, v0
	addv.4s	s0, v0
	fmov	w17, s0
	cmp	x1, x12
	b.eq	LBB2_27
; %bb.21:                               ;   in Loop: Header=BB2_4 Depth=1
	tst	x12, #0xc
	b.eq	LBB2_25
LBB2_22:                                ;   in Loop: Header=BB2_4 Depth=1
	mov	x2, x1
	and	x1, x12, #0x1ffc
	movi.2d	v0, #0000000000000000
	mov.s	v0[0], w17
	lsl	x17, x2, #2
	add	x17, x17, x15, lsl #2
	add	x17, x16, x17
	sub	x2, x2, x1
LBB2_23:                                ;   Parent Loop BB2_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	q1, [x17], #16
	add.4s	v0, v1, v0
	adds	x2, x2, #4
	b.ne	LBB2_23
; %bb.24:                               ;   in Loop: Header=BB2_4 Depth=1
	addv.4s	s0, v0
	fmov	w17, s0
	cmp	x1, x12
	b.eq	LBB2_27
LBB2_25:                                ;   in Loop: Header=BB2_4 Depth=1
	sub	x2, x12, x1
	lsl	x1, x1, #2
	add	x1, x1, x15, lsl #2
	add	x16, x16, x1
LBB2_26:                                ;   Parent Loop BB2_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w1, [x16], #4
	add	w17, w1, w17
	subs	x2, x2, #1
	b.ne	LBB2_26
LBB2_27:                                ;   in Loop: Header=BB2_4 Depth=1
	mov	w16, #0                         ; =0x0
	ldr	x1, [x0, #32]
	smaddl	x1, w13, w10, x1
	str	w17, [x1, #4]
	stlr	w8, [x1]
	mov	x1, x13
LBB2_28:                                ;   Parent Loop BB2_4 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB2_29 Depth 3
                                        ; kill: def $w1 killed $w1 killed $x1 def $x1
	sxtw	x1, w1
	sub	x1, x1, #1
LBB2_29:                                ;   Parent Loop BB2_4 Depth=1
                                        ;     Parent Loop BB2_28 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldr	x2, [x0, #32]
	madd	x2, x1, x10, x2
	ldapr	w2, [x2]
	cmp	w2, #2
	b.eq	LBB2_32
; %bb.30:                               ;   in Loop: Header=BB2_29 Depth=3
	cmp	w2, #1
	b.ne	LBB2_29
; %bb.31:                               ;   in Loop: Header=BB2_28 Depth=2
	ldr	x2, [x0, #32]
	madd	x2, x1, x10, x2
	ldr	w2, [x2, #4]
	add	w16, w2, w16
	b	LBB2_28
LBB2_32:                                ;   in Loop: Header=BB2_4 Depth=1
	ldr	x2, [x0, #32]
	madd	x1, x1, x10, x2
	ldr	w1, [x1, #8]
	add	w16, w1, w16
	add	w17, w16, w17
	smaddl	x13, w13, w10, x2
	str	w17, [x13, #8]
	stlr	w11, [x13]
	cmp	w14, #1
	b.lt	LBB2_2
; %bb.33:                               ;   in Loop: Header=BB2_4 Depth=1
	lsl	x14, x15, #2
	ldp	x13, x15, [x0]
	add	x13, x13, x14
	add	x14, x15, x14
LBB2_34:                                ;   Parent Loop BB2_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w15, [x13], #4
	add	w16, w15, w16
	str	w16, [x14], #4
	subs	x12, x12, #1
	b.ne	LBB2_34
	b	LBB2_2
LBB2_35:
	mov	x0, #0                          ; =0x0
	bl	_pthread_exit
	.cfi_endproc
                                        ; -- End function
	.globl	_generateData                   ; -- Begin function generateData
	.p2align	2
_generateData:                          ; @generateData
	.cfi_startproc
; %bb.0:
	stp	x26, x25, [sp, #-80]!           ; 16-byte Folded Spill
	stp	x24, x23, [sp, #16]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #32]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	mov	x20, x0
	sbfiz	x0, x20, #2, #32
	bl	_malloc
	mov	x19, x0
	cmp	w20, #1
	b.lt	LBB3_3
; %bb.1:
	mov	w21, #35757                     ; =0x8bad
	movk	w21, #26843, lsl #16
	mov	w22, #10000                     ; =0x2710
	mov	w23, #34079                     ; =0x851f
	movk	w23, #20971, lsl #16
	mov	w24, #100                       ; =0x64
	mov	x25, x19
	mov	w20, w20
LBB3_2:                                 ; =>This Inner Loop Header: Depth=1
	bl	_rand
	smull	x8, w0, w21
	asr	x8, x8, #44
	add	w8, w8, w8, lsr #31
	msub	w26, w8, w22, w0
	bl	_rand
	smull	x8, w0, w23
	asr	x8, x8, #37
	add	w8, w8, w8, lsr #31
	msub	w8, w8, w24, w0
	mvn	w9, w26
	cmp	w8, #25
	csinc	w8, w9, w26, lt
	str	w8, [x25], #4
	subs	x20, x20, #1
	b.ne	LBB3_2
LBB3_3:
	mov	x0, x19
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #32]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #16]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp], #80             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_verify                         ; -- Begin function verify
	.p2align	2
_verify:                                ; @verify
	.cfi_startproc
; %bb.0:
	cmp	w2, #1
	b.lt	LBB4_5
; %bb.1:
	mov	w8, w2
	sub	x9, x8, #1
LBB4_2:                                 ; =>This Inner Loop Header: Depth=1
	ldr	w8, [x1], #4
	ldr	w11, [x0], #4
	subs	x9, x9, #1
	cset	w10, hs
	cmp	w8, w11
	cset	w8, eq
	b.ne	LBB4_4
; %bb.3:                                ;   in Loop: Header=BB4_2 Depth=1
	tbnz	w10, #0, LBB4_2
LBB4_4:
	mov	x0, x8
	ret
LBB4_5:
	mov	w8, #1                          ; =0x1
	mov	x0, x8
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #304
	stp	d11, d10, [sp, #176]            ; 16-byte Folded Spill
	stp	d9, d8, [sp, #192]              ; 16-byte Folded Spill
	stp	x28, x27, [sp, #208]            ; 16-byte Folded Spill
	stp	x26, x25, [sp, #224]            ; 16-byte Folded Spill
	stp	x24, x23, [sp, #240]            ; 16-byte Folded Spill
	stp	x22, x21, [sp, #256]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #272]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #288]            ; 16-byte Folded Spill
	add	x29, sp, #288
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_offset b8, -104
	.cfi_offset b9, -112
	.cfi_offset b10, -120
	.cfi_offset b11, -128
Lloh0:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh1:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh2:
	ldr	x8, [x8]
	stur	x8, [x29, #-128]
	cmp	w0, #2
	b.ne	LBB5_37
; %bb.1:
	mov	w8, #67108864                   ; =0x4000000
	str	w8, [sp, #92]
	ldr	x0, [x1, #8]
	add	x8, sp, #92
	str	x8, [sp]
Lloh3:
	adrp	x1, l_.str.2@PAGE
Lloh4:
	add	x1, x1, l_.str.2@PAGEOFF
	bl	_sscanf
	mov	x0, #0                          ; =0x0
	bl	_time
                                        ; kill: def $w0 killed $w0 killed $x0
	bl	_srand
	ldrsw	x22, [sp, #92]
	lsl	x0, x22, #2
	bl	_malloc
	mov	x27, x0
	cmp	w22, #1
	b.lt	LBB5_5
; %bb.2:
	mov	w19, #35757                     ; =0x8bad
	movk	w19, #26843, lsl #16
	mov	w20, #10000                     ; =0x2710
	mov	w21, #34079                     ; =0x851f
	movk	w21, #20971, lsl #16
	mov	w23, #100                       ; =0x64
	mov	x24, x27
LBB5_3:                                 ; =>This Inner Loop Header: Depth=1
	bl	_rand
	smull	x8, w0, w19
	asr	x8, x8, #44
	add	w8, w8, w8, lsr #31
	msub	w25, w8, w20, w0
	bl	_rand
	smull	x8, w0, w21
	asr	x8, x8, #37
	add	w8, w8, w8, lsr #31
	msub	w8, w8, w23, w0
	mvn	w9, w25
	cmp	w8, #25
	csinc	w8, w9, w25, lt
	str	w8, [x24], #4
	subs	x22, x22, #1
	b.ne	LBB5_3
; %bb.4:
	ldr	w22, [sp, #92]
LBB5_5:
	mov	x25, #0                         ; =0x0
	add	x26, sp, #96
	movi	d8, #0000000000000000
Lloh5:
	adrp	x20, _scan_worker@PAGE
Lloh6:
	add	x20, x20, _scan_worker@PAGEOFF
	mov	x28, #70368744177664            ; =0x400000000000
	movk	x28, #16527, lsl #48
	mov	x24, x22
	movi	d9, #0000000000000000
LBB5_6:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB5_18 Depth 2
                                        ;     Child Loop BB5_21 Depth 2
	sbfiz	x0, x24, #2, #32
	bl	_malloc
	mov	x22, x0
	add	x1, sp, #72
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldr	w19, [sp, #92]
	adds	w8, w19, #4095
	mov	w9, #8190                       ; =0x1ffe
	add	w9, w19, w9
	csel	w8, w9, w8, lt
	asr	w21, w8, #12
	mov	w0, #40                         ; =0x28
	bl	_malloc
	mov	x23, x0
	stp	x27, x22, [x0]
	add	w8, w21, w21, lsl #1
	lsl	w8, w8, #2
	sxtw	x0, w8
	bl	_malloc
	mov	x24, x0
	cmp	w19, #1
	b.lt	LBB5_8
; %bb.7:                                ;   in Loop: Header=BB5_6 Depth=1
	cmp	w21, #1
	csinc	w8, w21, wzr, gt
	add	w8, w8, w8, lsl #1
	lsl	w1, w8, #2
	mov	x0, x24
	bl	_bzero
LBB5_8:                                 ;   in Loop: Header=BB5_6 Depth=1
	stp	w21, wzr, [x23, #20]
	str	w19, [x23, #16]
	str	x24, [x23, #32]
	add	x0, sp, #96
	mov	x1, #0                          ; =0x0
	mov	x2, x20
	mov	x3, x23
	bl	_pthread_create
	cbnz	w0, LBB5_25
; %bb.9:                                ;   in Loop: Header=BB5_6 Depth=1
	add	x0, x26, #8
	mov	x1, #0                          ; =0x0
	mov	x2, x20
	mov	x3, x23
	bl	_pthread_create
	cbnz	w0, LBB5_26
; %bb.10:                               ;   in Loop: Header=BB5_6 Depth=1
	add	x0, x26, #16
	mov	x1, #0                          ; =0x0
	mov	x2, x20
	mov	x3, x23
	bl	_pthread_create
	cbnz	w0, LBB5_27
; %bb.11:                               ;   in Loop: Header=BB5_6 Depth=1
	add	x0, x26, #24
	mov	x1, #0                          ; =0x0
	mov	x2, x20
	mov	x3, x23
	bl	_pthread_create
	cbnz	w0, LBB5_28
; %bb.12:                               ;   in Loop: Header=BB5_6 Depth=1
	add	x0, x26, #32
	mov	x1, #0                          ; =0x0
	mov	x2, x20
	mov	x3, x23
	bl	_pthread_create
	cbnz	w0, LBB5_29
; %bb.13:                               ;   in Loop: Header=BB5_6 Depth=1
	add	x0, x26, #40
	mov	x1, #0                          ; =0x0
	mov	x2, x20
	mov	x3, x23
	bl	_pthread_create
	cbnz	w0, LBB5_30
; %bb.14:                               ;   in Loop: Header=BB5_6 Depth=1
	add	x0, x26, #48
	mov	x1, #0                          ; =0x0
	mov	x2, x20
	mov	x3, x23
	bl	_pthread_create
	cbnz	w0, LBB5_31
; %bb.15:                               ;   in Loop: Header=BB5_6 Depth=1
	add	x0, x26, #56
	mov	x1, #0                          ; =0x0
	mov	x2, x20
	mov	x3, x23
	bl	_pthread_create
	cbnz	w0, LBB5_32
; %bb.16:                               ;   in Loop: Header=BB5_6 Depth=1
	ldr	x0, [sp, #96]
	mov	x1, #0                          ; =0x0
	bl	_pthread_join
	ldr	x0, [sp, #104]
	mov	x1, #0                          ; =0x0
	bl	_pthread_join
	ldr	x0, [sp, #112]
	mov	x1, #0                          ; =0x0
	bl	_pthread_join
	ldr	x0, [sp, #120]
	mov	x1, #0                          ; =0x0
	bl	_pthread_join
	ldr	x0, [sp, #128]
	mov	x1, #0                          ; =0x0
	bl	_pthread_join
	ldr	x0, [sp, #136]
	mov	x1, #0                          ; =0x0
	bl	_pthread_join
	ldr	x0, [sp, #144]
	mov	x1, #0                          ; =0x0
	bl	_pthread_join
	ldr	x0, [sp, #152]
	mov	x1, #0                          ; =0x0
	bl	_pthread_join
	add	x1, sp, #56
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	mov	x0, x24
	bl	_free
	mov	x0, x23
	bl	_free
	ldp	x8, x9, [sp, #56]
	ldp	x10, x11, [sp, #72]
	sub	x8, x8, x10
	scvtf	d0, x8
	sub	x8, x9, x11
	scvtf	d1, x8
	fmov	d2, x28
	fdiv	d1, d1, d2
	mov	x8, #145685290680320            ; =0x848000000000
	movk	x8, #16686, lsl #48
	fmov	d2, x8
	fmadd	d10, d0, d2, d1
	ldr	w8, [x22, x25, lsl #2]
	str	x8, [sp, #8]
	str	d10, [sp]
Lloh7:
	adrp	x0, l_.str.4@PAGE
Lloh8:
	add	x0, x0, l_.str.4@PAGEOFF
	bl	_printf
	ldrsw	x8, [sp, #92]
	lsl	x0, x8, #2
	bl	_malloc
	mov	x23, x0
	add	x1, sp, #40
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldr	w8, [sp, #92]
	cmp	w8, #1
	b.lt	LBB5_19
; %bb.17:                               ;   in Loop: Header=BB5_6 Depth=1
	mov	w9, #0                          ; =0x0
	mov	x10, x27
	mov	x11, x23
LBB5_18:                                ;   Parent Loop BB5_6 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w12, [x10], #4
	add	w9, w12, w9
	str	w9, [x11], #4
	subs	x8, x8, #1
	b.ne	LBB5_18
LBB5_19:                                ;   in Loop: Header=BB5_6 Depth=1
	mov	x26, x27
	add	x1, sp, #24
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldp	x28, x27, [sp, #24]
	ldp	x19, x21, [sp, #40]
	ldr	w24, [sp, #92]
	cmp	w24, #1
	b.lt	LBB5_23
; %bb.20:                               ;   in Loop: Header=BB5_6 Depth=1
	mov	x8, x23
	mov	x9, x22
	mov	x10, x24
LBB5_21:                                ;   Parent Loop BB5_6 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w11, [x8], #4
	ldr	w12, [x9], #4
	cmp	w11, w12
	b.ne	LBB5_36
; %bb.22:                               ;   in Loop: Header=BB5_21 Depth=2
	subs	x10, x10, #1
	b.ne	LBB5_21
LBB5_23:                                ;   in Loop: Header=BB5_6 Depth=1
	mov	x0, x22
	bl	_free
	mov	x0, x23
	bl	_free
	sub	x8, x28, x19
	scvtf	d0, x8
	fadd	d8, d8, d10
	sub	x8, x27, x21
	scvtf	d1, x8
	mov	x28, #70368744177664            ; =0x400000000000
	movk	x28, #16527, lsl #48
	fmov	d2, x28
	fdiv	d1, d1, d2
	mov	x8, #145685290680320            ; =0x848000000000
	movk	x8, #16686, lsl #48
	fmov	d2, x8
	fmadd	d0, d0, d2, d1
	fadd	d9, d9, d0
	add	x25, x25, #1
                                        ; kill: def $w24 killed $w24 killed $x24 def $x24
	cmp	x25, #30
	mov	x27, x26
	add	x26, sp, #96
	b.ne	LBB5_6
; %bb.24:
	fmov	d0, #30.00000000
	fdiv	d1, d9, d0
	fdiv	d0, d8, d0
	stp	d0, d1, [sp]
Lloh9:
	adrp	x0, l_.str.6@PAGE
Lloh10:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	mov	w0, #0                          ; =0x0
	b	LBB5_34
LBB5_25:
	mov	w8, #0                          ; =0x0
	b	LBB5_33
LBB5_26:
	mov	w8, #1                          ; =0x1
	b	LBB5_33
LBB5_27:
	mov	w8, #2                          ; =0x2
	b	LBB5_33
LBB5_28:
	mov	w8, #3                          ; =0x3
	b	LBB5_33
LBB5_29:
	mov	w8, #4                          ; =0x4
	b	LBB5_33
LBB5_30:
	mov	w8, #5                          ; =0x5
	b	LBB5_33
LBB5_31:
	mov	w8, #6                          ; =0x6
	b	LBB5_33
LBB5_32:
	mov	w8, #7                          ; =0x7
LBB5_33:
	str	x8, [sp]
Lloh11:
	adrp	x0, l_.str.3@PAGE
Lloh12:
	add	x0, x0, l_.str.3@PAGEOFF
	bl	_printf
	mov	w0, #1                          ; =0x1
LBB5_34:
	ldur	x8, [x29, #-128]
Lloh13:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh14:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh15:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB5_38
; %bb.35:
	ldp	x29, x30, [sp, #288]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #272]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #256]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #240]            ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #224]            ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #208]            ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #192]              ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #176]            ; 16-byte Folded Reload
	add	sp, sp, #304
	ret
LBB5_36:
Lloh16:
	adrp	x0, l___func__.main@PAGE
Lloh17:
	add	x0, x0, l___func__.main@PAGEOFF
Lloh18:
	adrp	x1, l_.str@PAGE
Lloh19:
	add	x1, x1, l_.str@PAGEOFF
Lloh20:
	adrp	x3, l_.str.5@PAGE
Lloh21:
	add	x3, x3, l_.str.5@PAGEOFF
	mov	w2, #236                        ; =0xec
	bl	___assert_rtn
LBB5_37:
Lloh22:
	adrp	x0, l___func__.main@PAGE
Lloh23:
	add	x0, x0, l___func__.main@PAGEOFF
Lloh24:
	adrp	x1, l_.str@PAGE
Lloh25:
	add	x1, x1, l_.str@PAGEOFF
Lloh26:
	adrp	x3, l_.str.1@PAGE
Lloh27:
	add	x3, x3, l_.str.1@PAGEOFF
	mov	w2, #159                        ; =0x9f
	bl	___assert_rtn
LBB5_38:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh0, Lloh1, Lloh2
	.loh AdrpAdd	Lloh3, Lloh4
	.loh AdrpAdd	Lloh5, Lloh6
	.loh AdrpAdd	Lloh7, Lloh8
	.loh AdrpAdd	Lloh9, Lloh10
	.loh AdrpAdd	Lloh11, Lloh12
	.loh AdrpLdrGotLdr	Lloh13, Lloh14, Lloh15
	.loh AdrpAdd	Lloh20, Lloh21
	.loh AdrpAdd	Lloh18, Lloh19
	.loh AdrpAdd	Lloh16, Lloh17
	.loh AdrpAdd	Lloh26, Lloh27
	.loh AdrpAdd	Lloh24, Lloh25
	.loh AdrpAdd	Lloh22, Lloh23
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l___func__.main:                        ; @__func__.main
	.asciz	"main"

l_.str:                                 ; @.str
	.asciz	"main.c"

l_.str.1:                               ; @.str.1
	.asciz	"argc == 2"

l_.str.2:                               ; @.str.2
	.asciz	"%d"

l_.str.3:                               ; @.str.3
	.asciz	"Error creating thread %d\n"

l_.str.4:                               ; @.str.4
	.asciz	"%f %d\n"

l_.str.5:                               ; @.str.5
	.asciz	"verify(output_paralell, output_seq, size)"

l_.str.6:                               ; @.str.6
	.asciz	"%f %f\n"

.subsections_via_symbols
