-- Phase 2: keep unmatched records visible for targeted cleanup and review.

SELECT
    source.no,
    source.nama,
    source.rt,
    source.rw,
    source.kelurahan,
    source.kecamatan,
    source.kontak
FROM hasil_match matched
FULL OUTER JOIN data_tim source
    ON matched.nama = source.nama
WHERE matched.nama IS NULL OR source.nama IS NULL;
