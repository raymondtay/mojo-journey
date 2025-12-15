#include <chrono>
#include <cmath>
#include <iostream>
#include <vector>

struct ParticleAoS {
  float x, y, z;
  float vx, vy, vz;
};

struct ParticleSoA {
  std::vector<float> x, y, z;
  std::vector<float> vx, vy, vz;
  explicit ParticleSoA(std::size_t n) : x(n), y(n), z(n), vx(n), vy(n), vz(n) {}
};

void update_aos(std::vector<ParticleAoS> &xs, float dt) {
  const std::size_t n = xs.size();

  // Question: To generate lots of wastage, simply comment out the statements
  // that touch the fields `y` and `z`
  for (std::size_t i = 0; i < n; i++) {
    xs[i].x += xs[i].vz * dt;
    xs[i].y += xs[i].vy * dt;
    xs[i].z += xs[i].vz * dt;
  }
}

void update_soa(ParticleSoA &p, float dt) {
  const std::size_t n = p.x.size();

  for (std::size_t i = 0; i < n; i++) {
    p.x[i] += p.vx[i] * dt;
    p.y[i] += p.vy[i] * dt;
    p.z[i] += p.vz[i] * dt;
  }
}

template <typename F> double time_it(F &&f, int iters = 5) {
  using clock = std::chrono::high_resolution_clock;
  double best_time = 1e9;
  for (int i = 0; i < iters; ++i) {
    auto start = clock::now();
    f();
    auto end = clock::now();
    double ms = std::chrono::duration<double, std::milli>(end - start).count();
    if (ms < best_time)
      best_time = ms;
  }

  return best_time;
}

int main() {
  const std::size_t N = 10'000'000;
  const float dt = 0.01f;

  std::vector<ParticleAoS> aos(N);
  for (std::size_t i = 0; i < N; ++i) {
    aos[i].x = float(i);
    aos[i].y = 1.0f;
    aos[i].z = 2.0f;
    aos[i].vx = 0.1f;
    aos[i].vy = 0.2f;
    aos[i].vz = 0.3f;
  }

  ParticleSoA soa(N);
  for (std::size_t i = 0; i < N; ++i) {
    soa.x[i] = float(i);
    soa.y[i] = 1.0f;
    soa.z[i] = 2.0f;
    soa.vx[i] = 0.1f;
    soa.vy[i] = 0.2f;
    soa.vz[i] = 0.3f;
  }

  double t_aos = time_it([&] { update_aos(aos, dt); });
  double t_soa = time_it([&] { update_soa(soa, dt); });
}
