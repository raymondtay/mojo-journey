	.build_version macos, 15, 0	sdk_version 15, 5
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_amx_smoke                      ## -- Begin function amx_smoke
	.p2align	4
_amx_smoke:                             ## @amx_smoke
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	andq	$-64, %rsp
	subq	$64, %rsp
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, 40(%rsp)
	vxorps	%xmm0, %xmm0, %xmm0
	vmovaps	%ymm0, (%rsp)
	movb	$1, (%rsp)
	movb	$64, 16(%rsp)
	movb	$16, 24(%rsp)
	movw	$16448, 17(%rsp)                ## imm = 0x4040
	movw	$4112, 25(%rsp)                 ## imm = 0x1010
	ldtilecfg	(%rsp)
	movslq	%ecx, %rax
	tileloadd	(%rdi,%rax), %tmm0
	movslq	%r8d, %rax
	tileloadd	(%rsi,%rax), %tmm1
	tdpbssd	%tmm1, %tmm0, %tmm2
	movslq	%r9d, %rax
	tilestored	%tmm2, (%rdx,%rax)
	tilerelease
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	cmpq	40(%rsp), %rax
	jne	LBB0_2
## %bb.1:
	movq	%rbp, %rsp
	popq	%rbp
	vzeroupper
	retq
LBB0_2:
	vzeroupper
	callq	___stack_chk_fail
	.cfi_endproc
                                        ## -- End function
.subsections_via_symbols
