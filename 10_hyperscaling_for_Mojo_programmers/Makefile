SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

LLVM_CLANG := $(shell brew --prefix llvm 2>/dev/null)/bin/clang++

SRC := ./src/01_loop_lowering_amx.cpp
ASM := ./src/01_loop_lowering_amx.s

check-llvm:
	@test -x "$(LLVM_CLANG)" || \
	  (echo "❌ LLVM clang not found"; exit 1)

check-amx:
	@$(LLVM_CLANG) -mavx512f -mamx-tile -mamx-int8 -E /dev/null \
	  >/dev/null 2>&1 || \
	  (echo "❌ AMX flags not supported"; exit 1)

amx-asm: check-llvm check-amx
	@echo "→ Generating AMX assembly"
	@$(LLVM_CLANG) -O3 -S \
	  -target x86_64-apple-darwin \
	  -mavx512f -mamx-tile -mamx-int8 \
	  $(SRC) -o $(ASM)

	@grep -qE "ldtilecfg|tileloadd|tdpb|tilestored|tilerelease" $(ASM) || \
	  (echo "❌ AMX instructions missing"; exit 1)

	@echo "✅ AMX assembly verified"



