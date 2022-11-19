@ECHO OFF
REM ///////////////////////////////////////////////////////////////////////////
REM
REM Copyright (c) 2007-2022 Daniel Adler <dadler@uni-goettingen.de>,
REM                         Tassilo Philipp <tphilipp@potion-studios.com>
REM
REM Permission to use, copy, modify, and distribute this software for any
REM purpose with or without fee is hereby granted, provided that the above
REM copyright notice and this permission notice appear in all copies.
REM
REM THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
REM WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
REM MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
REM ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
REM WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
REM ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
REM OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
REM
REM ///////////////////////////////////////////////////////////////////////////


SETLOCAL

REM Set default values.
SET PACKAGE=dyncall
SET CONFIG_HOST=windows
SET CONFIG_OS=windows
SET CONFIG_TOOL=msvc
SET CONFIG_ASM=ml
IF [%PROCESSOR_ARCHITECTURE%] == [AMD64] (
	SET CONFIG_ARCH=x64
) ELSE IF [%PROCESSOR_ARCHITEW6432%] == [AMD64] (
	SET CONFIG_ARCH=x64
) ELSE IF [%PROCESSOR_ARCHITECTURE%] == [ARM64] (
	SET CONFIG_ARCH=arm64
) ELSE (
	SET CONFIG_ARCH=x86
)

REM Scan arguments.
:MAIN_LOOP


REM Help.
IF [%1]==[] (
	GOTO DONE
) ELSE IF [%1]==[/?] (
	ECHO.
	ECHO.dyncall configuration shell-script
	ECHO.Usage:
	ECHO.  configure.bat [ options ]
	ECHO.
	ECHO.Options:
	ECHO.  /?                print this page
	ECHO.
	ECHO.  /target-x86       build for x86 architecture
	ECHO.  /target-x64       build for x64 architecture
	ECHO.  /target-arm64     build for arm64 architecture
	ECHO.  /target-psp       cross-build for PlayStation Portable ^(homebrew SDK^)
	ECHO.  /target-nds-arm   cross-build for Nintendo DS ^(devkitPro, ARM mode^)
	ECHO.  /target-nds-thumb cross-build for Nintendo DS ^(devkitPro, THUMB mode^)
	ECHO.
	ECHO.  /tool-msvc        use Microsoft Visual C++ compiler ^(default^)
	ECHO.  /tool-gcc         use GNU Compiler Collection
	ECHO.  /tool-clang       use LLVM clang compiler
	ECHO.
	ECHO.  /asm-ml           use Microsoft Macro Assembler ^(default^)
	ECHO.  /asm-as           use the GNU or LLVM Assembler
	ECHO.  /asm-nasm         use NASM Assembler
	GOTO:EOF
) ELSE IF [%1]==[/target-x86] (
	SET CONFIG_ARCH=x86
) ELSE IF [%1]==[/target-x64] (
	SET CONFIG_ARCH=x64
) ELSE IF [%1]==[/target-arm64] (
	SET CONFIG_ARCH=arm64
) ELSE IF [%1]==[/target-psp] (
	SET CONFIG_ARCH=mips32
	SET CONFIG_OS=psp
) ELSE IF [%1]==[/target-nds-arm] (
	SET CONFIG_ARCH=arm32_arm
	SET CONFIG_OS=nds
) ELSE IF [%1]==[/target-nds-thumb] (
	SET CONFIG_ARCH=arm32_thumb
	SET CONFIG_OS=nds
) ELSE IF [%1]==[/tool-gcc] (
	SET CONFIG_TOOL=gcc
	SET CONFIG_ASM=as
) ELSE IF [%1]==[/tool-msvc] (
	SET CONFIG_TOOL=msvc
	SET CONFIG_ASM=ml
) ELSE IF [%1]==[/tool-clang] (
	SET CONFIG_TOOL=clang
	SET CONFIG_ASM=as
) ELSE IF [%1]==[/asm-as] (
	SET CONFIG_ASM=as
) ELSE IF [%1]==[/asm-nasm] (
	SET CONFIG_ASM=nasm
) ELSE IF [%1]==[/asm-ml] (
	SET CONFIG_ASM=ml
) ELSE (
	ECHO Unknown parameter '%1'.
	GOTO DONE
)

SHIFT
GOTO MAIN_LOOP
:DONE

ECHO # auto-generated by configure.bat >Makefile.config
ECHO CONFIG_PACKAGE=%PACKAGE%#>>Makefile.config
ECHO CONFIG_HOST=%CONFIG_HOST%#>>Makefile.config
ECHO CONFIG_OS=%CONFIG_OS%#>>Makefile.config
ECHO CONFIG_ARCH=%CONFIG_ARCH%#>>Makefile.config
ECHO CONFIG_TOOL=%CONFIG_TOOL%#>>Makefile.config
ECHO CONFIG_ASM=%CONFIG_ASM%#>>Makefile.config

ECHO Writing following configuration to Makefile.config:
ECHO.
ECHO Host OS:             %CONFIG_HOST%
ECHO Target OS:           %CONFIG_OS%
ECHO Target Architecture: %CONFIG_ARCH%
ECHO Compiler:            %CONFIG_TOOL%
ECHO Assembler:           %CONFIG_ASM%


REM We have to transform some pathes for the nds/devkitPro build.
IF [%CONFIG_OS%]==[nds] (
	REM Check if DEVKITPRO is set.
	IF [%DEVKITPRO%]==[] (
		ECHO ERROR: Environment variable DEVKITPRO must be set to absolute devkitPro path.
	) ELSE (
		buildsys\scripts\conf-nds.bat
	)
)

