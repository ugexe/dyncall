/*

 Package: dyncall
 Library: dyncallback
 File: dyncallback/dyncall_thunk_riscv64.h
 Description: Thunk - Header for RISCV64
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

#ifndef DYNCALL_THUNK_RISCV64_H
#define DYNCALL_THUNK_RISCV64_H

struct DCThunk_          /* off  size */
{                        /* ----|---- */
  unsigned int code[4];  /*   0   16  */
  void (*entry)();       /*  16    8  */
  void* reserved;        /*  24    8  */
};                       /*  32 total */

#endif /* DYNCALL_THUNK_RISCV64_H */

