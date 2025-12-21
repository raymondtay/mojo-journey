Chapter X - CPU hyperscaling for Mojo Programmers
-

Modern CPU performance no longer comes from increasing clock frequency.
Instead, it comes from _hyperscaling_: architectural techniques that expand
parallelism, bandwidth, and compute density far faster than frequency ever
could.

For Mojo developers - especially those writing HPC kernels - the implications
are profound:

* Mojo data layout ⇒ determines SIMD throughput
* Loop structure ⇒ determines OoO (i.e., _Out Of Order_) SIMD throughput
* Memory access pattern ⇒ determines whether a CPU is compute-boujnd or stalled
* Choosing AoS vs SoA ⇒ can enable or disable hyperscaling.

p.s. the last point is particularly interesting.

1. Vector Hyperscaling: The Heart of Modern CPU throughput
--

Mojo is designed to generate machine code that maps directly to wide vector
units. This makes SIMD the primary vehicle of hyperscaling in Mojo. Below is an
illustration of how the hardware aspect of SIMD has expanded in its capacity:

| ISA | Vector Width | Lane Count (F32) | Typical Speedup |
|-- | -- | -- | -- |
| SSE | 128-bit | 4 | 4x |
| AVX | 256-bit | 8 | 8x |
| AVX-512 | 512-bit | 16 | 16x |
| AMX (Intel) | Tile registers | 8K-bit equivalent | 30-50x GEMM |
| RVV | 128-4096-bit | Variable | 4-128x |

Impacts?
When writing kernels, the compiler prefers structure-of-arrays and contiguous,
stride-1 patterns. These allow vector load/stores like:

```asm
vmovaps zmm0, [x + i*64] ; loads 16 floats at once
```

Avoiding AoS means Mojo can lower your loop into AVX-512 or AMX tiles w/o
re-writing the algorithm. Here's an example (see [source code](./src/00_loop_lowering.mojo)), when it happens:

```pre
     .file "loop_lowering.mojo"
     .text
     .globl "loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])"
     .p2align 4
     .type "loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])",@function
"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])":
".Lloop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])$local":
     .type ".Lloop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])$local",@function
     cmpq $16, %rdx
     jge .LBB0_5
     xorl %eax, %eax
     jmp .LBB0_2
.LBB0_5:
     vbroadcastss %xmm0, %zmm1
     xorl %ecx, %ecx
     .p2align 4
.LBB0_6:
     vmovaps (%rsi,%rcx,4), %zmm2
     vfmadd213ps (%rdi,%rcx,4), %zmm1, %zmm2
     vmovaps %zmm2, (%rdi,%rcx,4)
     leaq 16(%rcx), %rax
     addq $32, %rcx
     cmpq %rdx, %rcx
     movq %rax, %rcx
     jle .LBB0_6
.LBB0_2:
     cmpq %rdx, %rax
     jge .LBB0_4
     .p2align 4
.LBB0_3:
     vmovss (%rsi,%rax,4), %xmm1
     vfmadd213ss (%rdi,%rax,4), %xmm0, %xmm1
     vmovss %xmm1, (%rdi,%rax,4)
     incq %rax
     cmpq %rax, %rdx
     jne .LBB0_3
.LBB0_4:
     vzeroupper
     retq
.Lfunc_end0:
     .size "loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])", .Lfunc_end0-"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])"
     .size ".Lloop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])$local", .Lfunc_end0-"loop_lowering::saxpy16[::Origin[::Bool(True)],::Origin[::Bool(True)]](::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $0, ::AddressSpace(::Int(0))],::UnsafePointer[::Bool(True), ::SIMD[::DType(float32), ::Int(1)], $1, ::AddressSpace(::Int(0))],::Int,::SIMD[::DType(float32), ::Int(1)])"
    
     .section ".note.GNU-stack","",@progbits
```

Refer to the screenshot of it in action in Google Colab environment ![google colab](./images/00_loop_lowering.png).

Similary, if you wish to see the raw generated assembly, the current Mojo
compiler (version 0.26) provides the facility `mojo build --emit=asm <filename>`
and it can be passed along to _pixi_ to execute.

```mojo
!pixi run --manifest-path mojo_project/ mojo build --emit=asm mojo_project/loop_lowering.mojo
```
