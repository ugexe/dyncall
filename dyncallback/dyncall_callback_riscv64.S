/*

 Package: dyncall
 Library: dyncallback
 File: dyncallback/dyncall_callback_riscv64.S
 Description: Callback Thunk - Implementation for RISCV64
 License:

   Copyright (c) 2023 Jun Jeon <yjeon@netflix.com>

   Permission to use, copy, modify, and distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

*/

/* struct DCCallback
     type       off   size
     ---------|------|------
     DCThunk  |   0  |  32
     handler  |  32  |   8
     userdata |  40  |   8
*/

.align 4
.globl dcCallbackThunkEntry
dcCallbackThunkEntry:

/* called from dcbInitThunk() in dyncall_thunk_riscv64.c */

/* input:
    t5: DCCallback* pcb
    a0..a7   ?? GP regs
    fa0..fa7 ?? FP/SIMD regs
    sp...    ?? arguments on stack

   locals:
     type       off   size
     ---------|------|------
     Frame        0     16
     DCArgs      16    144
     DCValue    160     16

     size              176
     aligned           176

   ra - ret addr
   s0/fp - frame ptr

   locals:
      t0: orig sp
      t1: DCArgs* args
*/

	mv  t0, sp

	add sp, sp, -176

	/* save ra and s0 */
	sd  ra, 0(sp)
	sd  s0, 8(sp)

	/* save frame ptr */
	mv  s0, sp

	add t1, s0, 16

	/* just saving everything on stack, as defined in DCArgs in dyncall_args_riscv64.c */

/* save regs */

	sd  a0, 0(t1)
	sd  a1, 8(t1)
	sd  a2, 16(t1)
	sd  a3, 24(t1)
	sd  a4, 32(t1)
	sd  a5, 40(t1)
	sd  a6, 48(t1)
	sd  a7, 56(t1)

	fsd fa0, 64(t1)
	fsd fa1, 72(t1)
	fsd fa2, 80(t1)
	fsd fa3, 88(t1)
	fsd fa4, 96(t1)
	fsd fa5, 104(t1)
	fsd fa6, 112(t1)
	fsd fa7, 120(t1)

	sd  t0, 128(t1)   /* sp=sp */
	sd  zero, 136(t1) /* i=f=0 */

/* call handler/callback */

	mv   a0, t5      /* DCCallback* pcb      */
	add  a1, s0, 16  /* DCArgs*     args     */
	add  a2, s0, 160 /* DCValue*    result   */
	ld   a3, 40(t5)  /* void*       userdata */

	ld   t2, 32(t5)
	jalr ra, 0(t2)

	and  t3, a0, 255
	add  t4, zero, 'f'  /* single precition floats are sign extended on    */
	beq  t3, t4, .retf  /* riscv with the D extension, handle specifically */
	add  t4, zero, 'd'
	beq  t3, t4, .retd

.reti:
	ld   a0, 160(s0)
	j    .ret
.retf:
	flw  fa0, 160(s0)
	j    .ret
.retd:
	fld  fa0, 160(s0)
.ret:
	/* recover ra and s0 */
	ld   ra, 0(sp)
	ld   s0, 8(sp)

	add  sp, sp, 176
	ret

