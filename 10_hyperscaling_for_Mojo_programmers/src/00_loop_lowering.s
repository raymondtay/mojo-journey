	.file	"loop_lowering.mojo"
	.text
	.globl	main
	.p2align	4
	.type	main,@function
main:
.Lmain$local:
	.type	.Lmain$local,@function
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	pushq	%rax
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -24
	.cfi_offset %rbp, -16
	movq	%rsi, %rbx
	movl	%edi, %ebp
	callq	KGEN_CompilerRT_AsyncRT_GetCurrentRuntime@PLT
	testq	%rax, %rax
	jne	.LBB0_2
	leaq	static_string_a61c3395ab9379d9(%rip), %rdi
	leaq	"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_0"(%rip), %rdx
	leaq	"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_1"(%rip), %rcx
	movl	$7, %esi
	callq	KGEN_CompilerRT_GetOrCreateGlobal@PLT
.LBB0_2:
	movl	%ebp, %edi
	movq	%rbx, %rsi
	callq	KGEN_CompilerRT_SetArgV@PLT
	callq	KGEN_CompilerRT_PrintStackTraceOnFault@PLT
	leaq	static_string_7721000d2ce925e7(%rip), %rdi
	leaq	static_string_65420c993a6cdc19(%rip), %rdx
	leaq	static_string_ed3f8f42647c4c49(%rip), %r8
	leaq	static_string_418411b90408e635(%rip), %rax
	leaq	static_string_bbe01a6a523daf15(%rip), %r10
	movq	%rsp, %r11
	movl	$3509, %esi
	movl	$303, %ecx
	movl	$32, %r9d
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	%r10
	.cfi_adjust_cfa_offset 8
	pushq	$3
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	pushq	%r11
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	callq	"std::io::io::print[*::Writable](*$0,::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::Bool,::FileDescriptor$),Ts=[[typevalue<#kgen.instref<\"std::compile::compile::CompiledFunctionInfo,func_type=[(!kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::int::Int\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\\22loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\\22,target=#kgen.target<triple = \\22x86_64-unknown-linux-gnu\\22, arch = \\22skylake-avx512\\22, features = \\22+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\\22, data_layout = \\22e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\\22, relocation_model = \\22pic\\22, simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \\22nvidia:sm_75\\22>\">>, struct<(struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, index, pointer<none>, struct<(pointer<none>, index)>)>]]"
	addq	$64, %rsp
	.cfi_adjust_cfa_offset -64
	callq	KGEN_CompilerRT_DestroyGlobals@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.size	.Lmain$local, .Lfunc_end0-main
	.cfi_endproc

	.p2align	4
	.type	"std::compile::compile::CompiledFunctionInfo::write_to[::Writer](::CompiledFunctionInfo[$0, $1, $2],$3&),func_type=[(!kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::int::Int\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::simd::SIMD,dtype=f32,size=1\">>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\",target=#kgen.target<triple = \"x86_64-unknown-linux-gnu\", arch = \"skylake-avx512\", features = \"+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\", data_layout = \"e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\", relocation_model = \"pic\", simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \"nvidia:sm_75\">,T`2x=[typevalue<#kgen.instref<\"std::io::write::_WriteBufferStack,origin={  },W=[typevalue<#kgen.instref<\\1B\\22std::io::file_descriptor::FileDescriptor\\22>>, index],stack_buffer_bytes=4096\">>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, index, pointer<index>) memoryOnly>]",@function
"std::compile::compile::CompiledFunctionInfo::write_to[::Writer](::CompiledFunctionInfo[$0, $1, $2],$3&),func_type=[(!kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::int::Int\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::simd::SIMD,dtype=f32,size=1\">>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\",target=#kgen.target<triple = \"x86_64-unknown-linux-gnu\", arch = \"skylake-avx512\", features = \"+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\", data_layout = \"e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\", relocation_model = \"pic\", simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \"nvidia:sm_75\">,T`2x=[typevalue<#kgen.instref<\"std::io::write::_WriteBufferStack,origin={  },W=[typevalue<#kgen.instref<\\1B\\22std::io::file_descriptor::FileDescriptor\\22>>, index],stack_buffer_bytes=4096\">>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, index, pointer<index>) memoryOnly>]":
	.cfi_startproc
	movq	%rsi, %rdx
	movq	%rdi, %rsi
	movq	40(%rsp), %rdi
	jmp	"std::io::write::_WriteBufferStack::write_bytes[::Bool,::Origin[$3]](::_WriteBufferStack[$0, $1, $2]&,::Span[$3, ::SIMD[::DType(uint8), ::Int(1)], $4]),W=[typevalue<#kgen.instref<\"std::io::file_descriptor::FileDescriptor\">>, index],stack_buffer_bytes=4096,mut`2x1=0"
.Lfunc_end1:
	.size	"std::compile::compile::CompiledFunctionInfo::write_to[::Writer](::CompiledFunctionInfo[$0, $1, $2],$3&),func_type=[(!kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::int::Int\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::simd::SIMD,dtype=f32,size=1\">>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\",target=#kgen.target<triple = \"x86_64-unknown-linux-gnu\", arch = \"skylake-avx512\", features = \"+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\", data_layout = \"e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\", relocation_model = \"pic\", simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \"nvidia:sm_75\">,T`2x=[typevalue<#kgen.instref<\"std::io::write::_WriteBufferStack,origin={  },W=[typevalue<#kgen.instref<\\1B\\22std::io::file_descriptor::FileDescriptor\\22>>, index],stack_buffer_bytes=4096\">>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, index, pointer<index>) memoryOnly>]", .Lfunc_end1-"std::compile::compile::CompiledFunctionInfo::write_to[::Writer](::CompiledFunctionInfo[$0, $1, $2],$3&),func_type=[(!kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::int::Int\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::simd::SIMD,dtype=f32,size=1\">>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\",target=#kgen.target<triple = \"x86_64-unknown-linux-gnu\", arch = \"skylake-avx512\", features = \"+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\", data_layout = \"e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\", relocation_model = \"pic\", simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \"nvidia:sm_75\">,T`2x=[typevalue<#kgen.instref<\"std::io::write::_WriteBufferStack,origin={  },W=[typevalue<#kgen.instref<\\1B\\22std::io::file_descriptor::FileDescriptor\\22>>, index],stack_buffer_bytes=4096\">>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, index, pointer<index>) memoryOnly>]"
	.cfi_endproc

	.p2align	4
	.type	"std::io::write::_WriteBufferStack::write_bytes[::Bool,::Origin[$3]](::_WriteBufferStack[$0, $1, $2]&,::Span[$3, ::SIMD[::DType(uint8), ::Int(1)], $4]),W=[typevalue<#kgen.instref<\"std::io::file_descriptor::FileDescriptor\">>, index],stack_buffer_bytes=4096,mut`2x1=0",@function
"std::io::write::_WriteBufferStack::write_bytes[::Bool,::Origin[$3]](::_WriteBufferStack[$0, $1, $2]&,::Span[$3, ::SIMD[::DType(uint8), ::Int(1)], $4]),W=[typevalue<#kgen.instref<\"std::io::file_descriptor::FileDescriptor\">>, index],stack_buffer_bytes=4096,mut`2x1=0":
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rdx, %rbx
	movq	%rsi, %r15
	movq	%rdi, %r14
	cmpq	$4097, %rdx
	jl	.LBB2_1
	movq	4096(%r14), %rdx
	movq	4104(%r14), %rax
	movq	(%rax), %rdi
	movq	%r14, %rsi
	callq	write@PLT
	movq	$0, 4096(%r14)
	movq	4104(%r14), %rax
	movq	(%rax), %rdi
	movq	%r15, %rsi
	movq	%rbx, %rdx
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmp	write@PLT
.LBB2_1:
	.cfi_def_cfa_offset 48
	movq	4096(%r14), %rdx
	leaq	(%rdx,%rbx), %rax
	cmpq	$4097, %rax
	jl	.LBB2_3
	movq	4104(%r14), %rax
	movq	(%rax), %rdi
	movq	%r14, %rsi
	callq	write@PLT
	movq	$0, 4096(%r14)
	xorl	%edx, %edx
.LBB2_3:
	addq	%r14, %rdx
	cmpq	$4, %rbx
	jg	.LBB2_7
	testq	%rbx, %rbx
	je	.LBB2_15
	movzbl	(%r15), %eax
	movb	%al, (%rdx)
	movzbl	-1(%r15,%rbx), %eax
	movb	%al, -1(%rdx,%rbx)
	cmpq	$3, %rbx
	jl	.LBB2_15
	movzbl	1(%r15), %eax
	movb	%al, 1(%rdx)
	movzbl	-2(%r15,%rbx), %eax
	movb	%al, -2(%rdx,%rbx)
	jmp	.LBB2_15
.LBB2_7:
	cmpq	$16, %rbx
	jg	.LBB2_11
	cmpq	$8, %rbx
	jl	.LBB2_10
	movq	(%r15), %rax
	movq	%rax, (%rdx)
	movq	-8(%r15,%rbx), %rax
	movq	%rax, -8(%rdx,%rbx)
	jmp	.LBB2_15
.LBB2_11:
	movabsq	$9223372036854775776, %r12
	andq	%rbx, %r12
	je	.LBB2_13
	leaq	-1(%r12), %rax
	andq	$-32, %rax
	addq	$32, %rax
	movq	%rdx, %rdi
	movq	%r15, %rsi
	movq	%rdx, %r13
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	%r13, %rdx
.LBB2_13:
	testb	$31, %bl
	je	.LBB2_15
	leaq	-1(%rbx), %rax
	addq	%r12, %rdx
	addq	%r12, %r15
	subq	%r12, %rax
	movq	%rax, %rcx
	sarq	$63, %rcx
	andq	%rax, %rcx
	addq	%r12, %rcx
	movq	%rbx, %rax
	subq	%rcx, %rax
	movq	%rdx, %rdi
	movq	%r15, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	jmp	.LBB2_15
.LBB2_10:
	movl	(%r15), %eax
	movl	%eax, (%rdx)
	movl	-4(%r15,%rbx), %eax
	movl	%eax, -4(%rdx,%rbx)
.LBB2_15:
	addq	%rbx, 4096(%r14)
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	"std::io::write::_WriteBufferStack::write_bytes[::Bool,::Origin[$3]](::_WriteBufferStack[$0, $1, $2]&,::Span[$3, ::SIMD[::DType(uint8), ::Int(1)], $4]),W=[typevalue<#kgen.instref<\"std::io::file_descriptor::FileDescriptor\">>, index],stack_buffer_bytes=4096,mut`2x1=0", .Lfunc_end2-"std::io::write::_WriteBufferStack::write_bytes[::Bool,::Origin[$3]](::_WriteBufferStack[$0, $1, $2]&,::Span[$3, ::SIMD[::DType(uint8), ::Int(1)], $4]),W=[typevalue<#kgen.instref<\"std::io::file_descriptor::FileDescriptor\">>, index],stack_buffer_bytes=4096,mut`2x1=0"
	.cfi_endproc

	.p2align	4
	.type	"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_0",@function
"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_0":
	.cfi_startproc
	xorl	%edi, %edi
	jmp	KGEN_CompilerRT_AsyncRT_CreateRuntime@PLT
.Lfunc_end3:
	.size	"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_0", .Lfunc_end3-"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_0"
	.cfi_endproc

	.p2align	4
	.type	"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_1",@function
"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_1":
	.cfi_startproc
	jmp	KGEN_CompilerRT_AsyncRT_DestroyRuntime@PLT
.Lfunc_end4:
	.size	"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_1", .Lfunc_end4-"std::builtin::_startup::__wrap_and_execute_main[fn() -> None](::SIMD[::DType(int32), ::Int(1)],!kgen.pointer<pointer<scalar<ui8>>>),main_func=\"loop_lowering::main()\"_closure_1"
	.cfi_endproc

	.p2align	4
	.type	"std::io::io::_flush(::FileDescriptor)",@function
"std::io::io::_flush(::FileDescriptor)":
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	callq	dup@PLT
	leaq	static_string_0d78baac08237ddb(%rip), %rsi
	movl	%eax, %edi
	callq	fdopen@PLT
	movq	%rax, %rbx
	movq	%rax, %rdi
	callq	fflush@PLT
	movq	%rbx, %rdi
	popq	%rbx
	.cfi_def_cfa_offset 8
	jmp	fclose@PLT
.Lfunc_end5:
	.size	"std::io::io::_flush(::FileDescriptor)", .Lfunc_end5-"std::io::io::_flush(::FileDescriptor)"
	.cfi_endproc

	.p2align	4
	.type	"std::io::io::print[*::Writable](*$0,::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::Bool,::FileDescriptor$),Ts=[[typevalue<#kgen.instref<\"std::compile::compile::CompiledFunctionInfo,func_type=[(!kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::int::Int\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\\22loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\\22,target=#kgen.target<triple = \\22x86_64-unknown-linux-gnu\\22, arch = \\22skylake-avx512\\22, features = \\22+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\\22, data_layout = \\22e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\\22, relocation_model = \\22pic\\22, simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \\22nvidia:sm_75\\22>\">>, struct<(struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, index, pointer<none>, struct<(pointer<none>, index)>)>]]",@function
"std::io::io::print[*::Writable](*$0,::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::Bool,::FileDescriptor$),Ts=[[typevalue<#kgen.instref<\"std::compile::compile::CompiledFunctionInfo,func_type=[(!kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::int::Int\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\\22loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\\22,target=#kgen.target<triple = \\22x86_64-unknown-linux-gnu\\22, arch = \\22skylake-avx512\\22, features = \\22+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\\22, data_layout = \\22e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\\22, relocation_model = \\22pic\\22, simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \\22nvidia:sm_75\\22>\">>, struct<(struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, index, pointer<none>, struct<(pointer<none>, index)>)>]]":
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	subq	$4160, %rsp
	.cfi_def_cfa_offset 4192
	.cfi_offset %rbx, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	4224(%rsp), %rbx
	vmovups	4192(%rsp), %ymm0
	movq	4232(%rsp), %r14
	movq	4248(%rsp), %rax
	movq	%rax, 40(%rsp)
	movq	$0, 4144(%rsp)
	leaq	40(%rsp), %rax
	movq	%rax, 4152(%rsp)
	leaq	48(%rsp), %r15
	movq	%r15, 32(%rsp)
	vmovups	%ymm0, (%rsp)
	vzeroupper
	callq	"std::compile::compile::CompiledFunctionInfo::write_to[::Writer](::CompiledFunctionInfo[$0, $1, $2],$3&),func_type=[(!kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>, scalar<f32>],origin={  },address_space=0\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::int::Int\">>, !kgen.typevalue<#kgen.instref<\"std::builtin::simd::SIMD,dtype=f32,size=1\">>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\",target=#kgen.target<triple = \"x86_64-unknown-linux-gnu\", arch = \"skylake-avx512\", features = \"+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\", data_layout = \"e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\", relocation_model = \"pic\", simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \"nvidia:sm_75\">,T`2x=[typevalue<#kgen.instref<\"std::io::write::_WriteBufferStack,origin={  },W=[typevalue<#kgen.instref<\\1B\\22std::io::file_descriptor::FileDescriptor\\22>>, index],stack_buffer_bytes=4096\">>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, index, pointer<index>) memoryOnly>]"
	movq	%r15, %rdi
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	"std::io::write::_WriteBufferStack::write_bytes[::Bool,::Origin[$3]](::_WriteBufferStack[$0, $1, $2]&,::Span[$3, ::SIMD[::DType(uint8), ::Int(1)], $4]),W=[typevalue<#kgen.instref<\"std::io::file_descriptor::FileDescriptor\">>, index],stack_buffer_bytes=4096,mut`2x1=0"
	movq	4144(%rsp), %rdx
	movq	4152(%rsp), %rax
	movq	(%rax), %rdi
	movq	%r15, %rsi
	callq	write@PLT
	testb	$1, 4240(%rsp)
	je	.LBB6_1
	movq	40(%rsp), %rdi
	addq	$4160, %rsp
	.cfi_def_cfa_offset 32
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmp	"std::io::io::_flush(::FileDescriptor)"
.LBB6_1:
	.cfi_def_cfa_offset 4192
	addq	$4160, %rsp
	.cfi_def_cfa_offset 32
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end6:
	.size	"std::io::io::print[*::Writable](*$0,::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::Bool,::FileDescriptor$),Ts=[[typevalue<#kgen.instref<\"std::compile::compile::CompiledFunctionInfo,func_type=[(!kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::int::Int\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\\22loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\\22,target=#kgen.target<triple = \\22x86_64-unknown-linux-gnu\\22, arch = \\22skylake-avx512\\22, features = \\22+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\\22, data_layout = \\22e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\\22, relocation_model = \\22pic\\22, simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \\22nvidia:sm_75\\22>\">>, struct<(struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, index, pointer<none>, struct<(pointer<none>, index)>)>]]", .Lfunc_end6-"std::io::io::print[*::Writable](*$0,::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::StringSlice[::Bool(False), ::Origin[::Bool(False)](StaticConstantOrigin)],::Bool,::FileDescriptor$),Ts=[[typevalue<#kgen.instref<\"std::compile::compile::CompiledFunctionInfo,func_type=[(!kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::memory::unsafe_pointer::UnsafePointer,mut=1,type=[typevalue<#kgen.instref<\\\\1B\\\\22std::builtin::simd::SIMD,dtype=f32,size=1\\\\22>>, scalar<f32>],origin={  },address_space=0\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::int::Int\\22>>, !kgen.typevalue<#kgen.instref<\\1B\\22std::builtin::simd::SIMD,dtype=f32,size=1\\22>>) -> !kgen.none, (!kgen.pointer<none>, !kgen.pointer<none>, index, !pop.scalar<f32>) -> !kgen.none],func=\\22loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\\22,target=#kgen.target<triple = \\22x86_64-unknown-linux-gnu\\22, arch = \\22skylake-avx512\\22, features = \\22+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves\\22, data_layout = \\22e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\\22, relocation_model = \\22pic\\22, simd_bit_width = 512, index_bit_width = 64, accelerator_arch = \\22nvidia:sm_75\\22>\">>, struct<(struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, struct<(pointer<none>, index)>, index, pointer<none>, struct<(pointer<none>, index)>)>]]"
	.cfi_endproc

	.type	static_string_a61c3395ab9379d9,@object
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
static_string_a61c3395ab9379d9:
	.asciz	"Runtime"
	.size	static_string_a61c3395ab9379d9, 8

	.type	static_string_65420c993a6cdc19,@object
	.p2align	4, 0x0
static_string_65420c993a6cdc19:
	.asciz	"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])"
	.size	static_string_65420c993a6cdc19, 304

	.type	static_string_ed3f8f42647c4c49,@object
	.p2align	4, 0x0
static_string_ed3f8f42647c4c49:
	.asciz	"799669ac480e2df3a756e073923e352f"
	.size	static_string_ed3f8f42647c4c49, 33

	.type	static_string_7721000d2ce925e7,@object
	.p2align	4, 0x0
static_string_7721000d2ce925e7:
	.asciz	"\t.file\t\"loop_lowering.mojo\"\n\t.text\n\t.globl\t\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\"\n\t.p2align\t4\n\t.type\t\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\",@function\n\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\":\n\".Lloop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])$local\":\n\t.type\t\".Lloop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])$local\",@function\n\tcmpq\t$16, %rdx\n\tjge\t.LBB0_5\n\txorl\t%eax, %eax\n\tjmp\t.LBB0_2\n.LBB0_5:\n\tvbroadcastss\t%xmm0, %zmm1\n\txorl\t%ecx, %ecx\n\t.p2align\t4\n.LBB0_6:\n\tvmovaps\t(%rsi,%rcx,4), %zmm2\n\tvfmadd213ps\t(%rdi,%rcx,4), %zmm1, %zmm2\n\tvmovaps\t%zmm2, (%rdi,%rcx,4)\n\tleaq\t16(%rcx), %rax\n\taddq\t$32, %rcx\n\tcmpq\t%rdx, %rcx\n\tmovq\t%rax, %rcx\n\tjle\t.LBB0_6\n.LBB0_2:\n\tcmpq\t%rdx, %rax\n\tjge\t.LBB0_4\n\t.p2align\t4\n.LBB0_3:\n\tvmovss\t(%rsi,%rax,4), %xmm1\n\tvfmadd213ss\t(%rdi,%rax,4), %xmm0, %xmm1\n\tvmovss\t%xmm1, (%rdi,%rax,4)\n\tincq\t%rax\n\tcmpq\t%rax, %rdx\n\tjne\t.LBB0_3\n.LBB0_4:\n\tvzeroupper\n\tretq\n.Lfunc_end0:\n\t.size\t\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\", .Lfunc_end0-\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\"\n\t.size\t\".Lloop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])$local\", .Lfunc_end0-\"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])\"\n\n\t.section\t\".note.GNU-stack\",\"\",@progbits\n"
	.size	static_string_7721000d2ce925e7, 3510

	.type	static_string_418411b90408e635,@object
	.p2align	4, 0x0
static_string_418411b90408e635:
	.asciz	"asm"
	.size	static_string_418411b90408e635, 4

	.type	static_string_bbe01a6a523daf15,@object
	.p2align	4, 0x0
static_string_bbe01a6a523daf15:
	.asciz	"\n"
	.size	static_string_bbe01a6a523daf15, 2

	.type	static_string_0d78baac08237ddb,@object
	.p2align	4, 0x0
static_string_0d78baac08237ddb:
	.asciz	"a"
	.size	static_string_0d78baac08237ddb, 2

	.section	".note.GNU-stack","",@progbits


