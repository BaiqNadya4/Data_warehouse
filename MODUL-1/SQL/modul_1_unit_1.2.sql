-- MODUL 1 - UNIT 1.2
-- SQL: DATA PROFILING DAN DATA QUALITY ASSESSMENT

SET search_path TO src, public;

-- A. PROFILING STRUKTUR DAN UKURAN DATASET
-- SOAL 1. Jumlah record setiap tabel
SELECT 'program_studi' AS nama_dataset, COUNT(*) AS jumlah_record FROM src.program_studi
UNION ALL SELECT 'semester', COUNT(*) FROM src.semester
UNION ALL SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah
UNION ALL SELECT 'krs', COUNT(*) FROM src.krs
UNION ALL SELECT 'nilai', COUNT(*) FROM src.nilai
UNION ALL SELECT 'aktivitas_lms', COUNT(*) FROM src.aktivitas_lms
UNION ALL SELECT 'pembayaran', COUNT(*) FROM src.pembayaran
UNION ALL SELECT 'kelulusan', COUNT(*) FROM src.kelulusan
ORDER BY nama_dataset;

-- SOAL 2. Jumlah kolom setiap tabel
SELECT table_name AS nama_tabel, COUNT(*) AS jumlah_kolom
FROM information_schema.columns
WHERE table_schema = 'src'
  AND table_name IN ('program_studi', 'semester', 'mahasiswa', 'dosen',
                     'mata_kuliah', 'krs', 'nilai', 'aktivitas_lms',
                     'pembayaran', 'kelulusan')
GROUP BY table_name
ORDER BY table_name;

-- =========================================================
-- B. MAHASISWA - UNIQUENESS
-- =========================================================

-- SOAL 3. Mengukur keunikan NIM
SELECT COUNT(*) AS jumlah_seluruh_record,
       COUNT(DISTINCT nim) AS jumlah_nim_unik,
       COUNT(*) - COUNT(DISTINCT nim) AS indikasi_kelebihan_record
FROM src.mahasiswa;

-- SOAL 4. Mengidentifikasi NIM duplikat
SELECT nim, COUNT(*) AS jumlah_kemunculan
FROM src.mahasiswa
WHERE nim IS NOT NULL
GROUP BY nim
HAVING COUNT(*) > 1
ORDER BY jumlah_kemunculan DESC, nim;

-- =========================================================
-- C. MAHASISWA - COMPLETENESS
-- =========================================================

-- SOAL 5. Kelengkapan kota asal mahasiswa
SELECT COUNT(*) AS jumlah_kota_asal_kosong
FROM src.mahasiswa
WHERE kota_asal_raw IS NULL
   OR BTRIM(kota_asal_raw) = '';

-- =========================================================
-- D. MAHASISWA - DISTRIBUTION DAN STANDARDISASI
-- =========================================================

-- SOAL 6. Distribusi mahasiswa berdasarkan program studi
SELECT prodi_raw, COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY prodi_raw
ORDER BY jumlah_mahasiswa DESC, prodi_raw;

-- SOAL 7. Jumlah variasi penulisan program studi
SELECT COUNT(DISTINCT prodi_raw) AS jumlah_nama_prodi_berbeda
FROM src.mahasiswa;

-- SOAL 8. Distribusi jenis kelamin mahasiswa
SELECT jk_raw, COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY jk_raw
ORDER BY jumlah_mahasiswa DESC, jk_raw;

-- SOAL 9. Distribusi status mahasiswa
SELECT status_raw, COUNT(*) AS jumlah_record
FROM src.mahasiswa
GROUP BY status_raw
ORDER BY jumlah_record DESC, status_raw;

-- SOAL 10. Distribusi kode program studi
SELECT kode_prodi_raw, COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY kode_prodi_raw
ORDER BY jumlah_mahasiswa DESC, kode_prodi_raw;

-- SOAL 11. Nama program studi yang tidak sesuai standar
SELECT COUNT(*) AS jumlah_prodi_tidak_ditemukan
FROM src.mahasiswa m
WHERE NOT EXISTS (
    SELECT 1
    FROM src.program_studi p
    WHERE p.nama_prodi = m.prodi_raw
);

-- =========================================================
-- E. MAHASISWA - KONSISTENSI FORMAT TANGGAL
-- =========================================================

-- SOAL 12. Distribusi format tanggal masuk
SELECT CASE
         WHEN tanggal_masuk_raw ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
           THEN 'YYYY-MM-DD'
         WHEN tanggal_masuk_raw ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
           THEN 'DD/MM/YYYY'
         WHEN tanggal_masuk_raw ~ '^[0-9]{2}-[A-Za-z]{3}-[0-9]{4}$'
           THEN 'DD-Mon-YYYY'
         ELSE 'OTHER'
       END AS format_tanggal,
       COUNT(*) AS jumlah_record
FROM src.mahasiswa
GROUP BY 1
ORDER BY jumlah_record DESC, format_tanggal;

-- =========================================================
-- F. KRS - DUPLIKASI DATA
-- =========================================================

-- SOAL 13. Jumlah record KRS dan KRS unik
SELECT COUNT(*) AS jumlah_seluruh_record,
       COUNT(DISTINCT krs_id) AS jumlah_krs_id_unik
FROM src.krs;

-- SOAL 14. Duplikasi pengambilan mata kuliah
SELECT nim, kode_mk, semester_id,
       COUNT(*) AS jumlah_kemunculan
FROM src.krs
GROUP BY nim, kode_mk, semester_id
HAVING COUNT(*) > 1
ORDER BY jumlah_kemunculan DESC, nim, kode_mk, semester_id;

-- SOAL 15. Jumlah record KRS yang berlebih akibat duplikasi
SELECT COALESCE(SUM(jumlah_kemunculan - 1), 0) AS total_record_krs_berlebih
FROM (
    SELECT COUNT(*) AS jumlah_kemunculan
    FROM src.krs
    GROUP BY nim, kode_mk, semester_id
    HAVING COUNT(*) > 1
) AS duplikasi;

-- =========================================================
-- G. NILAI - COMPLETENESS DAN VALIDITY
-- =========================================================

-- SOAL 16. Nilai angka yang kosong
SELECT COUNT(*) AS jumlah_nilai_angka_kosong
FROM src.nilai
WHERE nilai_angka IS NULL
   OR BTRIM(nilai_angka::text) = '';

-- SOAL 17. Nilai angka di luar rentang 0-100
SELECT COUNT(*) AS jumlah_nilai_di_luar_rentang
FROM src.nilai
WHERE NULLIF(BTRIM(nilai_angka::text), '') ~ '^[+-]?[0-9]+([.][0-9]+)?$'
  AND BTRIM(nilai_angka::text)::numeric NOT BETWEEN 0 AND 100;

-- SOAL 18. Statistik deskriptif nilai mahasiswa yang valid
WITH nilai_valid AS (
    SELECT BTRIM(nilai_angka::text)::numeric AS angka
    FROM src.nilai
    WHERE NULLIF(BTRIM(nilai_angka::text), '') ~ '^[+-]?[0-9]+([.][0-9]+)?$'
      AND BTRIM(nilai_angka::text)::numeric BETWEEN 0 AND 100
)
SELECT COUNT(*) AS jumlah_nilai_valid,
       MIN(angka) AS nilai_terendah,
       MAX(angka) AS nilai_tertinggi,
       AVG(angka) AS nilai_rata_rata
FROM nilai_valid;

-- =========================================================
-- H. NILAI - KONSISTENSI NILAI ANGKA, HURUF, DAN KELULUSAN
-- =========================================================

-- SOAL 19. Konsistensi nilai angka dengan nilai huruf
WITH nilai_valid AS (
    SELECT BTRIM(nilai_angka::text)::numeric AS angka,
           UPPER(BTRIM(nilai_huruf::text)) AS huruf
    FROM src.nilai
    WHERE NULLIF(BTRIM(nilai_angka::text), '') ~ '^[+-]?[0-9]+([.][0-9]+)?$'
      AND BTRIM(nilai_angka::text)::numeric BETWEEN 0 AND 100
),
hasil_konversi AS (
    SELECT angka, huruf,
           CASE
             WHEN angka >= 85 THEN 'A'
             WHEN angka >= 80 THEN 'AB'
             WHEN angka >= 75 THEN 'B'
             WHEN angka >= 70 THEN 'BC'
             WHEN angka >= 60 THEN 'C'
             WHEN angka >= 50 THEN 'D'
             ELSE 'E'
           END AS huruf_seharusnya
    FROM nilai_valid
)
SELECT COUNT(*) AS jumlah_ketidaksesuaian_nilai_huruf
FROM hasil_konversi
WHERE huruf IS DISTINCT FROM huruf_seharusnya;

-- SOAL 20. Konsistensi nilai angka dengan status kelulusan
WITH nilai_valid AS (
    SELECT BTRIM(nilai_angka::text)::numeric AS angka,
           LOWER(BTRIM(status_lulus::text)) AS status
    FROM src.nilai
    WHERE NULLIF(BTRIM(nilai_angka::text), '') ~ '^[+-]?[0-9]+([.][0-9]+)?$'
      AND BTRIM(nilai_angka::text)::numeric BETWEEN 0 AND 100
)
SELECT COUNT(*) AS jumlah_ketidaksesuaian_status_lulus
FROM nilai_valid
WHERE status IS DISTINCT FROM
      CASE WHEN angka >= 60 THEN 'lulus' ELSE 'tidak lulus' END;

-- =========================================================
-- I. NILAI - DUPLIKASI DATA
-- =========================================================

-- SOAL 21. Duplikasi record nilai
SELECT nim, kode_mk, semester_id,
       COUNT(*) AS jumlah_kemunculan
FROM src.nilai
GROUP BY nim, kode_mk, semester_id
HAVING COUNT(*) > 1
ORDER BY jumlah_kemunculan DESC, nim, kode_mk, semester_id;

-- =========================================================
-- J. REFERENTIAL INTEGRITY - KRS, NILAI, MAHASISWA, MK, SEMESTER
-- =========================================================

-- SOAL 22. NIM KRS yang tidak terdaftar sebagai mahasiswa
SELECT COUNT(*) AS jumlah_nim_krs_tidak_terdaftar
FROM src.krs k
WHERE NOT EXISTS (
    SELECT 1 FROM src.mahasiswa m WHERE m.nim = k.nim
);

-- SOAL 23. NIM nilai yang tidak terdaftar sebagai mahasiswa
SELECT COUNT(*) AS jumlah_nim_nilai_tidak_terdaftar
FROM src.nilai n
WHERE NOT EXISTS (
    SELECT 1 FROM src.mahasiswa m WHERE m.nim = n.nim
);

-- SOAL 24. Kode mata kuliah nilai yang tidak memiliki referensi
SELECT COUNT(*) AS jumlah_kode_mk_tidak_ditemukan
FROM src.nilai n
WHERE NOT EXISTS (
    SELECT 1 FROM src.mata_kuliah mk WHERE mk.kode_mk = n.kode_mk
);

-- SOAL 25. Semester nilai yang tidak memiliki referensi
SELECT COUNT(*) AS jumlah_semester_nilai_tidak_ditemukan
FROM src.nilai n
WHERE NOT EXISTS (
    SELECT 1 FROM src.semester s WHERE s.semester_id = n.semester_id
);

-- =========================================================
-- K. AKTIVITAS LMS - UNIQUENESS DAN DISTRIBUTION
-- =========================================================

-- SOAL 26. Mengukur duplikasi aktivitas LMS
SELECT COUNT(*) AS jumlah_seluruh_aktivitas,
       COUNT(DISTINCT lms_event_id) AS jumlah_lms_event_id_unik,
       COUNT(*) - COUNT(DISTINCT lms_event_id) AS indikasi_kelebihan_record
FROM src.aktivitas_lms;

-- SOAL 27. Distribusi tipe aktivitas LMS
SELECT tipe_event, COUNT(*) AS jumlah_aktivitas
FROM src.aktivitas_lms
GROUP BY tipe_event
ORDER BY jumlah_aktivitas DESC, tipe_event;

-- SOAL 28. Kelengkapan skor kuis
SELECT COUNT(*) AS jumlah_quiz_attempt_tanpa_skor
FROM src.aktivitas_lms
WHERE tipe_event = 'quiz_attempt'
  AND (skor_kuis IS NULL OR BTRIM(skor_kuis::text) = '');

-- SOAL 29. Skor pada aktivitas selain kuis
SELECT COUNT(*) AS jumlah_skor_pada_aktivitas_non_quiz
FROM src.aktivitas_lms
WHERE tipe_event <> 'quiz_attempt'
  AND skor_kuis IS NOT NULL
  AND BTRIM(skor_kuis::text) <> '';

-- =========================================================
-- L. PEMBAYARAN - VALIDITY DAN COMPLETENESS
-- =========================================================

-- SOAL 30. Nominal pembayaran negatif
SELECT COUNT(*) AS jumlah_pembayaran_bernominal_negatif
FROM src.pembayaran
WHERE nominal_bayar < 0;

-- SOAL 31. Tanggal pembayaran kosong untuk nominal positif
SELECT COUNT(*) AS jumlah_tanggal_bayar_kosong
FROM src.pembayaran
WHERE nominal_bayar > 0
  AND (tanggal_bayar_raw IS NULL OR BTRIM(tanggal_bayar_raw) = '');

-- SOAL 32. Distribusi status pembayaran
SELECT status_pembayaran, COUNT(*) AS jumlah_transaksi
FROM src.pembayaran
GROUP BY status_pembayaran
ORDER BY jumlah_transaksi DESC, status_pembayaran;

-- =========================================================
-- M. KELULUSAN - UNIQUENESS DAN DISTRIBUTION
-- =========================================================

-- SOAL 33. Duplikasi data kelulusan
SELECT COUNT(*) AS jumlah_seluruh_record,
       COUNT(DISTINCT nim) AS jumlah_nim_unik,
       COUNT(*) - COUNT(DISTINCT nim) AS indikasi_kelebihan_record
FROM src.kelulusan;

-- SOAL 34. Distribusi status kelulusan tepat waktu
SELECT status_tepat_waktu, COUNT(*) AS jumlah_mahasiswa
FROM src.kelulusan
GROUP BY status_tepat_waktu
ORDER BY jumlah_mahasiswa DESC, status_tepat_waktu;

-- =========================================================
-- N. RELASI ANTAR-TABEL - REFERENTIAL INTEGRITY
-- =========================================================

-- SOAL 35. Aktivitas LMS dengan NIM yang tidak terdaftar
SELECT COUNT(*) AS jumlah_aktivitas_lms_nim_tidak_terdaftar
FROM src.aktivitas_lms a
WHERE NOT EXISTS (
    SELECT 1 FROM src.mahasiswa m WHERE m.nim = a.nim
);

-- SOAL 36. Aktivitas LMS dengan mata kuliah yang tidak terdaftar
SELECT COUNT(*) AS jumlah_aktivitas_lms_kode_mk_tidak_terdaftar
FROM src.aktivitas_lms a
WHERE NOT EXISTS (
    SELECT 1 FROM src.mata_kuliah mk WHERE mk.kode_mk = a.kode_mk
);

-- SOAL 37. Pembayaran dengan NIM yang tidak terdaftar
SELECT COUNT(*) AS jumlah_pembayaran_nim_tidak_terdaftar
FROM src.pembayaran p
WHERE NOT EXISTS (
    SELECT 1 FROM src.mahasiswa m WHERE m.nim = p.nim
);

-- SOAL 38. Kelulusan dengan NIM yang tidak terdaftar
SELECT COUNT(*) AS jumlah_kelulusan_nim_tidak_terdaftar
FROM src.kelulusan k
WHERE NOT EXISTS (
    SELECT 1 FROM src.mahasiswa m WHERE m.nim = k.nim
);
