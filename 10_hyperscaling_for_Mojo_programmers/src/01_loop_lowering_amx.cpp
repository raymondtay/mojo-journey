#include <immintrin.h>
#include <stdint.h>

extern "C" void amx_smoke(const uint8_t *A, const int8_t *B, int32_t *C,
                          int lda, int ldb, int ldc) {

  // 64-bbyte aligned tile config (Intel AMX requirement)
  alignas(64) struct {
    uint8_t palette_id;
    uint8_t start_row;
    uint8_t reserved[14];
    uint8_t colsb[8];
    uint8_t rows[8];
  } cfg = {};

  cfg.palette_id = 1;
  cfg.colsb[0] = 64;
  cfg.rows[0] = 16; // tmm0
  cfg.colsb[1] = 64;
  cfg.rows[1] = 16; // tmm1
  cfg.colsb[2] = 64;
  cfg.rows[2] = 16; // tmm2

  _tile_loadconfig(&cfg);

  // Load tiles (interpret strides in bytes)
  _tile_loadd(0, A, lda);
  _tile_loadd(1, B, ldb);

  // dot-product accumulate (int8 -> int32)
  // tdpbssd: signed*signed dword accumulate
  _tile_dpbssd(2, 0, 1);

  _tile_stored(2, C, ldc);

  _tile_release();
}
