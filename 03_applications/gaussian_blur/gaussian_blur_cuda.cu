/*
 * Separable Gaussian Blur - Pure CUDA Implementation
 * 
 * This implementation uses:
 * - Shared memory for efficient data reuse
 * - Separate kernels for horizontal and vertical passes
 * - Optimized memory access patterns
 */

#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdio.h>
#include <math.h>

#define KERNEL_RADIUS 5
#define KERNEL_SIZE (2 * KERNEL_RADIUS + 1)
#define BLOCK_SIZE 16

// Error checking macro
#define CUDA_CHECK(call) \
    do { \
        cudaError_t error = call; \
        if (error != cudaSuccess) { \
            fprintf(stderr, "CUDA error at %s:%d: %s\n", __FILE__, __LINE__, \
                    cudaGetErrorString(error)); \
            exit(EXIT_FAILURE); \
        } \
    } while(0)

/*
 * Generate 1D Gaussian kernel
 * Formula: G(x) = (1/sqrt(2*pi*sigma^2)) * exp(-x^2 / (2*sigma^2))
 */
__host__ void generateGaussianKernel(float* kernel, int radius, float sigma) {
    float sum = 0.0f;
    
    for (int i = -radius; i <= radius; i++) {
        float value = expf(-(i * i) / (2.0f * sigma * sigma));
        kernel[i + radius] = value;
        sum += value;
    }
    
    // Normalize
    for (int i = 0; i < 2 * radius + 1; i++) {
        kernel[i] /= sum;
    }
}

/*
 * Horizontal Gaussian blur kernel
 * Each thread processes one pixel, reading from shared memory
 */
__global__ void gaussianBlurHorizontal(
    const float* input,
    float* output,
    const float* kernel,
    int width,
    int height,
    int radius
) {
    // Shared memory for the row (includes halo region)
    extern __shared__ float sharedRow[];
    
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (y >= height) return;
    
    // Load data into shared memory with halo
    int sharedIdx = threadIdx.x + radius;
    
    // Load main data
    if (x < width) {
        sharedRow[sharedIdx] = input[y * width + x];
    }
    
    // Load left halo
    if (threadIdx.x < radius) {
        int leftX = blockIdx.x * blockDim.x - radius + threadIdx.x;
        if (leftX < 0) {
            sharedRow[threadIdx.x] = input[y * width + 0]; // Clamp
        } else {
            sharedRow[threadIdx.x] = input[y * width + leftX];
        }
    }
    
    // Load right halo
    if (threadIdx.x >= blockDim.x - radius) {
        int rightX = blockIdx.x * blockDim.x + threadIdx.x + radius;
        int sharedRightIdx = threadIdx.x + 2 * radius;
        if (rightX >= width) {
            sharedRow[sharedRightIdx] = input[y * width + width - 1]; // Clamp
        } else {
            sharedRow[sharedRightIdx] = input[y * width + rightX];
        }
    }
    
    __syncthreads();
    
    // Perform convolution
    if (x < width) {
        float sum = 0.0f;
        
        for (int k = -radius; k <= radius; k++) {
            sum += sharedRow[sharedIdx + k] * kernel[k + radius];
        }
        
        output[y * width + x] = sum;
    }
}

/*
 * Vertical Gaussian blur kernel
 * Each thread processes one pixel, reading columns
 */
__global__ void gaussianBlurVertical(
    const float* input,
    float* output,
    const float* kernel,
    int width,
    int height,
    int radius
) {
    // Shared memory for the column (includes halo region)
    extern __shared__ float sharedCol[];
    
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (x >= width) return;
    
    // Load data into shared memory with halo
    int sharedIdx = threadIdx.y + radius;
    
    // Load main data
    if (y < height) {
        sharedCol[sharedIdx] = input[y * width + x];
    }
    
    // Load top halo
    if (threadIdx.y < radius) {
        int topY = blockIdx.y * blockDim.y - radius + threadIdx.y;
        if (topY < 0) {
            sharedCol[threadIdx.y] = input[0 * width + x]; // Clamp
        } else {
            sharedCol[threadIdx.y] = input[topY * width + x];
        }
    }
    
    // Load bottom halo
    if (threadIdx.y >= blockDim.y - radius) {
        int bottomY = blockIdx.y * blockDim.y + threadIdx.y + radius;
        int sharedBottomIdx = threadIdx.y + 2 * radius;
        if (bottomY >= height) {
            sharedCol[sharedBottomIdx] = input[(height - 1) * width + x]; // Clamp
        } else {
            sharedCol[sharedBottomIdx] = input[bottomY * width + x];
        }
    }
    
    __syncthreads();
    
    // Perform convolution
    if (y < height) {
        float sum = 0.0f;
        
        for (int k = -radius; k <= radius; k++) {
            sum += sharedCol[sharedIdx + k] * kernel[k + radius];
        }
        
        output[y * width + x] = sum;
    }
}

/*
 * Apply separable Gaussian blur
 */
void applySeparableGaussianBlur(
    const float* d_input,
    float* d_output,
    float* d_temp,
    const float* d_kernel,
    int width,
    int height,
    int radius
) {
    dim3 blockSize(BLOCK_SIZE, BLOCK_SIZE);
    dim3 gridSize(
        (width + blockSize.x - 1) / blockSize.x,
        (height + blockSize.y - 1) / blockSize.y
    );
    
    // Shared memory size (block size + 2 * radius for halo)
    int sharedMemSize = (BLOCK_SIZE + 2 * radius) * sizeof(float);
    
    // Horizontal pass
    gaussianBlurHorizontal<<<gridSize, blockSize, sharedMemSize>>>(
        d_input, d_temp, d_kernel, width, height, radius
    );
    CUDA_CHECK(cudaGetLastError());
    
    // Vertical pass
    gaussianBlurVertical<<<gridSize, blockSize, sharedMemSize>>>(
        d_temp, d_output, d_kernel, width, height, radius
    );
    CUDA_CHECK(cudaGetLastError());
    
    CUDA_CHECK(cudaDeviceSynchronize());
}

/*
 * Main function demonstrating usage
 */
int main() {
    // Image dimensions
    const int width = 1920;
    const int height = 1080;
    const int imageSize = width * height * sizeof(float);
    
    // Gaussian parameters
    const int radius = KERNEL_RADIUS;
    const float sigma = 2.0f;
    const int kernelSize = 2 * radius + 1;
    
    printf("Separable Gaussian Blur (CUDA)\n");
    printf("Image size: %d x %d\n", width, height);
    printf("Kernel radius: %d (size: %d)\n", radius, kernelSize);
    printf("Sigma: %.2f\n\n", sigma);
    
    // Allocate host memory
    float* h_input = (float*)malloc(imageSize);
    float* h_output = (float*)malloc(imageSize);
    float* h_kernel = (float*)malloc(kernelSize * sizeof(float));
    
    // Initialize input with test pattern
    for (int i = 0; i < width * height; i++) {
        h_input[i] = (float)(rand() % 256) / 255.0f;
    }
    
    // Generate Gaussian kernel
    generateGaussianKernel(h_kernel, radius, sigma);
    
    printf("Gaussian kernel coefficients:\n");
    for (int i = 0; i < kernelSize; i++) {
        printf("%.6f ", h_kernel[i]);
    }
    printf("\n\n");
    
    // Allocate device memory
    float *d_input, *d_output, *d_temp, *d_kernel;
    CUDA_CHECK(cudaMalloc(&d_input, imageSize));
    CUDA_CHECK(cudaMalloc(&d_output, imageSize));
    CUDA_CHECK(cudaMalloc(&d_temp, imageSize));
    CUDA_CHECK(cudaMalloc(&d_kernel, kernelSize * sizeof(float)));
    
    // Copy data to device
    CUDA_CHECK(cudaMemcpy(d_input, h_input, imageSize, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_kernel, h_kernel, kernelSize * sizeof(float), cudaMemcpyHostToDevice));
    
    // Create CUDA events for timing
    cudaEvent_t start, stop;
    CUDA_CHECK(cudaEventCreate(&start));
    CUDA_CHECK(cudaEventCreate(&stop));
    
    // Warm-up run
    applySeparableGaussianBlur(d_input, d_output, d_temp, d_kernel, width, height, radius);
    
    // Timed run
    CUDA_CHECK(cudaEventRecord(start));
    applySeparableGaussianBlur(d_input, d_output, d_temp, d_kernel, width, height, radius);
    CUDA_CHECK(cudaEventRecord(stop));
    CUDA_CHECK(cudaEventSynchronize(stop));
    
    float milliseconds = 0;
    CUDA_CHECK(cudaEventElapsedTime(&milliseconds, start, stop));
    
    printf("Execution time: %.3f ms\n", milliseconds);
    printf("Throughput: %.2f Mpixels/sec\n", (width * height / 1e6) / (milliseconds / 1000.0f));
    
    // Copy result back to host
    CUDA_CHECK(cudaMemcpy(h_output, d_output, imageSize, cudaMemcpyDeviceToHost));
    
    // Verify result (check a few pixels)
    printf("\nSample output values:\n");
    for (int i = 0; i < 5; i++) {
        int idx = (height / 2) * width + (width / 2) + i;
        printf("Pixel[%d][%d]: %.6f\n", height / 2, width / 2 + i, h_output[idx]);
    }
    
    // Cleanup
    CUDA_CHECK(cudaEventDestroy(start));
    CUDA_CHECK(cudaEventDestroy(stop));
    CUDA_CHECK(cudaFree(d_input));
    CUDA_CHECK(cudaFree(d_output));
    CUDA_CHECK(cudaFree(d_temp));
    CUDA_CHECK(cudaFree(d_kernel));
    free(h_input);
    free(h_output);
    free(h_kernel);
    
    printf("\nGaussian blur completed successfully!\n");
    
    return 0;
}
