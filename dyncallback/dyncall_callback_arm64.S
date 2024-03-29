/*

 Package: dyncall
 Library: dyncallback
 File: dyncallback/dyncall_callback_arm64.S
 Description: Callback Thunk - Implementation for ARM64 / ARMv8 / AAPCS64
 License:

   Copyright (c) 2015-2024 Daniel Adler <dadler@uni-goettingen.de>,
                           Tassilo Philipp <tphilipp@potion-studios.com>

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

#include "../portasm/portasm-arm64.S"
BEGIN_ASM

/* struct DCCallback
     type       off   size
     ---------|------|------
     DCThunk  |   0  |  32
     handler  |  32  |   8
     userdata |  40  |   8
*/

TEXTAREA

GLOBAL_C(dcCallbackThunkEntry)
ENTRY_C(dcCallbackThunkEntry)
ALIGN(4)

/* input:
    x9: DCCallback* pcb
    x0..x7 ?? GP regs
    d0..d7 ?? FP/SIMD regs
    sp...  ?? arguments on stack

   locals:
     type       off   size
     ---------|------|------
     Frame        0     16
     DCArgs      16    144
     DCValue    160     16

     size              176
     aligned           176


   locals:
      x10: sp
      x11: DCArgs* args
*/

	mov x10, sp
	stp x29, x30, [sp, #-176 ]!
	mov x29, sp

	add x11, x29 , #16

/* save registers */

	stp x0, x1, [x11, #0 ]
	stp x2, x3, [x11, #16]
	stp x4, x5, [x11, #32]
	stp x6, x7, [x11, #48]

	stp d0, d1, [x11, #64]
	stp d2, d3, [x11, #80]
	stp d4, d5, [x11, #96]
	stp d6, d7, [x11, #112]

	eor x12, x12, x12
	stp x10,x12,[x11, #128]		/* sp=sp, i=0, f=0 */


/* call handler/callback */

	mov x0 , x9          /* DCCallback* pcb      */
	add x1 , x29 , #16   /* DCArgs*     args     */
	add x2 , x29 , #160  /* DCValue*    result   */
	ldr x3 , [x9 , #40]  /* void*       userdata */

	ldr x11, [x9 , #32]
	blr x11

	and w0, w0, #255
	cmp w0, 'f'
	b.eq LABELUSE(retf)
	cmp w0, 'd'
	b.eq LABELUSE(retf)

LABELDEF(reti)
	ldr x0, [x29, #160]
	b LABELUSE(ret)
LABELDEF(retf)
	ldr d0, [x29, #160]
LABELDEF(ret)
	ldp x29, x30, [sp], #176
	ret


END_PROC
END_ASM

