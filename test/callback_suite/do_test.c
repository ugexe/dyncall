/*

 Package: dyncall
 Library: test
 File: test/callback_suite/do_test.c
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

#include <assert.h>
#include <stdio.h>
#include "dyncall_callback.h"
#include "env.h"


/* arguments filled-in by callback handlers, and return value */
DCValue Args[CONFIG_MAXARGS];
DCValue Result;


static int CompareValues(char type, DCValue* a, DCValue* b)
{
  switch(type) 
  {
    case DC_SIGCHAR_BOOL:      return (a->B == b->B);
    case DC_SIGCHAR_CHAR:      return (a->c == b->c);
    case DC_SIGCHAR_UCHAR:     return (a->C == b->C);
    case DC_SIGCHAR_SHORT:     return (a->s == b->s);
    case DC_SIGCHAR_USHORT:    return (a->S == b->S);
    case DC_SIGCHAR_INT:       return (a->i == b->i);
    case DC_SIGCHAR_UINT:      return (a->I == b->I);
    case DC_SIGCHAR_LONG:      return (a->j == b->j);
    case DC_SIGCHAR_ULONG:     return (a->J == b->J);
    case DC_SIGCHAR_LONGLONG:  return (a->l == b->l);
    case DC_SIGCHAR_ULONGLONG: return (a->L == b->L);
    case DC_SIGCHAR_FLOAT:     return (a->f == b->f);
    case DC_SIGCHAR_DOUBLE:    return (a->d == b->d);
    case DC_SIGCHAR_POINTER:   return (a->p == b->p);
    default: assert(0);
  }
  return 0;
}


static int Compare(const char* signature)
{
  DCValue ref;
  int total = 1;
  int pos;
  int isequal;
  char ch;

  /* check arguments */
  pos = 0;
  for(;;)
  {
    ch = *signature++;
    
    if(ch == DC_SIGCHAR_CC_PREFIX) {
      ++signature; /* skip cconv prefix */
      continue;
    }

    if (!ch || ch == DC_SIGCHAR_ENDARG) break;
    GetReferenceArg(&ref, ch, pos);
    isequal = CompareValues( ch, &ref, &Args[pos] );
    if ( !isequal ) {
      if (OptionVerbose) { total = 0; fprintf(stdout, " @%d[%c] ", pos, ch); }
      else return 0;
    }
    ++pos;
  }
    
  if(ch == DC_SIGCHAR_ENDARG)
  ch = *signature;

  /* check result */

  GetReferenceResult(&ref, ch);

  isequal = CompareValues(ch, &ref, &Result);
  if (!isequal) {
    if (OptionVerbose) { total = 0; fprintf(stdout, " @-1 "); }
    else return 0;
  }

  return total;
}


static char handler(DCCallback* that, DCArgs* input, DCValue* output, void* userdata)
{
  const char* signature = (const char*) userdata;
  int pos = 0; 
  char ch;

  for(;;) {
    ch = *signature++;
    if (!ch || ch == DC_SIGCHAR_ENDARG) break;
    Args[pos].L = 0xDEADC0DECAFEBABELL;
    switch(ch) {
      case DC_SIGCHAR_BOOL:     Args[pos].B = dcbArgBool     (input); break;
      case DC_SIGCHAR_CHAR:     Args[pos].c = dcbArgChar     (input); break;
      case DC_SIGCHAR_UCHAR:    Args[pos].C = dcbArgUChar    (input); break;
      case DC_SIGCHAR_SHORT:    Args[pos].s = dcbArgShort    (input); break;
      case DC_SIGCHAR_USHORT:   Args[pos].S = dcbArgUShort   (input); break;
      case DC_SIGCHAR_INT:      Args[pos].i = dcbArgInt      (input); break;
      case DC_SIGCHAR_UINT:     Args[pos].I = dcbArgUInt     (input); break;
      case DC_SIGCHAR_LONG:     Args[pos].j = dcbArgLong     (input); break;
      case DC_SIGCHAR_ULONG:    Args[pos].J = dcbArgULong    (input); break;
      case DC_SIGCHAR_LONGLONG: Args[pos].l = dcbArgLongLong (input); break;
      case DC_SIGCHAR_ULONGLONG:Args[pos].L = dcbArgULongLong(input); break;
      case DC_SIGCHAR_FLOAT:    Args[pos].f = dcbArgFloat    (input); break; 
      case DC_SIGCHAR_DOUBLE:   Args[pos].d = dcbArgDouble   (input); break;
      case DC_SIGCHAR_STRING:
      case DC_SIGCHAR_POINTER:  Args[pos].p = dcbArgPointer  (input); break;
      case DC_SIGCHAR_CC_PREFIX: ++signature; /* skip cconv prefix */ continue;
    }
    ++pos;
  }

  if(ch == DC_SIGCHAR_ENDARG)
    ch = *signature;

  /* @@@ unsupported result types or missing retval sig char */
  switch(ch) {
    case DC_SIGCHAR_BOOL:
    case DC_SIGCHAR_CHAR:
    case DC_SIGCHAR_UCHAR:
    case DC_SIGCHAR_SHORT:
    case DC_SIGCHAR_USHORT:
    case DC_SIGCHAR_INT:
    case DC_SIGCHAR_UINT:
    case DC_SIGCHAR_LONG:
    case DC_SIGCHAR_ULONG:
    case DC_SIGCHAR_LONGLONG:
    case DC_SIGCHAR_ULONGLONG:
    case DC_SIGCHAR_FLOAT:
    case DC_SIGCHAR_DOUBLE:
    case DC_SIGCHAR_STRING:
    case DC_SIGCHAR_POINTER:
      break;
    case DC_SIGCHAR_VOID:
    case DC_SIGCHAR_AGGREGATE:
    default:
      assert(0); return 'v';
  }

  GetReferenceResult(output, ch);

  return ch;
}


/* index range: [0,CONFIG_NSIGS[ */
static const char* GetSignature(int index)
{
  static const char* sigstrings[CONFIG_NSIGS] = {
#include "_auto_sigstrings.h"
  };

  return sigstrings[index];
}


#define X(CH,T) typedef T CH;
DEF_TYPES
#undef X

#define M ValueMatrix
#include "_auto_invoke_macros.h"
#include "_auto_invokers.h"
#undef M

void (*invokers[CONFIG_NSIGS])(void*) = {
#include "_auto_invoke_table.h"
};



int DoTest(int id)
{
  const char* signature;
  DCCallback* pcb;
  int result, index = id - 1;

  signature = GetSignature(index);
  printf("f%d(\t%s", id, signature);

  pcb = dcbNewCallback(signature, handler, (void*)signature, NULL);
  assert(pcb != NULL);

  /* invoke call */
  invokers[index]((void*)pcb);

  result = Compare(signature); 
  printf(" :%d\n", result);
  dcbFreeCallback(pcb);

  return result;
}

