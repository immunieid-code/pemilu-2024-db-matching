-- Phase 1: exact match on normalized name + RT + RW + TPS.
-- Handles the majority of records where both datasets used consistent formatting.

SELECT
    a.nama,
    a.rt, a.rw, a.tps,
    a.kelurahan,
    b.kontak
FROM daftar_pemilih a
JOIN data_tim b
    ON LOWER(TRIM(a.nama)) = LOWER(TRIM(b.nama))
    AND a.rt  = b.rt
    AND a.rw  = b.rw
    AND a.tps = b.tps
WHERE a.kecamatan = 'KEBAYORAN LAMA';
