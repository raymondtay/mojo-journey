#!/bin/bash
# Simple script to build and run Gaussian Blur comparison

set -e

echo "========================================"
echo "Gaussian Blur Comparison Runner"
echo "========================================"
echo ""

# Check if CUDA is available
if command -v nvcc &> /dev/null; then
    CUDA_AVAILABLE=true
    echo "✓ CUDA compiler found: $(nvcc --version | grep release)"
else
    CUDA_AVAILABLE=false
    echo "✗ CUDA compiler not found (nvcc not in PATH)"
fi

# Check if Python is available
if command -v python3 &> /dev/null; then
    PYTHON_AVAILABLE=true
    echo "✓ Python found: $(python3 --version)"
    
    # Check for numpy and scipy
    if python3 -c "import numpy, scipy" &> /dev/null; then
        echo "✓ NumPy and SciPy installed"
    else
        echo "✗ NumPy or SciPy not installed"
        echo "  Install with: pip install numpy scipy"
        PYTHON_AVAILABLE=false
    fi
else
    PYTHON_AVAILABLE=false
    echo "✗ Python3 not found"
fi

echo ""

# Default parameters
WIDTH=1000
HEIGHT=1000
KERNEL_SIZE=11
SIGMA=2.0
PATTERN="random"
ITERATIONS=10

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --cuda-only)
            PYTHON_AVAILABLE=false
            shift
            ;;
        --python-only)
            CUDA_AVAILABLE=false
            shift
            ;;
        --width)
            WIDTH="$2"
            shift 2
            ;;
        --height)
            HEIGHT="$2"
            shift 2
            ;;
        --kernel-size)
            KERNEL_SIZE="$2"
            shift 2
            ;;
        --sigma)
            SIGMA="$2"
            shift 2
            ;;
        --pattern)
            PATTERN="$2"
            shift 2
            ;;
        --iterations)
            ITERATIONS="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --cuda-only          Run only CUDA version"
            echo "  --python-only        Run only Python version"
            echo "  --width N            Image width (default: 1000)"
            echo "  --height N           Image height (default: 1000)"
            echo "  --kernel-size N      Kernel size (default: 11)"
            echo "  --sigma N            Gaussian sigma (default: 2.0)"
            echo "  --pattern TYPE       Pattern type (default: random)"
            echo "  --iterations N       Benchmark iterations (default: 10)"
            echo "  --help               Show this help"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Run both versions"
            echo "  $0 --cuda-only --width 1920 --height 1080"
            echo "  $0 --python-only --kernel-size 15"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

PARAMS="--width $WIDTH --height $HEIGHT --kernel-size $KERNEL_SIZE --sigma $SIGMA --pattern $PATTERN --iterations $ITERATIONS"

echo "Configuration:"
echo "  Image: ${WIDTH}x${HEIGHT}"
echo "  Kernel: ${KERNEL_SIZE}x${KERNEL_SIZE}"
echo "  Sigma: $SIGMA"
echo "  Pattern: $PATTERN"
echo "  Iterations: $ITERATIONS"
echo ""

# Run CUDA version
if [ "$CUDA_AVAILABLE" = true ]; then
    echo "========================================"
    echo "Building and Running CUDA Version"
    echo "========================================"
    echo ""
    
    if [ ! -f "gaussian_blur_comparison_cuda" ]; then
        echo "Building CUDA application..."
        make -f Makefile_comparison cuda
        echo ""
    fi
    
    echo "Running CUDA version..."
    ./gaussian_blur_comparison_cuda $PARAMS
    echo ""
fi

# Run Python version
if [ "$PYTHON_AVAILABLE" = true ]; then
    echo "========================================"
    echo "Running Python Version"
    echo "========================================"
    echo ""
    
    python3 gaussian_blur_comparison.py $PARAMS
    echo ""
fi

# Summary
echo "========================================"
echo "Execution Summary"
echo "========================================"

if [ "$CUDA_AVAILABLE" = true ]; then
    echo "✓ CUDA version executed successfully"
else
    echo "✗ CUDA version not executed (not available)"
fi

if [ "$PYTHON_AVAILABLE" = true ]; then
    echo "✓ Python version executed successfully"
else
    echo "✗ Python version not executed (not available)"
fi

if [ "$CUDA_AVAILABLE" = true ] && [ "$PYTHON_AVAILABLE" = true ]; then
    echo ""
    echo "Both versions completed! Compare the results above."
fi

echo ""
