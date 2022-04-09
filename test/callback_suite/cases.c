/*

 Package: dyncall
 Library: test
 File: test/call_suite/cases.c
 Description:
 License:

   Copyright (c) 2011-2022 Daniel Adler <dadler@uni-goettingen.de>,
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

#include "globals.h"

// @@@STRUCT move or remove
#define CONFIG_API 

#define X(CH,T) typedef T CH;
DEF_TYPES
#undef X

extern DCValue Result;
#define M ValueMatrix
#include "cases.h"
#undef M

int G_ncases = sizeof(G_sigtab)/sizeof(G_sigtab[0]);

