/*
 * CUDA Kernels Implementation
 * Separable Gaussian Blur
 */

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

/*
 * Horizontal Gaussian blur kernel with shared memory optimization
 */
__global__ void gaussianBlurHorizontalKernel(
    const float* __restrict__ input,
    float* __restrict__ output,
    const float* __restrict__ kernel,
    int width,
    int height,
    int radius
) {
    extern __shared__ float sharedRow[];
    
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (y >= height) return;
    
    int sharedIdx = threadIdx.x + radius;
    
    // Load center data
    if (x < width) {
        sharedRow[sharedIdx] = input[y * width + x];
    }
    
    // Load left halo
    if (threadIdx.x < radius) {
        int leftX = blockIdx.x * blockDim.x - radius + threadIdx.x;
        sharedRow[threadIdx.x] = (leftX < 0) ? 
            input[y * width] : input[y * width + leftX];
    }
    
    // Load right halo
    if (threadIdx.x >= blockDim.x - radius) {
        int rightX = blockIdx.x * blockDim.x + threadIdx.x + radius;
        int sharedRightIdx = threadIdx.x + 2 * radius;
        sharedRow[sharedRightIdx] = (rightX >= width) ? 
            input[y * width + width - 1] : input[y * width + rightX];
    }
    
    __syncthreads();
    
    // Perform convolution
    if (x < width) {
        float sum = 0.0f;
        
        #pragma unroll
        for (int k = -radius; k <= radius; k++) {
            sum += sharedRow[sharedIdx + k] * kernel[k + radius];
        }
        
        output[y * width + x] = sum;
    }
}

/*
 * Vertical Gaussian blur kernel with shared memory optimization
 */
__global__ void gaussianBlurVerticalKernel(
    const float* __restrict__ input,
    float* __restrict__ output,
    const float* __restrict__ kernel,
    int width,
    int height,
    int radius
) {
    extern __shared__ float sharedCol[];
    
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (x >= width) return;
    
    int sharedIdx = threadIdx.y + radius;
    
    // Load center data
    if (y < height) {
        sharedCol[sharedIdx] = input[y * width + x];
    }
    
    // Load top halo
    if (threadIdx.y < radius) {
        int topY = blockIdx.y * blockDim.y - radius + threadIdx.y;
        sharedCol[threadIdx.y] = (topY < 0) ? 
            input[x] : input[topY * width + x];
    }
    
    // Load bottom halo
    if (threadIdx.y >= blockDim.y - radius) {
        int bottomY = blockIdx.y * blockDim.y + threadIdx.y + radius;
        int sharedBottomIdx = threadIdx.y + 2 * radius;
        sharedCol[sharedBottomIdx] = (bottomY >= height) ? 
            input[(height - 1) * width + x] : input[bottomY * width + x];
    }
    
    __syncthreads();
    
    // Perform convolution
    if (y < height) {
        float sum = 0.0f;
        
        #pragma unroll
        for (int k = -radius; k <= radius; k++) {
            sum += sharedCol[sharedIdx + k] * kernel[k + radius];
        }
        
        output[y * width + x] = sum;
    }
}

/*
 * C-style wrapper functions for C++ code
 */
extern "C" {

void launchGaussianBlurHorizontal(
    const float* input,
    float* output,
    const float* kernel,
    int width,
    int height,
    int radius,
    dim3 gridSize,
    dim3 blockSize,
    int sharedMemSize
) {
    gaussianBlurHorizontalKernel<<<gridSize, blockSize, sharedMemSize>>>(
        input, output, kernel, width, height, radius
    );
}

void launchGaussianBlurVertical(
    const float* input,
    float* output,
    const float* kernel,
    int width,
    int height,
    int radius,
    dim3 gridSize,
    dim3 blockSize,
    int sharedMemSize
) {
    gaussianBlurVerticalKernel<<<gridSize, blockSize, sharedMemSize>>>(
        input, output, kernel, width, height, radius
    );
}

} // extern "C"
