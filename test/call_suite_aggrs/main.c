/*

 Package: dyncall
 Library: test
 File: test/call_suite_aggrs/main.c
 Description: 
 License:

   Copyright (c) 2022 Tassilo Philipp <tphilipp@potion-studios.com>

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

#include "dyncall.h"
#include "globals.h"
#include <string.h>
#include "../common/platformInit.h"
#include "../common/platformInit.c" /* Impl. for functions only used in this translation unit */


static void* G_callvm;


static int find_agg_idx(int* len, const char* sig)
{
  int i;
  for(i=0; i<G_naggs; ++i) {
    const char* agg_sig = G_agg_sigs[i];
    *len = strlen(agg_sig);
    if(strncmp(agg_sig, sig, *len) == 0)
      return i;
  }
  return -1;
}

static int invoke(char const* signature, void* t)
{
  DCCallVM   * p = (DCCallVM*) G_callvm;
  char const * sig = signature;
  char const * sig_args;
  char         rtype;
  DCaggr *     rtype_a = NULL;
  int          rtype_size = 0;
  funptr       rtype_a_cmp = NULL;
  char         atype;
  int          pos = 0;
  int          s = 0;

  clear_V();

  dcReset(p);

  if(*sig == '{' || *sig == '<') {
    int len;
    int i = find_agg_idx(&len, sig);
    if(i == -1) {
      printf("unknown rtype sig at '%s' ;", sig);
      return 0;
    }
    rtype = *sig;
    sig += len;

    rtype_size = G_agg_sizes[i];
    rtype_a_cmp = G_agg_cmpfuncs[i];
    rtype_a = ((DCaggr*(*)())G_agg_touchdcstfuncs[i])();
    dcBeginCallAggr(p, rtype_a);
  }
  else
    rtype = *sig++;

  sig_args = sig;

  while ( (atype = *sig) != '\0') {
    pos++;
    switch(atype) {
      case 'c': dcArgChar    (p,K_c[pos]); break;
      case 's': dcArgShort   (p,K_s[pos]); break;
      case 'i': dcArgInt     (p,K_i[pos]); break;
      case 'j': dcArgLong    (p,K_j[pos]); break;
      case 'l': dcArgLongLong(p,K_l[pos]); break;
      case 'p': dcArgPointer (p,K_p[pos]); break;
      case 'f': dcArgFloat   (p,K_f[pos]); break;
      case 'd': dcArgDouble  (p,K_d[pos]); break;
      case '<': /* union */
      case '{': /* struct */
      {
        /* find aggregate sig */
        int len;
        DCaggr *ag;
        int i = find_agg_idx(&len, sig);
        if(i == -1) {
          printf("unknown sig at '%s' ;", sig);
          return 0;
        }
        ag = ((DCaggr*(*)())G_agg_touchdcstfuncs[i])();
        dcArgAggr(p, ag, K_a[pos]);
        sig += len-1; /* advance to next arg char */
        break;
      }
      default: printf("unknown atype '%c' (1) ;", atype); return 0;
    }
    ++sig;
  }
  
  switch(rtype) 
  {
    case 'v': dcCallVoid(p,t); s=1; /*TODO:check that no return-arg was touched.*/ break;
    case 'c': s = (dcCallChar    (p,t) == K_c[pos]) ; break;
    case 's': s = (dcCallShort   (p,t) == K_s[pos]) ; break;
    case 'i': s = (dcCallInt     (p,t) == K_i[pos]) ; break;
    case 'j': s = (dcCallLong    (p,t) == K_j[pos]) ; break;
    case 'l': s = (dcCallLongLong(p,t) == K_l[pos]) ; break;
    case 'p': s = (dcCallPointer (p,t) == K_p[pos]) ; break;
    case 'f': s = (dcCallFloat   (p,t) == K_f[pos]) ; break;
    case 'd': s = (dcCallDouble  (p,t) == K_d[pos]) ; break;
    case '<': /* union */
    case '{': /* struct */
    {
      /* bound check memory adjacent to returned aggregate, to check for overflows by dcCallAggr */
      long long* adj_ll = (get_max_aggr_size() - rtype_size) > sizeof(long long) ? (long long*)((char*)V_a[0] + rtype_size) : NULL;
      if(adj_ll)
        *adj_ll = 0x0123456789abcdef;

      s = ((int(*)(const void*,const void*))rtype_a_cmp)(dcCallAggr(p, t, rtype_a, V_a[0]), K_a[pos]);

      if(adj_ll && *adj_ll != 0x0123456789abcdef) {
        printf("writing rval overflowed into adjacent memory;");
        return 0;
      }
      break;
    }
    default: printf("unknown rtype '%c'", rtype); return 0;
  }

  if (!s) { printf("rval wrong;"); return 0; }

  /* test V_* array against values passed to func: */
  sig = sig_args;
  pos = 1;
  while ( (atype = *sig) != '\0') {
    switch(atype) {
      case 'c': s = ( V_c[pos] == K_c[pos] ); if (!s) printf("'c':%d: %d != %d ; ",     pos, V_c[pos], K_c[pos]); break;
      case 's': s = ( V_s[pos] == K_s[pos] ); if (!s) printf("'s':%d: %d != %d ; ",     pos, V_s[pos], K_s[pos]); break;
      case 'i': s = ( V_i[pos] == K_i[pos] ); if (!s) printf("'i':%d: %d != %d ; ",     pos, V_i[pos], K_i[pos]); break;
      case 'j': s = ( V_j[pos] == K_j[pos] ); if (!s) printf("'j':%d: %ld != %ld ; ",   pos, V_j[pos], K_j[pos]); break;
      case 'l': s = ( V_l[pos] == K_l[pos] ); if (!s) printf("'l':%d: %lld != %lld ; ", pos, V_l[pos], K_l[pos]); break;
      case 'p': s = ( V_p[pos] == K_p[pos] ); if (!s) printf("'p':%d: %p != %p ; ",     pos, V_p[pos], K_p[pos]); break;
      case 'f': s = ( V_f[pos] == K_f[pos] ); if (!s) printf("'f':%d: %f != %f ; ",     pos, V_f[pos], K_f[pos]); break;
      case 'd': s = ( V_d[pos] == K_d[pos] ); if (!s) printf("'d':%d: %f != %f ; ",     pos, V_d[pos], K_d[pos]); break;
      case '<': /* union */
      case '{': /* struct */
      {
        /* no check: guaranteed to exist, or invoke func would've exited when passing args, above */
        int len;
        int i = find_agg_idx(&len, sig);
        s = ((int(*)(const void*,const void*))G_agg_cmpfuncs[i])(V_a[pos], K_a[pos]);
        if (!s) printf("'%c':%d:  *%p != *%p ; ", atype, pos, V_a[pos], K_a[pos]);
        sig += len-1; /* advance to next arg char */
        break;
      }
      default: printf("unknown atype '%c' ; ", atype); return 0;
    }
    if (!s) {
      printf("arg mismatch at %d ; ", pos);
      return 0;
    }
    ++sig;
    ++pos;
  }
  return 1;
}

int run_test(int i)
{  
  char const * sig;
  void * target;
  int success;
  sig = G_sigtab[i];
  target = (void*) G_funtab[i];
  printf("%d:%s:",i,sig);
  success = invoke(sig,target);
  printf("%d\n",success);
  return success;
}

int run_all()
{
  int i;
  int failure = 0;
  for(i=0;i<G_ncases;++i)
    failure |= !( run_test(i) );

  return !failure;
}

int main(int argc, char* argv[])
{
  int total, i;

  dcTest_initPlatform();

  init_test_data(G_maxargs);
  G_callvm = (DCCallVM*) dcNewCallVM(32768);

  dcReset(G_callvm);
  total = run_all();

  /* free all DCaggrs created on the fly */
  for(i=0; i<G_naggs; ++i)
    dcFreeAggr(((DCaggr*(*)())G_agg_touchdcstfuncs[i])());

  dcFree(G_callvm);
  deinit_test_data(G_maxargs);

  printf("result: call_suite_aggrs: %d\n", total);

  dcTest_deInitPlatform();

  return !total;
}

