-- UADW v1.0 - Modul Praktikum 01
CREATE SCHEMA IF NOT EXISTS src;
DROP TABLE IF EXISTS src.program_studi;
CREATE TABLE src.program_studi (kode_prodi TEXT,nama_prodi TEXT,fakultas TEXT,departemen TEXT,status TEXT);
DROP TABLE IF EXISTS src.semester;
CREATE TABLE src.semester (semester_id TEXT,tahun_akademik TEXT,term TEXT,urutan_tahun TEXT,tanggal_mulai TEXT,tanggal_selesai TEXT);
DROP TABLE IF EXISTS src.mahasiswa;
CREATE TABLE src.mahasiswa (nim TEXT,nama TEXT,jk_raw TEXT,tanggal_lahir_raw TEXT,kota_asal_raw TEXT,kode_prodi_raw TEXT,prodi_raw TEXT,angkatan TEXT,tanggal_masuk_raw TEXT,status_raw TEXT,email_kampus TEXT);
DROP TABLE IF EXISTS src.dosen;
CREATE TABLE src.dosen (nidn TEXT,nama_dosen TEXT,jk_raw TEXT,unit_prodi_raw TEXT,jabatan_akademik TEXT,tanggal_masuk_raw TEXT,status TEXT);
DROP TABLE IF EXISTS src.mata_kuliah;
CREATE TABLE src.mata_kuliah (kode_mk TEXT,nama_mk TEXT,kode_prodi TEXT,sks TEXT,semester_rekomendasi TEXT,kategori TEXT,aktif TEXT);

--menjalankan excercise c - Membuat Data Inventory
-- 1. Hitung jumlah baris di setiap tabel
SELECT 'program_studi' AS tabel, COUNT(*) AS jumlah_baris FROM src.program_studi
UNION ALL
SELECT 'semester', COUNT(*) FROM src.semester
UNION ALL
SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL
SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL
SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah;

-- 2. Cek indikasi duplicate pada NIM mahasiswa
SELECT COUNT(*) AS raw_rows,
       COUNT(DISTINCT nim) AS distinct_nim,
       COUNT(*) - COUNT(DISTINCT nim) AS excess_duplicate_rows
FROM src.mahasiswa;

-- 3. Cek mahasiswa yang missing kota_asal_raw
SELECT COUNT(*) AS missing_kota
FROM src.mahasiswa
WHERE TRIM(COALESCE(kota_asal_raw,'')) = '';

-- 4. Variasi label program studi
SELECT prodi_raw, COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY prodi_raw
ORDER BY prodi_raw;

--poin 11. Problem Challenge
-- 1. jumlah baris pada masing-masing dari lima tabel sumber
SELECT 'program_studi' AS tabel, COUNT(*) AS jumlah_baris FROM src.program_studi
UNION ALL
SELECT 'semester', COUNT(*) FROM src.semester
UNION ALL
SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL
SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL
SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah;

-- 2 & 3. Jumlah NIM unik dan excess duplicate rows pada mahasiswa
SELECT 
    COUNT(*) AS total_baris,
    COUNT(DISTINCT nim) AS nim_unik,
    COUNT(*) - COUNT(DISTINCT nim) AS excess_duplicate_rows
FROM src.mahasiswa;

-- 4. Rentang angkatan pada base load
SELECT 
    MIN(angkatan) AS angkatan_terawal, 
    MAX(angkatan) AS angkatan_terakhir 
FROM src.mahasiswa;

-- 5. Jumlah mahasiswa yang kota_asal_raw-nya kosong
SELECT COUNT(*) AS kota_kosong
FROM src.mahasiswa
WHERE TRIM(COALESCE(kota_asal_raw, '')) = '';

-- 6. Jumlah label prodi_raw berbeda vs canonical
SELECT 
    (SELECT COUNT(DISTINCT prodi_raw) FROM src.mahasiswa) AS label_prodi_raw_unik,
    (SELECT COUNT(*) FROM src.program_studi) AS prodi_canonical;

-- 7.tiga pola lain yang menunjukkan bahwa source data belum siap langsung dimasukkan ke Dimension Table.
-- 1. Bukti Inkonsistensi Format Tanggal (Campuran YYYY-MM-DD dan DD/MM/YYYY)
SELECT 
    CASE 
        WHEN tanggal_lahir_raw LIKE '%/%' THEN 'Format DD/MM/YYYY (Garis Miring)'
        WHEN tanggal_lahir_raw LIKE '%-%' THEN 'Format YYYY-MM-DD (Tanda Hubung)'
        ELSE 'Lainnya / Kosong'
    END AS jenis_format_tanggal,
    COUNT(*) AS jumlah_baris
FROM src.mahasiswa
GROUP BY 1;

-- 2. Bukti Masalah Kapitalisasi & Spasi Berlebih pada kota_asal_raw
SELECT 
    kota_asal_raw AS nilai_asli,
    LENGTH(kota_asal_raw) AS panjang_karakter,
    COUNT(*) AS jumlah
FROM src.mahasiswa
WHERE kota_asal_raw IS NOT NULL AND kota_asal_raw != ''
GROUP BY kota_asal_raw
ORDER BY LOWER(TRIM(kota_asal_raw)), kota_asal_raw;

-- 3. Bukti Keberadaan Nilai Kosong / NULL (Missing Values)
SELECT 
    COUNT(*) FILTER (WHERE TRIM(COALESCE(kota_asal_raw, '')) = '') AS kota_kosong,
    COUNT(*) FILTER (WHERE TRIM(COALESCE(jk_raw, '')) = '') AS jk_kosong
FROM src.mahasiswa;

