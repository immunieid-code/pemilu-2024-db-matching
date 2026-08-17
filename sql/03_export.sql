-- Phase 3: export the merged, confirmed matches for field use.

COPY (
    SELECT nama, jenis_kelamin, usia, kelurahan, kecamatan, rt, rw, tps, kontak
    FROM hasil_pencocokan
    ORDER BY kelurahan, tps, nama
) TO '/tmp/database_final.csv' WITH CSV HEADER;
