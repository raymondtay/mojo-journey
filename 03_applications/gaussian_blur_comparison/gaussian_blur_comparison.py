#!/usr/bin/env python3
"""
Gaussian Blur: Complete Comparison
Separable Convolution vs Full 2D Convolution

This standalone application demonstrates both approaches and verifies they produce
identical results while showing the performance difference.
"""

import numpy as np
from scipy import ndimage
import time
import argparse


def gaussian_2d_kernel(sigma=1.0, kernel_size=5):
    """
    Create 2D Gaussian kernel

    Args:
        sigma: Standard deviation of Gaussian
        kernel_size: Size of kernel (must be odd)

    Returns:
        2D numpy array of shape (kernel_size, kernel_size)
    """
    if kernel_size % 2 == 0:
        kernel_size += 1  # Ensure odd size

    x = np.arange(kernel_size) - kernel_size // 2
    y = np.arange(kernel_size) - kernel_size // 2
    x, y = np.meshgrid(x, y)

    # 2D Gaussian formula: G(x,y) = (1/(2πσ²)) * exp(-(x²+y²)/(2σ²))
    kernel = np.exp(-(x**2 + y**2) / (2 * sigma**2))
    kernel = kernel / kernel.sum()  # Normalize

    return kernel


def gaussian_1d_kernel(sigma=1.0, kernel_size=5):
    """
    Create 1D Gaussian kernel

    Args:
        sigma: Standard deviation of Gaussian
        kernel_size: Size of kernel (must be odd)

    Returns:
        1D numpy array of shape (kernel_size,)
    """
    if kernel_size % 2 == 0:
        kernel_size += 1

    x = np.arange(kernel_size) - kernel_size // 2

    # 1D Gaussian formula: G(x) = (1/√(2πσ²)) * exp(-x²/(2σ²))
    kernel = np.exp(-(x**2) / (2 * sigma**2))
    kernel = kernel / kernel.sum()  # Normalize

    return kernel


def gaussian_2d_full(image, sigma=1.0, kernel_size=5):
    """
    Apply Gaussian blur using full 2D convolution

    Args:
        image: Input image (2D numpy array)
        sigma: Standard deviation
        kernel_size: Size of kernel

    Returns:
        Blurred image
    """
    kernel = gaussian_2d_kernel(sigma, kernel_size)
    return ndimage.convolve(image, kernel, mode="reflect")


def gaussian_separable(image, sigma=1.0, kernel_size=5):
    """
    Apply Gaussian blur using separable convolution (two 1D passes)

    Args:
        image: Input image (2D numpy array)
        sigma: Standard deviation
        kernel_size: Size of kernel

    Returns:
        Blurred image
    """
    kernel_1d = gaussian_1d_kernel(sigma, kernel_size)

    # First pass: convolve along rows (horizontal)
    temp = ndimage.convolve1d(image, kernel_1d, axis=1, mode="reflect")

    # Second pass: convolve along columns (vertical)
    result = ndimage.convolve1d(temp, kernel_1d, axis=0, mode="reflect")

    return result


def create_test_image(width=1000, height=1000, pattern="gradient"):
    """
    Create a test image with various patterns

    Args:
        width: Image width
        height: Image height
        pattern: Type of pattern ('random', 'gradient', 'checkerboard', 'gaussian')

    Returns:
        2D numpy array
    """
    if pattern == "random":
        return np.random.rand(height, width).astype(np.float32)

    elif pattern == "gradient":
        x = np.linspace(0, 1, width)
        y = np.linspace(0, 1, height)
        X, Y = np.meshgrid(x, y)
        return (X + Y) / 2

    elif pattern == "checkerboard":
        image = np.zeros((height, width), dtype=np.float32)
        square_size = 32
        for i in range(0, height, square_size):
            for j in range(0, width, square_size):
                if ((i // square_size) + (j // square_size)) % 2 == 0:
                    image[i : i + square_size, j : j + square_size] = 1.0
        return image

    elif pattern == "gaussian":
        # Create a Gaussian blob in the center
        x = np.arange(width) - width // 2
        y = np.arange(height) - height // 2
        X, Y = np.meshgrid(x, y)
        return np.exp(-(X**2 + Y**2) / (2 * (min(width, height) / 6) ** 2))

    else:
        raise ValueError(f"Unknown pattern: {pattern}")


def benchmark_method(method_func, image, sigma, kernel_size, iterations=10):
    """
    Benchmark a blur method

    Args:
        method_func: Function to benchmark
        image: Input image
        sigma: Gaussian sigma
        kernel_size: Kernel size
        iterations: Number of iterations

    Returns:
        Dictionary with timing statistics
    """
    times = []

    # Warm-up run
    result = method_func(image, sigma, kernel_size)

    # Benchmark runs
    for _ in range(iterations):
        start = time.time()
        result = method_func(image, sigma, kernel_size)
        end = time.time()
        times.append((end - start) * 1000)  # Convert to ms

    return {
        "result": result,
        "min": min(times),
        "max": max(times),
        "mean": np.mean(times),
        "std": np.std(times),
        "median": np.median(times),
    }


def verify_results(result1, result2, tolerance=1e-10):
    """
    Verify that two results are identical within tolerance

    Args:
        result1: First result
        result2: Second result
        tolerance: Maximum acceptable difference

    Returns:
        Dictionary with verification statistics
    """
    diff = np.abs(result1 - result2)

    return {
        "max_diff": np.max(diff),
        "mean_diff": np.mean(diff),
        "identical": np.max(diff) < tolerance,
        "tolerance": tolerance,
    }


def print_kernel_info(sigma, kernel_size):
    """Print kernel information"""
    kernel_1d = gaussian_1d_kernel(sigma, kernel_size)
    kernel_2d = gaussian_2d_kernel(sigma, kernel_size)

    print(f"\n{'=' * 70}")
    print(f"Kernel Information (σ={sigma}, size={kernel_size}x{kernel_size})")
    print(f"{'=' * 70}")

    print(f"\n1D Kernel ({kernel_size} elements):")
    print(f"  Values: {kernel_1d}")
    print(f"  Sum: {kernel_1d.sum():.10f} (should be 1.0)")

    print(f"\n2D Kernel ({kernel_size}x{kernel_size} elements):")
    print(f"  Center row: {kernel_2d[kernel_size // 2, :]}")
    print(f"  Sum: {kernel_2d.sum():.10f} (should be 1.0)")

    # Verify separability
    outer_product = np.outer(kernel_1d, kernel_1d)
    separable_diff = np.max(np.abs(kernel_2d - outer_product))
    print(f"\n  Separability check:")
    print(f"    Max difference between 2D and outer(1D,1D): {separable_diff:.2e}")
    print(f"    Kernel is separable: {separable_diff < 1e-10}")


def print_benchmark_results(name, stats, image_size, kernel_size):
    """Print benchmark statistics"""
    height, width = image_size
    pixels = width * height
    throughput = (pixels / 1e6) / (stats["mean"] / 1000.0)
    ops_per_pixel = kernel_size * kernel_size if "2D" in name else 2 * kernel_size

    print(f"\n{name}:")
    print(f"  Time: {stats['mean']:.3f} ± {stats['std']:.3f} ms")
    print(f"  Range: [{stats['min']:.3f}, {stats['max']:.3f}] ms")
    print(f"  Throughput: {throughput:.2f} Mpixels/sec")
    print(f"  Operations/pixel: {ops_per_pixel}")


def save_output(filename, image):
    """Save image to file (as numpy array)"""
    np.save(filename, image)
    print(f"\nSaved output to: {filename}")


def main():
    parser = argparse.ArgumentParser(
        description="Gaussian Blur Comparison: Separable vs Full 2D Convolution"
    )
    parser.add_argument(
        "--width", type=int, default=1000, help="Image width (default: 1000)"
    )
    parser.add_argument(
        "--height", type=int, default=1000, help="Image height (default: 1000)"
    )
    parser.add_argument(
        "--sigma", type=float, default=2.0, help="Gaussian sigma (default: 2.0)"
    )
    parser.add_argument(
        "--kernel-size", type=int, default=11, help="Kernel size (default: 11)"
    )
    parser.add_argument(
        "--pattern",
        type=str,
        default="random",
        choices=["random", "gradient", "checkerboard", "gaussian"],
        help="Test pattern (default: random)",
    )
    parser.add_argument(
        "--iterations", type=int, default=10, help="Benchmark iterations (default: 10)"
    )
    parser.add_argument("--save", action="store_true", help="Save output images")

    args = parser.parse_args([])

    # Header
    print("=" * 70)
    print("Gaussian Blur: Separable vs Full 2D Convolution")
    print("=" * 70)

    # Configuration
    print(f"\nConfiguration:")
    print(f"  Image size: {args.width} x {args.height}")
    print(f"  Kernel size: {args.kernel_size} x {args.kernel_size}")
    print(f"  Sigma: {args.sigma}")
    print(f"  Pattern: {args.pattern}")
    print(f"  Benchmark iterations: {args.iterations}")

    # Create test image
    print(f"\nCreating test image ({args.pattern} pattern)...")
    image = create_test_image(args.width, args.height, args.pattern)

    # Print kernel information
    print_kernel_info(args.sigma, args.kernel_size)

    # Benchmark Full 2D Convolution
    print(f"\n{'=' * 70}")
    print("Benchmarking Full 2D Convolution")
    print(f"{'=' * 70}")
    stats_2d = benchmark_method(
        gaussian_2d_full, image, args.sigma, args.kernel_size, args.iterations
    )
    print_benchmark_results(
        "Full 2D Convolution", stats_2d, (args.height, args.width), args.kernel_size
    )

    # Benchmark Separable Convolution
    print(f"\n{'=' * 70}")
    print("Benchmarking Separable Convolution")
    print(f"{'=' * 70}")
    stats_sep = benchmark_method(
        gaussian_separable, image, args.sigma, args.kernel_size, args.iterations
    )
    print_benchmark_results(
        "Separable Convolution", stats_sep, (args.height, args.width), args.kernel_size
    )

    # Verify results are identical
    print(f"\n{'=' * 70}")
    print("Verification")
    print(f"{'=' * 70}")
    verification = verify_results(stats_2d["result"], stats_sep["result"])

    print(f"\nResult comparison:")
    print(f"  Max difference: {verification['max_diff']:.2e}")
    print(f"  Mean difference: {verification['mean_diff']:.2e}")
    print(
        f"  Results identical (tolerance={verification['tolerance']:.2e}): "
        f"{verification['identical']}"
    )

    # Performance comparison
    print(f"\n{'=' * 70}")
    print("Performance Summary")
    print(f"{'=' * 70}")

    speedup = stats_2d["mean"] / stats_sep["mean"]
    theoretical_speedup = args.kernel_size / 2

    print(f"\nSpeedup (Separable vs Full 2D):")
    print(f"  Actual: {speedup:.2f}x")
    print(f"  Theoretical: {theoretical_speedup:.2f}x")
    print(f"  Efficiency: {(speedup / theoretical_speedup) * 100:.1f}%")

    # Sample output values
    print(f"\n{'=' * 70}")
    print("Sample Output Values (center 5x5 region)")
    print(f"{'=' * 70}")

    cy, cx = args.height // 2, args.width // 2
    print("\nInput:")
    print(image[cy - 2 : cy + 3, cx - 2 : cx + 3])

    print("\nOutput (both methods produce identical results):")
    print(stats_sep["result"][cy - 2 : cy + 3, cx - 2 : cx + 3])

    # Save outputs if requested
    if args.save:
        save_output("input.npy", image)
        save_output("output_2d.npy", stats_2d["result"])
        save_output("output_separable.npy", stats_sep["result"])

    # Test multiple kernel sizes
    print(f"\n{'=' * 70}")
    print("Performance Scaling with Kernel Size")
    print(f"{'=' * 70}")

    print(
        f"\n{'Kernel':<10} {'Size':<8} {'2D Time':<12} {'Sep Time':<12} {'Speedup':<10} {'Theoretical'}"
    )
    print("-" * 70)

    for ksize in [3, 5, 7, 9, 11, 15, 21]:
        if ksize > args.kernel_size:
            break

        # Quick benchmark (fewer iterations)
        stats_2d_test = benchmark_method(
            gaussian_2d_full, image, args.sigma, ksize, iterations=3
        )
        stats_sep_test = benchmark_method(
            gaussian_separable, image, args.sigma, ksize, iterations=3
        )

        speedup_test = stats_2d_test["mean"] / stats_sep_test["mean"]
        theoretical = ksize / 2

        print(
            f"{ksize}x{ksize:<6} {ksize * ksize:<8} "
            f"{stats_2d_test['mean']:>10.2f}ms "
            f"{stats_sep_test['mean']:>10.2f}ms "
            f"{speedup_test:>8.2f}x "
            f"{theoretical:>10.2f}x"
        )

    print(f"\n{'=' * 70}")
    print("Completed Successfully!")
    print(f"{'=' * 70}\n")


if __name__ == "__main__":
    main()
