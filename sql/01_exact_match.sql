-- Phase 1: strict exact match on name + RT + RW + age within one area.
-- Run per kelurahan, then assemble the reviewed result sets.

SELECT DISTINCT
    tim.no, dpt.nama, dpt.jenis_kelamin, dpt.usia,
    dpt.kelurahan, tim.kecamatan, tim.rt, tim.rw,
    dpt.tps, tim.kontak
FROM data_tim tim
JOIN daftar_pemilih dpt
    ON tim.nama = dpt.nama
    AND tim.rt = dpt.rt
    AND tim.rw = dpt.rw
    AND tim.usia = dpt.usia
WHERE tim.kecamatan = 'KEBAYORAN LAMA'
  AND dpt.kelurahan = 'CIPULIR';
