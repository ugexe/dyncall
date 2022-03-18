/*

 Package: dyncall
 Library: test
 File: test/callback_suite/env.h
 Description: 
 License:

   Copyright (c) 2011-2018 Daniel Adler <dadler@uni-goettingen.de>,
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

#include "dyncall_value.h"
#include "_auto_config.h"


#define DEF_NON_VOID_TYPES \
  X(B,DCbool) \
  X(c,DCchar) X(C,DCuchar) X(s,DCshort) X(S,DCushort) \
  X(i,DCint) X(I,DCuint) X(j,DClong) X(J,DCulong) \
  X(l,DClonglong) X(L,DCulonglong) \
  X(f,DCfloat) X(d,DCdouble) \
  X(p,DCpointer) X(Z,DCpointer)

#define DEF_TYPES \
  X(v,DCvoid) \
  DEF_NON_VOID_TYPES


typedef struct DCValueSet_
{
#define X(CH,T) T CH;
DEF_NON_VOID_TYPES
#undef X
} DCValueSet;


/* test related */

void InitEnv(); /* initializes ValueMatrix */


/* function of type and position */
void GetReferenceArg(DCValue* output, char type, int argpos);
/* function of type (position = -1) */
void GetReferenceResult(DCValue* output, char type);

extern DCValueSet ValueMatrix[CONFIG_MAXARGS];

/* Global Options. */
extern int OptionVerbose;


