/*

 Package: dyncall
 Library: test
 File: test/callback_suite/globals.c
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

#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include "dyncall_signature.h"
#include "globals.h"


extern int G_maxargs;

static DCValueSet K;
DCValueSet* ValueMatrix;
DCValue* Args;
DCValue Result;

void get_reference_arg(DCValue* output, char ch, int pos)
{
  output->L = 0xCAFEBABEDEADC0DELL;
  pos = pos + 2; //@@@STRUCT unsure about indexing, here
  switch(ch) {
    case DC_SIGCHAR_BOOL:     output->B = ((pos*K.i) & 1) ? DC_TRUE : DC_FALSE ; break;
    case DC_SIGCHAR_CHAR:     output->c =             pos *           K.c;       break;
    case DC_SIGCHAR_UCHAR:    output->C =             pos *           K.C;       break;
    case DC_SIGCHAR_SHORT:    output->s =             pos *           K.s;       break;
    case DC_SIGCHAR_USHORT:   output->S =             pos *           K.S;       break;
    case DC_SIGCHAR_INT:      output->i =             pos *           K.i;       break;
    case DC_SIGCHAR_UINT:     output->I =             pos *           K.I;       break;
    case DC_SIGCHAR_LONG:     output->j =             pos *           K.j;       break;
    case DC_SIGCHAR_ULONG:    output->J =             pos *           K.J;       break;
    case DC_SIGCHAR_LONGLONG: output->l =             pos *           K.l;       break;
    case DC_SIGCHAR_ULONGLONG:output->L =             pos *           K.L;       break;
    case DC_SIGCHAR_FLOAT:    output->f =      (float)pos *           K.f;       break;
    case DC_SIGCHAR_DOUBLE:   output->d =     (double)pos *           K.d;       break;
    case DC_SIGCHAR_POINTER:  output->p = (DCpointer)(pos * (intptr_t)K.p);      break;
    default: assert(0);
  }
}

void get_reference_result(DCValue* output, char ch)
{
  get_reference_arg(output, ch, -1);
}

void init_test_data()
{
  int pos;

  ValueMatrix = malloc(sizeof(DCValueSet)*G_maxargs);

  K.B = DC_TRUE;
  K.c =  13;
  K.C =  19;
  K.s = -23;
  K.S =  41;
  K.i = 134;
  K.I = 257;
  K.j = -12357;
  K.J = 356;
  K.l = -1234556687721LL;
  K.L = 23564634576581ULL;
  K.f = 1.20432545f;
  K.d = 1.0123456;
  K.p = (void*)0x1020345;

  for(pos = 0 ;pos < G_maxargs ;++pos) {
    DCValue ref;
    get_reference_arg(&ref, DC_SIGCHAR_BOOL     , pos);   ValueMatrix[pos].B = ref.B;
    get_reference_arg(&ref, DC_SIGCHAR_CHAR     , pos);   ValueMatrix[pos].c = ref.c;
    get_reference_arg(&ref, DC_SIGCHAR_UCHAR    , pos);   ValueMatrix[pos].C = ref.C;
    get_reference_arg(&ref, DC_SIGCHAR_SHORT    , pos);   ValueMatrix[pos].s = ref.s;
    get_reference_arg(&ref, DC_SIGCHAR_USHORT   , pos);   ValueMatrix[pos].S = ref.S;
    get_reference_arg(&ref, DC_SIGCHAR_INT      , pos);   ValueMatrix[pos].i = ref.i;
    get_reference_arg(&ref, DC_SIGCHAR_UINT     , pos);   ValueMatrix[pos].I = ref.I;
    get_reference_arg(&ref, DC_SIGCHAR_LONG     , pos);   ValueMatrix[pos].j = ref.j;
    get_reference_arg(&ref, DC_SIGCHAR_ULONG    , pos);   ValueMatrix[pos].J = ref.J;
    get_reference_arg(&ref, DC_SIGCHAR_LONGLONG , pos);   ValueMatrix[pos].l = ref.l;
    get_reference_arg(&ref, DC_SIGCHAR_ULONGLONG, pos);   ValueMatrix[pos].L = ref.L;
    get_reference_arg(&ref, DC_SIGCHAR_FLOAT    , pos);   ValueMatrix[pos].f = ref.f;
    get_reference_arg(&ref, DC_SIGCHAR_DOUBLE   , pos);   ValueMatrix[pos].d = ref.d;
    get_reference_arg(&ref, DC_SIGCHAR_POINTER  , pos);   ValueMatrix[pos].p = ref.p;
  }

  Args = malloc(sizeof(DCValue)*G_maxargs);
}


void deinit_test_data()
{
  free(Args);

  free(ValueMatrix);
}

