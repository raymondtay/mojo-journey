/*
 * Separable Gaussian Blur - C++ with CUDA Implementation
 * 
 * This is a C++ wrapper around CUDA kernels providing:
 * - Object-oriented interface
 * - RAII memory management
 * - Support for multiple data types (float, uchar)
 * - Easy-to-use API
 */

#ifndef GAUSSIAN_BLUR_HPP
#define GAUSSIAN_BLUR_HPP

#include <cuda_runtime.h>
#include <vector>
#include <memory>
#include <stdexcept>
#include <cmath>
#include <iostream>

// CUDA kernel declarations
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
    );
    
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
    );
}

namespace gpu {

// RAII wrapper for CUDA device memory
template<typename T>
class DeviceBuffer {
private:
    T* d_ptr_;
    size_t size_;
    
public:
    DeviceBuffer(size_t size) : size_(size) {
        cudaError_t err = cudaMalloc(&d_ptr_, size * sizeof(T));
        if (err != cudaSuccess) {
            throw std::runtime_error("CUDA malloc failed: " + 
                std::string(cudaGetErrorString(err)));
        }
    }
    
    ~DeviceBuffer() {
        if (d_ptr_) {
            cudaFree(d_ptr_);
        }
    }
    
    // Delete copy constructor and assignment
    DeviceBuffer(const DeviceBuffer&) = delete;
    DeviceBuffer& operator=(const DeviceBuffer&) = delete;
    
    // Move constructor and assignment
    DeviceBuffer(DeviceBuffer&& other) noexcept 
        : d_ptr_(other.d_ptr_), size_(other.size_) {
        other.d_ptr_ = nullptr;
    }
    
    DeviceBuffer& operator=(DeviceBuffer&& other) noexcept {
        if (this != &other) {
            if (d_ptr_) cudaFree(d_ptr_);
            d_ptr_ = other.d_ptr_;
            size_ = other.size_;
            other.d_ptr_ = nullptr;
        }
        return *this;
    }
    
    T* get() { return d_ptr_; }
    const T* get() const { return d_ptr_; }
    size_t size() const { return size_; }
    
    void copyToDevice(const T* host_data) {
        cudaError_t err = cudaMemcpy(d_ptr_, host_data, 
            size_ * sizeof(T), cudaMemcpyHostToDevice);
        if (err != cudaSuccess) {
            throw std::runtime_error("Copy to device failed");
        }
    }
    
    void copyToHost(T* host_data) const {
        cudaError_t err = cudaMemcpy(host_data, d_ptr_, 
            size_ * sizeof(T), cudaMemcpyDeviceToHost);
        if (err != cudaSuccess) {
            throw std::runtime_error("Copy to host failed");
        }
    }
};

// Gaussian blur class
class GaussianBlur {
private:
    int width_;
    int height_;
    int radius_;
    float sigma_;
    std::vector<float> kernel_;
    
    std::unique_ptr<DeviceBuffer<float>> d_kernel_;
    std::unique_ptr<DeviceBuffer<float>> d_temp_;
    
    void generateKernel() {
        int kernelSize = 2 * radius_ + 1;
        kernel_.resize(kernelSize);
        
        float sum = 0.0f;
        for (int i = -radius_; i <= radius_; i++) {
            float value = std::exp(-(i * i) / (2.0f * sigma_ * sigma_));
            kernel_[i + radius_] = value;
            sum += value;
        }
        
        // Normalize
        for (auto& val : kernel_) {
            val /= sum;
        }
    }
    
public:
    GaussianBlur(int width, int height, int radius, float sigma)
        : width_(width), height_(height), radius_(radius), sigma_(sigma) {
        
        if (radius <= 0 || radius > 50) {
            throw std::invalid_argument("Radius must be between 1 and 50");
        }
        
        if (sigma <= 0.0f) {
            throw std::invalid_argument("Sigma must be positive");
        }
        
        // Generate Gaussian kernel
        generateKernel();
        
        // Allocate device memory
        d_kernel_ = std::make_unique<DeviceBuffer<float>>(kernel_.size());
        d_kernel_->copyToDevice(kernel_.data());
        
        // Allocate temporary buffer for intermediate results
        d_temp_ = std::make_unique<DeviceBuffer<float>>(width * height);
    }
    
    // Apply Gaussian blur
    void apply(const float* h_input, float* h_output) {
        // Allocate device buffers
        DeviceBuffer<float> d_input(width_ * height_);
        DeviceBuffer<float> d_output(width_ * height_);
        
        // Copy input to device
        d_input.copyToDevice(h_input);
        
        // Configure kernel launch parameters
        const int blockSize = 16;
        dim3 blockDim(blockSize, blockSize);
        dim3 gridDim(
            (width_ + blockSize - 1) / blockSize,
            (height_ + blockSize - 1) / blockSize
        );
        
        int sharedMemSize = (blockSize + 2 * radius_) * sizeof(float);
        
        // Launch horizontal blur
        launchGaussianBlurHorizontal(
            d_input.get(),
            d_temp_->get(),
            d_kernel_->get(),
            width_,
            height_,
            radius_,
            gridDim,
            blockDim,
            sharedMemSize
        );
        
        // Check for kernel launch errors
        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess) {
            throw std::runtime_error("Horizontal kernel launch failed: " + 
                std::string(cudaGetErrorString(err)));
        }
        
        // Launch vertical blur
        launchGaussianBlurVertical(
            d_temp_->get(),
            d_output.get(),
            d_kernel_->get(),
            width_,
            height_,
            radius_,
            gridDim,
            blockDim,
            sharedMemSize
        );
        
        err = cudaGetLastError();
        if (err != cudaSuccess) {
            throw std::runtime_error("Vertical kernel launch failed: " + 
                std::string(cudaGetErrorString(err)));
        }
        
        // Synchronize
        cudaDeviceSynchronize();
        
        // Copy result back to host
        d_output.copyToHost(h_output);
    }
    
    // Getters
    int getWidth() const { return width_; }
    int getHeight() const { return height_; }
    int getRadius() const { return radius_; }
    float getSigma() const { return sigma_; }
    const std::vector<float>& getKernel() const { return kernel_; }
    
    // Print kernel coefficients
    void printKernel() const {
        std::cout << "Gaussian kernel (radius=" << radius_ 
                  << ", sigma=" << sigma_ << "):\n";
        for (size_t i = 0; i < kernel_.size(); i++) {
            std::cout << kernel_[i] << " ";
        }
        std::cout << std::endl;
    }
};

} // namespace gpu

#endif // GAUSSIAN_BLUR_HPP
