/*

 Package: dyncall
 Library: dyncallback
 File: dyncallback/dyncall_callback_sparc64.s
 Description: Callback - Implementation for Sparc 64-bit
 License:

   Copyright (c) 2017 Tassilo Philipp <tphilipp@potion-studios.com>

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

/* input:
	$i0    -> thunk
	$i0+56 -> cb handler
	$i0+64 -> userdata
*/

/* NOTE: %sp/%fp for v9 are offset, using them needs a "BIAS" of 2047 */
.set BIAS, 2047

.text
.globl dcCallbackThunkEntry

/* Called by thunk - thunk stores pointer to DCCallback */
/* in %g1, and pointer to called function in %g2        */
dcCallbackThunkEntry:

	/* Prolog. */
	/* Frame size of 208b comes from needing storage space for the following: */
	/*   DCargs(sparc_req_reg_save_area:128 + spill:64 + argptr:8) + retval:8 */
	/* Spill area could theoretically be only 32b, b/c cbHandler function has */
 	/* 4 arguments, and retval doesn't need stack, but let's be conservative. */
	save %sp, -208, %sp

	/* Spill register args. */
	add  %fp, BIAS + 136, %l0
	stx  %i0, [ %l0 +  0 ]          /* reg arg 0 */
	stx  %i1, [ %l0 +  8 ]          /* reg arg 1 */
	stx  %i2, [ %l0 + 16 ]          /* reg arg 2 */
	stx  %i3, [ %l0 + 24 ]          /* reg arg 3 */
	stx  %i4, [ %l0 + 32 ]          /* reg arg 4 */
	stx  %i5, [ %l0 + 40 ]          /* reg arg 5 */
	stx  %l0, [ %sp + BIAS + 192 ]  /* init arg_ptr */

	/* Zero retval store. */
	stx  %g0, [ %sp + BIAS + 200 ]

	/* Prepare callback handler call. */
	mov  %g1, %o0                   /* Param 0 = DCCallback*, %g1 holds ptr to thunk */
	add  %sp, BIAS + 192, %o1       /* Param 1 = DCArgs* (ptr to struct with args ptr) */
	add  %sp, BIAS + 200, %o2       /* Param 2 = results ptr to 8b of local stack data */
	ldx  [ %g1 + 64 ], %o3          /* Param 3 = userdata ptr */

	/* Fetch callback handler address (after thunk blob) and call. */
	ldx  [ %g1 + 56 ], %l0
	call %l0
	nop

	/* Put retval in %i0 (to be in caller's %o0), and %f0. */
	ldx  [ %sp + BIAS + 200 ], %i0
	ldd  [ %sp + BIAS + 200 ], %f0

	/* Epilog. */
	restore                 /* unshift reg window */
	retl                    /* Return from proc. -- jmpl %i7 + 8, %g0 */
	nop

