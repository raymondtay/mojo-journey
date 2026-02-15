/*
 * Main Application - C++ with CUDA Gaussian Blur
 * 
 * Demonstrates usage of the GaussianBlur class
 */

#include "gaussian_blur.hpp"
#include <iostream>
#include <vector>
#include <chrono>
#include <random>
#include <iomanip>

// Simple image loader/saver simulation
class Image {
private:
    int width_;
    int height_;
    std::vector<float> data_;
    
public:
    Image(int width, int height) 
        : width_(width), height_(height), data_(width * height) {}
    
    void fillRandom() {
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_real_distribution<float> dis(0.0f, 1.0f);
        
        for (auto& pixel : data_) {
            pixel = dis(gen);
        }
    }
    
    void fillTestPattern() {
        for (int y = 0; y < height_; y++) {
            for (int x = 0; x < width_; x++) {
                // Create a checkerboard pattern
                float value = ((x / 32) % 2) ^ ((y / 32) % 2) ? 1.0f : 0.0f;
                data_[y * width_ + x] = value;
            }
        }
    }
    
    float* data() { return data_.data(); }
    const float* data() const { return data_.data(); }
    int width() const { return width_; }
    int height() const { return height_; }
    size_t size() const { return data_.size(); }
    
    float getPixel(int x, int y) const {
        if (x < 0 || x >= width_ || y < 0 || y >= height_) {
            return 0.0f;
        }
        return data_[y * width_ + x];
    }
    
    void printRegion(int startX, int startY, int sizeX, int sizeY) const {
        std::cout << std::fixed << std::setprecision(3);
        for (int y = startY; y < startY + sizeY && y < height_; y++) {
            for (int x = startX; x < startX + sizeX && x < width_; x++) {
                std::cout << getPixel(x, y) << " ";
            }
            std::cout << std::endl;
        }
    }
};

// Benchmark helper
class Timer {
private:
    std::chrono::high_resolution_clock::time_point start_;
    
public:
    void start() {
        start_ = std::chrono::high_resolution_clock::now();
    }
    
    double elapsed() const {
        auto end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double, std::milli> duration = end - start_;
        return duration.count();
    }
};

// Run benchmark
void runBenchmark(gpu::GaussianBlur& blur, const Image& input, 
                  Image& output, int iterations = 10) {
    Timer timer;
    std::vector<double> times;
    
    // Warm-up run
    blur.apply(input.data(), output.data());
    
    // Benchmark runs
    for (int i = 0; i < iterations; i++) {
        timer.start();
        blur.apply(input.data(), output.data());
        times.push_back(timer.elapsed());
    }
    
    // Calculate statistics
    double sum = 0.0;
    double minTime = times[0];
    double maxTime = times[0];
    
    for (double t : times) {
        sum += t;
        minTime = std::min(minTime, t);
        maxTime = std::max(maxTime, t);
    }
    
    double avgTime = sum / iterations;
    int pixels = input.width() * input.height();
    double throughput = (pixels / 1e6) / (avgTime / 1000.0);
    
    std::cout << "\n=== Benchmark Results ===" << std::endl;
    std::cout << "Iterations: " << iterations << std::endl;
    std::cout << "Average time: " << avgTime << " ms" << std::endl;
    std::cout << "Min time: " << minTime << " ms" << std::endl;
    std::cout << "Max time: " << maxTime << " ms" << std::endl;
    std::cout << "Throughput: " << throughput << " Mpixels/sec" << std::endl;
}

int main(int argc, char** argv) {
    std::cout << "=== Separable Gaussian Blur (C++ with CUDA) ===" << std::endl;
    std::cout << std::endl;
    
    // Configuration
    const int width = 1920;
    const int height = 1080;
    const int radius = 5;
    const float sigma = 2.0f;
    
    std::cout << "Image dimensions: " << width << " x " << height << std::endl;
    std::cout << "Kernel radius: " << radius << std::endl;
    std::cout << "Sigma: " << sigma << std::endl;
    std::cout << std::endl;
    
    try {
        // Create input and output images
        Image input(width, height);
        Image output(width, height);
        
        // Fill with test data
        std::cout << "Generating test image..." << std::endl;
        input.fillRandom();
        
        // Create Gaussian blur processor
        std::cout << "Initializing GPU processor..." << std::endl;
        gpu::GaussianBlur blur(width, height, radius, sigma);
        
        // Print kernel
        blur.printKernel();
        std::cout << std::endl;
        
        // Apply blur
        std::cout << "Applying Gaussian blur..." << std::endl;
        Timer timer;
        timer.start();
        blur.apply(input.data(), output.data());
        double elapsed = timer.elapsed();
        
        std::cout << "First run completed in " << elapsed << " ms" << std::endl;
        
        // Show sample results
        std::cout << "\nSample input region (center 5x5):" << std::endl;
        input.printRegion(width/2 - 2, height/2 - 2, 5, 5);
        
        std::cout << "\nSample output region (center 5x5):" << std::endl;
        output.printRegion(width/2 - 2, height/2 - 2, 5, 5);
        
        // Run benchmark
        std::cout << "\nRunning performance benchmark..." << std::endl;
        runBenchmark(blur, input, output, 100);
        
        // Test with different kernel sizes
        std::cout << "\n=== Testing Different Kernel Sizes ===" << std::endl;
        std::vector<int> radii = {3, 5, 7, 10};
        
        for (int r : radii) {
            gpu::GaussianBlur blurTest(width, height, r, 2.0f);
            Timer t;
            t.start();
            blurTest.apply(input.data(), output.data());
            double time = t.elapsed();
            
            int kernelSize = 2 * r + 1;
            double throughput = (width * height / 1e6) / (time / 1000.0);
            
            std::cout << "Radius " << r << " (kernel " << kernelSize 
                      << "x" << kernelSize << "): " 
                      << time << " ms, "
                      << throughput << " Mpixels/sec" << std::endl;
        }
        
        std::cout << "\n=== Success! ===" << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
