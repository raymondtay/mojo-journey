# Makefile for Gaussian Blur CUDA implementations
# Supports both standalone CUDA and C++ with CUDA versions

# Compiler settings
NVCC = nvcc
CXX = g++

# CUDA architecture (adjust based on your GPU)
# Common options:
# - sm_50: Maxwell (GTX 900 series)
# - sm_60: Pascal (GTX 10 series)
# - sm_70: Volta (Tesla V100)
# - sm_75: Turing (RTX 20 series)
# - sm_80: Ampere (RTX 30 series, A100)
# - sm_86: Ampere (RTX 30 series mobile)
# - sm_89: Ada Lovelace (RTX 40 series)
CUDA_ARCH = sm_75

# Compiler flags
NVCC_FLAGS = -arch=$(CUDA_ARCH) -O3 --use_fast_math -Xcompiler -Wall
CXX_FLAGS = -std=c++11 -Wall -O3

# CUDA include and library paths (adjust if needed)
CUDA_INC = /usr/local/cuda/include
CUDA_LIB = /usr/local/cuda/lib64

# Targets
TARGETS = gaussian_blur_cuda gaussian_blur_cpp

.PHONY: all clean

all: $(TARGETS)

# Standalone CUDA implementation
gaussian_blur_cuda: gaussian_blur_cuda.cu
	$(NVCC) $(NVCC_FLAGS) $< -o $@
	@echo "Built standalone CUDA implementation: $@"

# C++ with CUDA implementation (requires separate compilation)
gaussian_blur_kernels.o: gaussian_blur_kernels.cu
	$(NVCC) $(NVCC_FLAGS) -c $< -o $@

main.o: main.cpp gaussian_blur.hpp
	$(NVCC) $(NVCC_FLAGS) -x cu -c $< -o $@

gaussian_blur_cpp: main.o gaussian_blur_kernels.o
	$(NVCC) $(NVCC_FLAGS) $^ -o $@
	@echo "Built C++ with CUDA implementation: $@"

# Run targets
run_cuda: gaussian_blur_cuda
	@echo "\n=== Running Standalone CUDA Implementation ==="
	./gaussian_blur_cuda

run_cpp: gaussian_blur_cpp
	@echo "\n=== Running C++ with CUDA Implementation ==="
	./gaussian_blur_cpp

run: run_cuda run_cpp

# Clean build artifacts
clean:
	rm -f $(TARGETS) *.o
	@echo "Cleaned build artifacts"

# Help target
help:
	@echo "Gaussian Blur CUDA Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all              - Build all implementations (default)"
	@echo "  gaussian_blur_cuda - Build standalone CUDA version"
	@echo "  gaussian_blur_cpp  - Build C++ with CUDA version"
	@echo "  run_cuda         - Build and run standalone CUDA"
	@echo "  run_cpp          - Build and run C++ with CUDA"
	@echo "  run              - Run both implementations"
	@echo "  clean            - Remove build artifacts"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  CUDA_ARCH=$(CUDA_ARCH) - Target GPU architecture"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Build all"
	@echo "  make run                # Build and run both"
	@echo "  make CUDA_ARCH=sm_80    # Build for Ampere (RTX 30 series)"
	@echo "  make clean              # Clean build files"
