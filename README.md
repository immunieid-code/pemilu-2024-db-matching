# Voter Database Matching — Pemilu 2024

PostgreSQL-based voter-data reconciliation for the 2024 Indonesian general election. The task: connect a campaign field list with fragmented KPU voter data while keeping geographic context and unresolved records visible for review.

**Tools:** PostgreSQL, SQL

---

## Project Overview

A 2024 campaign needed field-contact records reconciled with KPU voter data across Dapil 7: five kecamatan, 34 kelurahan and 3,830 TPS-level source PDFs. The field dataset contained 15,156 raw rows; a 14,021-row version was prepared for SQL processing. Voter names and contacts are not published in this repository.

## The problem

The campaign list contained inconsistent kecamatan and kelurahan values, blank RT/RW fields and out-of-scope records. The voter data arrived as thousands of TPS-level files with varying headers. A manual lookup process could not produce a reliable district-wide operating list or show which records still needed review.

## What I built

A set of privacy-safe SQL examples reconstructed from the project workflow. They show the method used in the local archive: a strict area-scoped pass, area assembly, residual auditing and targeted retries. See `sql/` for the query sequence.

### Phase 1 — Area-scoped exact match

```sql
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
```

Matched on name + RT + RW + age within the corresponding kecamatan and kelurahan. The additional age key and area scope made the first pass deliberately strict.

### Phase 2 — Residual review

Records that did not land in the exact match stayed visible through a `FULL OUTER JOIN` check:

```sql
SELECT
    source.no, source.nama, source.rt, source.rw,
    source.kelurahan, source.kecamatan, source.kontak
FROM hasil_match matched
FULL OUTER JOIN data_tim source
    ON matched.nama = source.nama
WHERE matched.nama IS NULL OR source.nama IS NULL;
```

The residual list supported targeted cleanup and another exact-match pass without silently dropping or forcing uncertain records.

### Phase 3 — Reviewed retry

After reviewing residuals, the follow-up pass retried records on name + RT + RW within the same area. Age was removed only at this reviewed stage:

```sql
SELECT DISTINCT
    tim.no, dpt.nama, dpt.jenis_kelamin, dpt.usia,
    dpt.kelurahan, tim.kecamatan, tim.rt, tim.rw,
    dpt.tps, tim.kontak
FROM residual_field_rows tim
JOIN staged_voter_rows dpt
    ON tim.nama = dpt.nama
    AND tim.rt = dpt.rt
    AND tim.rw = dpt.rw
WHERE tim.kecamatan = 'KEBAYORAN LAMA'
  AND dpt.kelurahan = 'CIPULIR';
```

### Phase 4 — Export matched results

```sql
COPY (
    SELECT nama, jenis_kelamin, usia, kelurahan, kecamatan, rt, rw, tps, kontak
    FROM hasil_pencocokan
    ORDER BY kelurahan, tps, nama
) TO '/tmp/database_final.csv' WITH CSV HEADER;
```

## Coverage

The source archive covers five kecamatan and 34 kelurahan:
- Kebayoran Baru (10 kelurahan)
- Setiabudi (8 kelurahan)
- Kebayoran Lama (6 kelurahan)
- Pesanggrahan (5 kelurahan)
- Cilandak (5 kelurahan)

Fields: `no`, `nama`, `jenis_kelamin`, `usia`, `kelurahan`, `kecamatan`, `rt`, `rw`, `tps`, `kontak`

## Result

The project produced structured match outputs organized by area and TPS, enriched with voter demographics and campaign contact fields. Unresolved records remained traceable for follow-up review.

## Notes

- Voter names and contact details are not included in this repo (privacy).
- Tested on PostgreSQL 15.
