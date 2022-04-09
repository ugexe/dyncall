/*

 Package: dyncall
 Library: test
 File: test/callback_suite/main.c
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

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "dyncall_callback.h"
#include "globals.h"
#include "../common/platformInit.h"
#include "../common/platformInit.c" /* Impl. for functions only used in this translation unit */




static void print_usage(const char* appName)
{
  printf("usage:\n\
%s [ from [to] ]\n\
where\n\
  from, to: test range (0-based, runs single test if \"to\" is omitted)\n\
options\n\
  -h        help on usage\n\
\n\
", appName);
}


/* -------------- this was do_test.c -------------------------- this was do_test.c ------------> */

static int cmp_values(char type, DCValue* a, DCValue* b)
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


static int cmp(const char* signature)
{
  DCValue ref;
  int r = 1;
  int pos;
  char ch;

  /* check arguments */
  pos = 0;
  for(;;)
  {
    ch = *signature++;
    
    if(ch == DC_SIGCHAR_CC_PREFIX) {
      ++signature; /* skip cconv prefix @@@STRUCT needs handling? */
      continue;
    }

    if (!ch || ch == DC_SIGCHAR_ENDARG)
      break;

    get_reference_arg(&ref, ch, pos);

    if ( !cmp_values( ch, &ref, &Args[pos] ) ) {
      r = 0;
      printf(" @%d[%c] ", pos, ch);
    }
    ++pos;
  }
    
  if(ch == DC_SIGCHAR_ENDARG)
    ch = *signature;

  /* check result */
  get_reference_result(&ref, ch);

  if (!cmp_values(ch, &ref, &Result)) {
    r = 0;
    printf(" @-1 ");
  }

  return r;
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
      assert(0); return DC_SIGCHAR_VOID;
  }

  get_reference_result(output, ch);

  return ch;
}




static int run_test(int id)
{
  const char* signature;
  DCCallback* pcb;
  int result;

  /* index range: [0,nsigs[ */
  signature = G_sigtab[id];
  printf("%d:%s", id, signature);

  pcb = dcbNewCallback(signature, handler, (void*)signature, NULL);
  assert(pcb != NULL);

  /* invoke call */
  G_funtab[id]((void*)pcb);

  result = cmp(signature); 
  printf(":%d\n", result);
  dcbFreeCallback(pcb);

  return result;
}


static int run_all(int from, int to)
{
  int i;
  int failure = 0;
  for(i=from; i<=to ;++i)
      failure |= !( run_test(i) );

  return !failure;
}

        
#define Error(X, Y, N) { fprintf(stderr, X, Y); print_usage(N); exit(1); }

int main(int argc, char* argv[])
{
  int from = 0, to = G_ncases-1;
  int i, pos = 0, total;

  dcTest_initPlatform();


  /* parse args */
  for(i=1; i<argc; ++i)
  {
    if(argv[i][0] == '-')
    {
      switch(argv[i][1]) {
        case 'h':
        case '?':
          print_usage(argv[0]);
          return 0;
        default:
          Error("invalid option: %s\n\n", argv[i], argv[0]);
      }      
    }
    switch(pos++) {
      case 0: from = to = atoi(argv[i]); break;
      case 1:        to = atoi(argv[i]); break;
      default: Error("too many arguments (%d given, 2 allowed)\n\n", pos, argv[0]);
    }
  }
  if(from < 0 || to >= G_ncases || from > to)
      Error("invalid arguments (provided from or to not in order or outside of range [0,%d])\n\n", G_ncases-1, argv[0]);


  init_test_data();
  total = run_all(from, to);
  deinit_test_data();

  printf("result: callback_suite: %d\n", total);

  dcTest_deInitPlatform();

  return !total;
}

