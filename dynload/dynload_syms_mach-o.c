/*

 Package: dyncall
 Library: dynload
 File: dynload/dynload_syms_mach-o.c
 Description: 
 License:

   Copyright (c) 2007-2015 Olivier Chafik <olivier.chafik@gmail.com>,
                      2017 refactored for stability, API consistency
                           and portability by Tassilo Philipp.

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



/*
 
 dynamic symbol resolver for Mach-O

*/

#include "dynload.h"
#include "dynload_alloc.h"
#include "../autovar/autovar_ARCH.h"

#include <mach-o/dyld.h>
#include <mach-o/nlist.h>
#include <sys/stat.h>
#include <dlfcn.h>
#include <string.h>

#if defined(ARCH_X64) || defined(ARCH_PPC64) || defined(ARCH_ARM64) //@@@ use dyncall_macros.h
#define MACH_HEADER_TYPE mach_header_64
#define NLIST_TYPE nlist_64
#else
#define MACH_HEADER_TYPE mach_header
#define NLIST_TYPE nlist
#endif


struct DLSyms_
{
	DLLib*                   pLib;
	const char*              pStringTable;
	const struct NLIST_TYPE* pSymbolTable;
	uint32_t                 symbolCount;
};


DLSyms* dlSymsInit(const char* libPath)
{
	DLLib* pLib;
	DLSyms* pSyms;
	uint32_t iImage, nImages;
	struct stat st0;

	if(stat(libPath, &st0) == -1)
		return NULL;

	pLib = dlLoadLibrary(libPath);
	if(!pLib)
		return NULL;

	// Loop over all dynamically linked images.
	for (iImage = 0, nImages = _dyld_image_count(); iImage < nImages; iImage++)
	{
		struct stat st1;
		const char* name = _dyld_get_image_name(iImage);

		if(name && (stat(name, &st1) != -1))
		{
			// Don't rely on name comparison alone, as libPath might be relative, symlink, differently 
			// cased, etc., but compare inode number with the one of the mapped dyld image.
			if (st0.st_ino == st1.st_ino/*!strcmp(name, libPath)*/)
			{
				const struct MACH_HEADER_TYPE* pHeader = (const struct MACH_HEADER_TYPE*) _dyld_get_image_header(iImage);
				const char* pBase = ((const char*)pHeader);
				if (pHeader->filetype != MH_DYLIB)
					return NULL;
				if (pHeader->flags & MH_SPLIT_SEGS)
					return NULL;

				if (pHeader)
				{
					uint32_t iCmd, nCmds = pHeader->ncmds;
					const struct load_command* cmd = (const struct load_command*)(pBase + sizeof(struct MACH_HEADER_TYPE));

					for (iCmd = 0; iCmd < nCmds; iCmd++) 
					{
						if (cmd->cmd == LC_SYMTAB) 
						{
							const struct symtab_command* scmd = (const struct symtab_command*)cmd;

							pSyms = (DLSyms*)( dlAllocMem(sizeof(DLSyms)) );
							pSyms->symbolCount  = scmd->nsyms;
							pSyms->pStringTable = pBase + scmd->stroff;
							pSyms->pSymbolTable = (struct NLIST_TYPE*)(pBase + scmd->symoff);
							pSyms->pLib         = pLib;

							return pSyms;
						}
						cmd = (const struct load_command*)(((char*)cmd) + cmd->cmdsize);
					}
				}
				break;
			}
		}
	}
	return NULL;
}


void dlSymsCleanup(DLSyms* pSyms)
{
	if(pSyms) {
		dlFreeLibrary(pSyms->pLib);
		dlFreeMem(pSyms);
	}
}

int dlSymsCount(DLSyms* pSyms)
{
	return pSyms ? pSyms->symbolCount : 0;
}

static const struct NLIST_TYPE* get_nlist(DLSyms* pSyms, int index)
{
	const struct NLIST_TYPE* nl;
	if (!pSyms)
		return NULL;

	nl = pSyms->pSymbolTable + index;
	if (nl->n_un.n_strx <= 1)
		return NULL; // would be empty string anyway

	//TODO skip more symbols based on nl->n_desc and nl->n_type ?
	return nl;
}


const char* dlSymsName(DLSyms* pSyms, int index)
{
	const struct NLIST_TYPE* nl = get_nlist(pSyms, index);
	return nl ? pSyms->pStringTable + nl->n_un.n_strx : NULL;
}


const char* dlSymsNameFromValue(DLSyms* pSyms, void* value)
{
	Dl_info info;
	if (!dladdr(value, &info) || (value != info.dli_saddr))
		return NULL;

	return info.dli_sname;
}

