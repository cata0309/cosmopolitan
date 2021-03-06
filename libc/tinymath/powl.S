/*-*- mode:unix-assembly; indent-tabs-mode:t; tab-width:8; coding:utf-8     -*-│
│vi: set et ft=asm ts=8 tw=8 fenc=utf-8                                     :vi│
╞══════════════════════════════════════════════════════════════════════════════╡
│ Copyright 2020 Justine Alexandra Roberts Tunney                              │
│                                                                              │
│ Permission to use, copy, modify, and/or distribute this software for         │
│ any purpose with or without fee is hereby granted, provided that the         │
│ above copyright notice and this permission notice appear in all copies.      │
│                                                                              │
│ THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL                │
│ WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED                │
│ WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE             │
│ AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL         │
│ DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR        │
│ PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER               │
│ TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR             │
│ PERFORMANCE OF THIS SOFTWARE.                                                │
╚─────────────────────────────────────────────────────────────────────────────*/
#include "libc/runtime/pc.internal.h"
#include "libc/macros.internal.h"

//	Returns 𝑥^𝑦.
//
//	@param	𝑥 is an 80-bit long double passed on stack in 16-bytes
//	@param	𝑦 is the power, also pushed on stack, in reverse order
//	@return	result of exponentiation on FPU stack in %st
//	@note	Sun's fdlibm needs 2kLOC to do this for RISC lool
//	@define	z=y*log2(fabs(x)),copysign(trunc(exp2(fmod(z,1)))*exp2(z),x)
powl:	push	%rbp
	mov	%rsp,%rbp
	.profilable
	fldt	32(%rbp)
	fldt	16(%rbp)
	fxam
	fstsw
	fabs
	fyl2x
	fld1
	fld	%st(1)
	fprem
	f2xm1
	faddp
	fscale
	fxch
	fstp	%st
	test	$FPU_C1>>8,%ah
	jz	1f
	fchs
1:	pop	%rbp
	ret
	.endfn	powl,globl
	.alias	powl,__powl_finite
