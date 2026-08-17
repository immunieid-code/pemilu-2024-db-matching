-- Phase 2: fuzzy fallback for records that missed the exact match —
-- typos, abbreviations, or spelling differences between the two datasets.
-- Requires pg_trgm: CREATE EXTENSION IF NOT EXISTS pg_trgm;

SELECT
    a.nama  AS nama_dpt,
    b.nama  AS nama_tim,
    similarity(a.nama, b.nama) AS skor,
    a.rt, a.rw, a.tps
FROM daftar_pemilih a
JOIN data_tim b
    ON similarity(a.nama, b.nama) > 0.55
    AND a.rt = b.rt
    AND a.tps = b.tps
WHERE a.kecamatan = 'KEBAYORAN LAMA'
ORDER BY skor DESC;

-- The 0.55 threshold was tuned by hand: high enough to skip obvious
-- non-matches, low enough to still catch real near-matches for a human
-- to confirm before they're merged into the final dataset.
