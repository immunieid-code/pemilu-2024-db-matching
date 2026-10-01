-- Phase 3: retry reviewed residuals without age, still scoped by area.

SELECT DISTINCT
    tim.no,
    dpt.nama,
    dpt.jenis_kelamin,
    dpt.usia,
    dpt.kelurahan,
    tim.kecamatan,
    tim.rt,
    tim.rw,
    dpt.tps,
    tim.kontak
FROM residual_field_rows tim
JOIN staged_voter_rows dpt
    ON tim.nama = dpt.nama
    AND tim.rt = dpt.rt
    AND tim.rw = dpt.rw
WHERE tim.kecamatan = 'KEBAYORAN LAMA'
  AND dpt.kelurahan = 'CIPULIR';
