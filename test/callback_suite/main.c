/*

 Package: dyncall
 Library: test
 File: test/callback_suite/main.c
 Description: 
 License:

   Copyright (c) 2011-2021 Daniel Adler <dadler@uni-goettingen.de>,
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
#include "env.h"
#include "../common/platformInit.h"
#include "../common/platformInit.c" /* Impl. for functions only used in this translation unit */


static void PrintUsage(const char* appName)
{
  printf("usage:\n\
%s [ -v ] [ from [to] ]\n\
where\n\
  from, to: test range\n\
options\n\
  -v        verbose reports\n\
  -h        help on usage\n\
\n\
", appName);
}


/* test one case, returns error code */
int DoTest(int id);

void InitEnv();

        
#define Error(X, Y, N) { fprintf(stderr, X, Y); PrintUsage(N); exit(1); }

int main(int argc, char* argv[])
{
  int from = 1;
  int to = CONFIG_NSIGS;
  int ncases;

  int i;
  int pos;
  int totalResult;

  /* capture total results for failure (0) and success (1) */
  int totalErrorCodes[2] = { 0, 0 };

  dcTest_initPlatform();

  InitEnv();

  pos = 0;
  for(i = 1 ; i < argc ; ++i)
  {
    int number;

    if(argv[i][0] == '-')
    {
      switch(argv[i][1]) {
        case 'v':
          OptionVerbose = 1;
          continue;
        case 'h':
        case '?':
          PrintUsage(argv[0]);
          return 0;
        default: Error("invalid option: %s\n\n", argv[i], argv[0]);
      }      
    }

    number = atoi(argv[i]);
    switch(pos++) {
      case 0: to = from = number; break;
      case 1: to =        number; break;
      default: Error("too many arguments (%d given, 2 allowed)\n\n", pos, argv[0]);
    }
  }

  if(from <= 0 || to > CONFIG_NSIGS || from > to)
      Error("invalid arguments (provided from or to not in order or outside of range [1,%d])\n\n", CONFIG_NSIGS, argv[0]);

  ncases = (to - from) + 1;

  printf("case\tsignat.\tresult\n");

  for(i = from ; i <= to ; ++i )
    ++totalErrorCodes[!!DoTest(i)];

  totalResult = (totalErrorCodes[1] == ncases);
  printf("result: callback_suite: %d\n", totalResult);

  dcTest_deInitPlatform();

  return !totalResult;
}

