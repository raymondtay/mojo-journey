#include <cstdint>
#include <cstdio>
#include <cuda_runtime.h>

#ifndef CHECK_CUDA
#define CHECK_CUDA(x)                                                          \
  do {                                                                         \
    cudaError_t err = (x);                                                     \
    if (err != cudaSuccess) {                                                  \
      fprintf(stderr, "CUDA error %s:%d: %s\n", __FILE__, __LINE__,            \
              cudaGetErrorString(err));                                        \
      std::exit(1);                                                            \
    }                                                                          \
  } while (0)
#endif

struct ParticleAoS {
  float x, y, z;
  float vx, vy, vz;
  float mass;
  // pad to 32 bytes to emulate common AoS layouts (optional)
  float pad;
};

__global__ void read_x_aos(const ParticleAoS *__restrict__ p,
                           float *__restrict__ out, int n) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n)
    out[i] = p[i].x;
}

__global__ void read_x_soa(const float *__restrict__ x, float *__restrict__ out,
                           int n) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n)
    out[i] = x[i];
}

// do many passes to amplify memory traffic
template <typename K> float run_kernel(K kernel, int iters) {
  cudaEvent_t start, stop;
  CHECK_CUDA(cudaEventCreate(&start));
  CHECK_CUDA(cudaEventCreate(&stop));

  CHECK_CUDA(cudaEventRecord(start));
  for (int i = 0; i < iters; i++)
    kernel();
  CHECK_CUDA(cudaEventRecord(stop));
  CHECK_CUDA(cudaEventSynchronize(stop));

  float ms = 0.f;
  CHECK_CUDA(cudaEventElapsedTime(&ms, start, stop));

  CHECK_CUDA(cudaEventDestroy(start));
  CHECK_CUDA(cudaEventDestroy(stop));
  return ms;
}

int main(int argc, char **argv) {
  int n = (argc > 1) ? std::atoi(argv[1]) : (1 << 26); // ~67 million
  int iters = (argc > 2) ? std::atoi(argv[2]) : 50;

  size_t bytes_out = size_t(n) * sizeof(float);
  size_t bytes_aos = size_t(n) * sizeof(ParticleAoS);
  size_t bytes_soa = size_t(n) * sizeof(float);

  printf("n=%d iters=%d\n", n, iters);
  printf("AoS struct size = %zu bytes\n", sizeof(ParticleAoS));

  // host init
  ParticleAoS *h_aos = (ParticleAoS *)malloc(bytes_aos);
  float *h_x = (float *)malloc(bytes_soa);
  for (int i = 0; i < n; i++) {
    h_aos[i].x = float(i) * 0.001f;
    h_aos[i].y = 1.f;
    h_aos[i].z = 2.f;
    h_aos[i].vx = 3.f;
    h_aos[i].vy = 4.f;
    h_aos[i].vz = 5.f;
    h_aos[i].mass = 6.f;
    h_aos[i].pad = 7.f;
    h_x[i] = h_aos[i].x;
  }

  // device alloc
  ParticleAoS *d_aos = nullptr;
  float *d_x = nullptr, *d_out = nullptr;
  CHECK_CUDA(cudaMalloc(&d_aos, bytes_aos));
  CHECK_CUDA(cudaMalloc(&d_x, bytes_soa));
  CHECK_CUDA(cudaMalloc(&d_out, bytes_out));

  CHECK_CUDA(cudaMemcpy(d_aos, h_aos, bytes_aos, cudaMemcpyHostToDevice));
  CHECK_CUDA(cudaMemcpy(d_x, h_x, bytes_soa, cudaMemcpyHostToDevice));

  int block = 256;
  int grid = (n + block - 1) / block;

  // warmup
  read_x_aos<<<grid, block>>>(d_aos, d_out, n);
  read_x_soa<<<grid, block>>>(d_x, d_out, n);
  CHECK_CUDA(cudaDeviceSynchronize());

  // time AoS
  auto aos_launcher = [&]() { read_x_aos<<<grid, block>>>(d_aos, d_out, n); };
  float ms_aos = run_kernel(aos_launcher, iters);

  // time SoA
  auto soa_launcher = [&]() { read_x_soa<<<grid, block>>>(d_x, d_out, n); };
  float ms_soa = run_kernel(soa_launcher, iters);

  // bytes read per iter:
  // AoS reads 4B useful but causes the hardware to fetch from a strided
  // pattern. For *effective bandwidth* we count only requested bytes (n * 4).
  double req_bytes = double(n) * sizeof(float) * iters;

  double gb = req_bytes / 1e9;
  double sec_aos = ms_aos / 1e3;
  double sec_soa = ms_soa / 1e3;

  printf("\nRequested read traffic: %.3f GB\n", gb);
  printf("AoS: %.3f ms total => %.2f GB/s (requested)\n", ms_aos, gb / sec_aos);
  printf("SoA: %.3f ms total => %.2f GB/s (requested)\n", ms_soa, gb / sec_soa);

  CHECK_CUDA(cudaFree(d_aos));
  CHECK_CUDA(cudaFree(d_x));
  CHECK_CUDA(cudaFree(d_out));
  free(h_aos);
  free(h_x);
  return 0;
}
