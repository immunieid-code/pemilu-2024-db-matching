# Voter Database Matching — Pemilu 2024

PostgreSQL-based record linkage for the 2024 Indonesian general election. The task: match thousands of voter records across two datasets where names, addresses, and poll station codes were inconsistently formatted, incomplete, or had changed between election cycles.

**Tools:** PostgreSQL, Python (psycopg2, Pandas)

---

## Project Overview

A 2024 campaign in Kebayoran Lama needed an official voter roll linked to field-contact records across six kelurahan for polling-station follow-up. The SQL method uses exact joins and a trigram review pass; 993 matched records were exported for coordinators. Voter names and contacts are not published in this repository.

## The problem

The campaign team's previous process: open both spreadsheets, search by name manually, compare RT/RW and TPS numbers by eye, copy the matched row. For a district with thousands of voters split across six kelurahan and dozens of polling stations, this took days and was error-prone — a name like "Budi S" could match several people, or zero if the spelling differed by one character between datasets.

## What I built

A set of SQL queries that handle the full matching in minutes, including cases where names don't match exactly. The queries below are reconstructed for this write-up (the live campaign database wasn't mine to export) but reflect the actual approach and match logic used — see `sql/` for the runnable versions.

### Phase 1 — Exact match

```sql
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
```

Matched on normalized name + RT + RW + TPS. Handled the majority of records.

### Phase 2 — Fuzzy fallback

For records that didn't land in the exact match, used trigram similarity (`pg_trgm`) to surface near-matches for human review:

```sql
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
```

The threshold (0.55) was tuned to surface real near-matches without flooding the review queue with false positives.

### Phase 3 — Export matched results

```sql
COPY (
    SELECT nama, jenis_kelamin, usia, kelurahan, kecamatan, rt, rw, tps, kontak
    FROM hasil_pencocokan
    ORDER BY kelurahan, tps, nama
) TO '/tmp/database_final.csv' WITH CSV HEADER;
```

## Coverage

The final dataset covers Kecamatan Kebayoran Lama across six kelurahan:
- Grogol Utara
- Grogol Selatan
- Kebayoran Lama Utara
- Kebayoran Lama Selatan
- Pondok Pinang
- Cipulir

Fields: `no`, `nama`, `jenis_kelamin`, `usia`, `kelurahan`, `kecamatan`, `rt`, `rw`, `tps`, `kontak`

## Result

What previously took the team multiple days of manual cross-referencing finished in minutes. The matched output fed directly into the campaign's door-to-door coordination, sorted by polling station for field workers.

## Notes

- Voter names and contact details are not included in this repo (privacy).
- The `pg_trgm` extension must be enabled: `CREATE EXTENSION IF NOT EXISTS pg_trgm;`
- Tested on PostgreSQL 15.
