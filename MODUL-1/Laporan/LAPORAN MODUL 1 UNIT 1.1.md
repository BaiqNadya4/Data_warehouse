# LAPORAN MODUL 1 – UNIT 1.1
## Persiapan Source Layer dan Initial Data Profiling

**Studi Kasus:** Database Akademik Perguruan Tinggi  
**DBMS:** PostgreSQL  
**Database:** `postgres`  
**Schema:** `src`

---

## Identitas Laporan

| Identitas | Keterangan |
|---|---|
| Nama | Baiq Nadya Fairuz Qutratu'ain |
| NIM | 24030607 |
| Program Studi | Teknologi Informasi |
| Kelas/Kelompok | A / 4 |
| Modul | 1 |
| Unit | 1.1 |
| Tanggal Praktikum | 5 November 2026 |
| Dosen/Instruktur | Adam Bachtiar Maulachela S.Kom., M.MT.|

## Tujuan Praktikum

Praktikum Unit 1.1 bertujuan menyiapkan source layer pada PostgreSQL, memuat dataset raw UADW v1.0, memverifikasi struktur dan jumlah data sumber, serta melakukan *initial profiling* untuk memperoleh gambaran awal karakteristik dataset akademik.

## Ketentuan Praktikum

1. Gunakan PostgreSQL dan schema `src`.
2. Pertahankan nilai raw sebagaimana tersedia pada file sumber.
3. Jangan melakukan proses cleaning, standardisasi, deduplikasi, `UPDATE`, atau `DELETE` terhadap isi raw source pada unit ini.
4. Sesuaikan path file CSV dengan lokasi dataset pada komputer masing-masing.
5. Untuk setiap aktivitas query, cantumkan query yang dijalankan, hasil eksekusi, dan interpretasi.
6. Apabila hasil aktual berbeda dari nilai acuan pada bahan praktikum, catat perbedaannya dan lakukan pemeriksaan; jangan mengubah data hanya agar hasilnya sama.

---

## 1. Verifikasi Environment PostgreSQL

### 1.1 Memeriksa versi PostgreSQL

Query yang digunakan:

```sql
SELECT version();
```

**Hasil eksekusi:**


![Gambar 1. Hasil SELECT version()](hasil%20unit1.1/soal1.png)

### 1.2 Memeriksa database dan user aktif

```sql
SELECT
    current_database() AS database_aktif,
    current_user      AS user_aktif;
```

**Hasil eksekusi:**

![Gambar 2. Hasil database dan user aktif](hasil%20unit1.1/soal2.png)


### 1.3 Memeriksa keberadaan schema `src`

Query yang digunakan:

```sql
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'src';
```

**Hasil eksekusi:**

![Gambar 3. Hasil pemeriksaan schema src](hasil%20unit1.1/soal3.png)


---

## 2. Membuat dan Memverifikasi Source Layer

Source layer menggunakan schema `src` untuk menyimpan data mentah (*raw source*).

| No. | Nama tabel | Peran data | Status pembuatan |
|---:|---|---|---|
| 1 | `src.program_studi` | Master/reference program studi | Berhasil dibuat |
| 2 | `src.semester` | Reference periode akademik | Berhasil dibuat |
| 3 | `src.mahasiswa` | Master mahasiswa | Berhasil dibuat |
| 4 | `src.dosen` | Master dosen | Berhasil dibuat |
| 5 | `src.mata_kuliah` | Master/reference mata kuliah | Berhasil dibuat |
| 6 | `src.krs` | Transaksi pengambilan mata kuliah | Berhasil dibuat |
| 7 | `src.nilai` | Hasil penilaian akademik | Berhasil dibuat |
| 8 | `src.aktivitas_lms` | Aktivitas mahasiswa pada LMS | Berhasil dibuat |
| 9 | `src.pembayaran` | Transaksi pembayaran | Berhasil dibuat |
| 10 | `src.kelulusan` | Data outcome kelulusan | Berhasil dibuat |

### 2.1 Membuat schema dan tabel

**Script DDL yang digunakan:**

```sql
-- 1. Membuat schema src
CREATE SCHEMA IF NOT EXISTS src;

-- 2. Membuat sepuluh tabel sumber 
-- Membuat tabel program_studi
CREATE TABLE IF NOT EXISTS src.program_studi (
    kode_prodi TEXT,
    nama_prodi TEXT,
    fakultas TEXT,
    departemen TEXT,
    status TEXT
);

-- Membuat tabel semester
CREATE TABLE IF NOT EXISTS src.semester (
    semester_id TEXT,
    tahun_akademik TEXT,
    term TEXT,
    urutan_tahun INTEGER,
    tanggal_mulai TEXT,
    tanggal_selesai TEXT
);

-- Membuat tabel mahasiswa
CREATE TABLE IF NOT EXISTS src.mahasiswa (
    nim TEXT,
    nama TEXT,
    jk_raw TEXT,
    tanggal_lahir_raw TEXT,
    kota_asal_raw TEXT,
    kode_prodi_raw TEXT,
    prodi_raw TEXT,
    angkatan TEXT,
    tanggal_masuk_raw TEXT,
    status_raw TEXT,
    email_kampus TEXT
);

-- Membuat tabel dosen
CREATE TABLE IF NOT EXISTS src.dosen (
    nidn TEXT,
    nama_dosen TEXT,
    jk_raw TEXT,
    unit_prodi_raw TEXT,
    jabatan_akademik TEXT,
    tanggal_masuk_raw TEXT,
    status TEXT
);

-- Membuat tabel mata_kuliah
CREATE TABLE IF NOT EXISTS src.mata_kuliah (
    kode_mk TEXT,
    nama_mk TEXT,
    kode_prodi TEXT,
    sks INTEGER,
    semester_rekomendasi INTEGER,
    kategori TEXT,
    aktif TEXT
);

-- Membuat tabel krs
CREATE TABLE IF NOT EXISTS src.krs (
    krs_id TEXT,
    nim TEXT,
    kode_mk TEXT,
    semester_id TEXT,
    kelas TEXT,
    status_krs TEXT,
    tanggal_ambil_raw TEXT,
    sumber_sistem TEXT
);

-- Membuat tabel nilai
CREATE TABLE IF NOT EXISTS src.nilai (
    nilai_id TEXT,
    nim TEXT,
    kode_mk TEXT,
    semester_id TEXT,
    nilai_angka NUMERIC(6,2),
    nilai_huruf TEXT,
    status_lulus TEXT,
    tanggal_input_raw TEXT
);

-- 9. Membuat tabel aktivitas_lms
CREATE TABLE IF NOT EXISTS src.aktivitas_lms (
    lms_event_id TEXT,
    nim TEXT,
    kode_mk TEXT,
    semester_id TEXT,
    waktu_event TEXT,
    tipe_event TEXT,
    durasi_menit INTEGER,
    skor_kuis NUMERIC(6,2),
    platform TEXT
);

-- Membuat tabel pembayaran
CREATE TABLE IF NOT EXISTS src.pembayaran (
    pembayaran_id TEXT,
    nim TEXT,
    semester_id TEXT,
    tanggal_bayar_raw TEXT,
    nominal_tagihan BIGINT,
    nominal_bayar BIGINT,
    status_pembayaran TEXT,
    kanal TEXT
);

-- Membuat tabel kelulusan
CREATE TABLE IF NOT EXISTS src.kelulusan (
    kelulusan_id TEXT,
    nim TEXT,
    tanggal_lulus_raw TEXT,
    ipk_final NUMERIC(4,2),
    masa_studi_bulan INTEGER,
    predikat TEXT,
    status_tepat_waktu TEXT
);

```

**Bukti eksekusi / hasil:**


![Gambar 4. Eksekusi DDL pembuatan schema dan tabel (log Output DBeaver)](hasil%20unit1.1/soal4.png)

![Gambar 5. Inventarisasi tabel setelah DDL](hasil%20unit1.1/soal5.png)


**Catatan:** Perintah `DROP TABLE` dapat menghapus tabel beserta isinya, sehingga tidak digunakan kecuali diperlukan pada tahap persiapan. DDL di atas memakai `IF NOT EXISTS` agar aman dijalankan ulang.

**Interpretasi:** Schema src berhasil dibuat dan telah memiliki 10 tabel sesuai dengan dataset yang digunakan. Setiap tabel memiliki struktur kolom yang disesuaikan dengan file CSV sumber. Struktur ini digunakan untuk menampung data mentah sebelum dilakukan proses pengolahan lebih lanjut.

---

## 3. Mengimpor/Mengakses Raw Source

### 3.1 Proses impor CSV melalui DBeaver

Sepuluh file CSV diimpor menggunakan fitur Import Data pada DBeaver karena praktikum dijalankan melalui DBeaver di Windows. Perintah \\copy merupakan perintah khusus psql sehingga tidak dijalankan pada SQL Editor DBeaver.

Langkah impor yang dilakukan:

1. Klik kanan tabel tujuan pada schema src, lalu pilih Import Data.
2. Pilih sumber CSV dan tentukan file yang sesuai dari folder 01_raw_data.
3. Pastikan encoding UTF-8, delimiter koma, dan opsi header aktif.
4. Periksa preview serta pemetaan kolom sumber ke kolom tujuan.
5. Klik Proceed dan tunggu sampai proses selesai.

| No. | File CSV | Tabel tujuan |
|---:|---|---|
| 1 | `program_studi.csv` | `src.program_studi` |
| 2 | `semester.csv` | `src.semester` |
| 3 | `mahasiswa.csv` | `src.mahasiswa` |
| 4 | `dosen.csv` | `src.dosen` |
| 5 | `mata_kuliah.csv` | `src.mata_kuliah` |
| 6 | `krs.csv` | `src.krs` |
| 7 | `nilai.csv` | `src.nilai` |
| 8 | `aktivitas_lms.csv` | `src.aktivitas_lms` |
| 9 | `pembayaran.csv` | `src.pembayaran` |
| 10 | `kelulusan.csv` | `src.kelulusan` |

**Bukti proses impor:** hasil verifikasi jumlah record pada masing-masing tabel setelah impor ditunjukkan pada Gambar 8 (lihat juga bagian 3.2 dan 6).


### 3.2 Catatan proses impor

| No. | File CSV | Tabel tujuan | Status impor | Jumlah baris yang dilaporkan saat impor | Catatan/error |
|---:|---|---|---|---:|---|
| 1 | `program_studi.csv` | `src.program_studi` | Berhasil | 6 | - |
| 2 | `semester.csv` | `src.semester` | Berhasil | 8 | - |
| 3 | `mahasiswa.csv` | `src.mahasiswa` | Berhasil | 1.965 | - |
| 4 | `dosen.csv` | `src.dosen` | Berhasil | 96 | - |
| 5 | `mata_kuliah.csv` | `src.mata_kuliah` | Berhasil | 208 | - |
| 6 | `krs.csv` | `src.krs` | Berhasil | 57.025 | - |
| 7 | `nilai.csv` | `src.nilai` | Berhasil | 57.000 | - |
| 8 | `aktivitas_lms.csv` | `src.aktivitas_lms` | Berhasil | 200.356 | - |
| 9 | `pembayaran.csv` | `src.pembayaran` | Berhasil | 9.500 | - |
| 10 | `kelulusan.csv` | `src.kelulusan` | Berhasil | 347 | - |

**Bukti proses impor:** hasil query verifikasi jumlah record seluruh tabel setelah impor.

![Gambar 6. Jumlah baris seluruh sepuluh tabel setelah impor](hasil%20unit1.1/soal5_dataset.png)

**Interpretasi:** Seluruh 10 file CSV berhasil diimpor ke tabel masing-masing melalui DBeaver. Jumlah data yang masuk bervariasi, dengan jumlah paling sedikit 6 baris pada tabel program_studi dan paling banyak 200.356 baris pada tabel aktivitas_lms. Hal ini menunjukkan bahwa proses pemuatan data telah berjalan dengan baik.

---

## 4. Menginventarisasi Tabel pada Schema `src`

**Query SQL:**

```sql
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'src'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Hasil eksekusi:**

![Gambar 7. Daftar base table pada schema src](hasil%20unit1.1/soal6.png)


**Interpretasi:**Hasil pemeriksaan menunjukkan bahwa terdapat 10 tabel pada schema src. Seluruh tabel tersebut merupakan tabel sumber yang telah dibuat sesuai dengan kebutuhan praktikum.

---

## 5. Verifikasi Jumlah Baris Lima Source Awal

**Query SQL:**

```sql
SELECT 'program_studi' AS tabel, COUNT(*) AS jumlah_baris FROM src.program_studi
UNION ALL SELECT 'semester',    COUNT(*) FROM src.semester
UNION ALL SELECT 'mahasiswa',   COUNT(*) FROM src.mahasiswa
UNION ALL SELECT 'dosen',       COUNT(*) FROM src.dosen
UNION ALL SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah
ORDER BY tabel;
```

**Hasil eksekusi:**

![Gambar 8. Jumlah baris lima tabel master/reference](hasil%20unit1.1/soal7.png)



**Interpretasi:** Hasil perhitungan menunjukkan bahwa kelima tabel memiliki jumlah data yang berbeda sesuai dengan jenis informasi yang disimpan. Tabel mahasiswa memiliki jumlah data paling banyak di antara kelima tabel, yaitu 1.965 baris, sedangkan program studi memiliki 6 baris.

---

## 6. Verifikasi Jumlah Baris Seluruh Sepuluh Source

**Query SQL:**

```sql
SELECT 'program_studi' AS tabel, COUNT(*) AS jumlah_baris FROM src.program_studi
UNION ALL
SELECT 'semester', COUNT(*) FROM src.semester
UNION ALL
SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL
SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL
SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah
UNION ALL
SELECT 'krs', COUNT(*) FROM src.krs
UNION ALL
SELECT 'nilai', COUNT(*) FROM src.nilai
UNION ALL
SELECT 'aktivitas_lms', COUNT(*) FROM src.aktivitas_lms
UNION ALL
SELECT 'pembayaran', COUNT(*) FROM src.pembayaran
UNION ALL
SELECT 'kelulusan', COUNT(*) FROM src.kelulusan
ORDER BY tabel;
```

**Hasil eksekusi:**

![Gambar 9. Jumlah baris seluruh sepuluh tabel](hasil%20unit1.1/soal8.png)



**Interpretasi:** Berdasarkan hasil pemeriksaan, seluruh 10 tabel telah memiliki jumlah baris sesuai dengan data yang diimpor. Dengan demikian, tidak ditemukan tabel yang kosong maupun kekurangan jumlah data berdasarkan nilai acuan praktikum.

---

## 7. Verifikasi Jumlah Kolom Seluruh Source

**Query SQL:**

```sql
SELECT
    table_name,
    COUNT(*) AS jumlah_kolom
FROM information_schema.columns
WHERE table_schema = 'src'
GROUP BY table_name
ORDER BY table_name;
```

**Hasil eksekusi:**

![Gambar 10. Jumlah kolom setiap tabel](hasil%20unit1.1/soal9.png)

**Interpretasi:** Setiap tabel memiliki jumlah kolom yang berbeda, yaitu antara 5 sampai 11 kolom. Perbedaan tersebut disesuaikan dengan atribut informasi yang dibutuhkan oleh masing-masing tabel.

---

## 8. Verifikasi Struktur Kolom Tabel Mahasiswa

**Query SQL:**

```sql
SELECT
    ordinal_position AS posisi_kolom,
    column_name      AS nama_kolom,
    data_type        AS tipe_data
FROM information_schema.columns
WHERE table_schema = 'src'
  AND table_name = 'mahasiswa'
ORDER BY ordinal_position;
```

**Hasil eksekusi:**

![Gambar 11. Struktur kolom tabel mahasiswa](hasil%20unit1.1/soal10.png)


**Interpretasi:** Tabel mahasiswa memiliki 11 kolom dengan tipe data yang sebagian besar berupa text dan satu kolom angkatan bertipe integer. Struktur ini menunjukkan bahwa sebagian besar atribut masih dipertahankan dalam bentuk data sumber, sedangkan tahun angkatan sudah dapat digunakan untuk perhitungan numerik.
---

## 9. Verifikasi Candidate Key Mahasiswa

**Query SQL:**

```sql
SELECT
    COUNT(*) AS raw_rows,
    COUNT(DISTINCT nim) AS distinct_nim,
    COUNT(*) - COUNT(DISTINCT nim) AS excess_duplicate_rows
FROM src.mahasiswa;
```

**Hasil eksekusi:**

![Gambar 12. Verifikasi candidate key NIM](hasil%20unit1.1/soal11.png)


**Analisis:**

- Apakah jumlah seluruh baris sama dengan jumlah NIM unik? **Tidak** (1.965 vs 1.950).
- Apakah terdapat indikasi NIM duplikat? **Ya**, terdapat 15 baris berlebih.
- Apakah hasil ini cukup untuk memutuskan penghapusan record? **Belum**. Hasil hanya menunjukkan selisih jumlah; belum diketahui apakah baris-baris itu identik penuh atau memuat data historis.

**Interpretasi:** Hasil pemeriksaan menunjukkan bahwa jumlah seluruh record sebanyak 1.965 baris, sedangkan jumlah NIM unik sebanyak 1.950. Terdapat selisih 15 baris yang mengindikasikan adanya data dengan NIM yang berulang. Oleh karena itu, NIM belum dapat dinyatakan unik dan masih memerlukan pemeriksaan lebih lanjut sebelum digunakan sebagai candidate key.

**Catatan:** Indikasi duplikasi belum membuktikan bahwa record harus dihapus. Perlu pemeriksaan lanjutan untuk mengetahui apakah record merupakan duplikasi atau data historis.

---

## 10. Mengetahui Rentang Angkatan Mahasiswa

**Query SQL:**

```sql
SELECT
    MIN(CAST(angkatan AS INTEGER)) AS angkatan_min,
    MAX(CAST(angkatan AS INTEGER)) AS angkatan_max
FROM src.mahasiswa;
```

**Hasil eksekusi:**

![Gambar 13. Rentang tahun angkatan](hasil%20unit1.1/soal12.png)


**Interpretasi:** Tahun angkatan mahasiswa berada pada rentang 2021 sampai 2024. Artinya, dataset mencakup empat kelompok tahun angkatan yang dapat digunakan untuk analisis berdasarkan tahun masuk mahasiswa.


---

## 11. Memeriksa Data Kota Asal yang Kosong

**Query SQL:**

```sql
SELECT COUNT(*) AS missing_kota
FROM src.mahasiswa
WHERE TRIM(COALESCE(kota_asal_raw, '')) = '';
```

**Hasil eksekusi:**

![Gambar 14. Jumlah kota asal kosong](hasil%20unit1.1/soal13.png)


**Interpretasi:** Ditemukan sebanyak 30 record mahasiswa yang tidak memiliki informasi kota asal, atau sekitar 1,53% dari keseluruhan data. Kondisi ini menunjukkan bahwa masih terdapat informasi yang belum lengkap pada atribut kota asal. Data tersebut tetap dipertahankan karena belum memasuki tahap perbaikan data.
---

## 12. Menghitung Variasi Label Program Studi pada Mahasiswa

**Query SQL:**

```sql
SELECT COUNT(DISTINCT prodi_raw) AS distinct_prodi_raw
FROM src.mahasiswa;
```

**Hasil eksekusi:**

![Gambar 15. Jumlah label prodi_raw berbeda](hasil%20unit1.1/soal14.png)


**Interpretasi:** Hasil pemeriksaan menemukan 30 variasi nilai pada kolom prodi_raw. Jumlah tersebut lebih banyak dibandingkan dengan program studi resmi yang tersedia pada tabel referensi. Hal ini menunjukkan adanya perbedaan penulisan nama program studi dalam data mahasiswa.
---

## 13. Menghitung Jumlah Program Studi pada Tabel Referensi

**Query SQL:**

```sql
SELECT COUNT(*) AS canonical_programs
FROM src.program_studi;
```

**Hasil eksekusi:**

![Gambar 16. Jumlah program studi pada tabel referensi](hasil%20unit1.1/soal15.png)

**Perbandingan:**

| Keterangan | Jumlah |
|---|---:|
| Variasi label `prodi_raw` | 30 |
| Record pada `src.program_studi` | 6 |

**Interpretasi:** Tabel program_studi memiliki 6 record yang berisi daftar program studi sebagai referensi. Data ini nantinya dapat digunakan sebagai acuan untuk menyesuaikan penulisan program studi pada tabel mahasiswa.

---

## 14. Menampilkan Distribusi Label Program Studi Mentah

**Query SQL:**

```sql
SELECT
    prodi_raw,
    COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY prodi_raw
ORDER BY prodi_raw;
```

**Hasil eksekusi:**

![Gambar 17. Distribusi label program studi mentah](hasil%20unit1.1/soal16.png)



**Interpretasi:** Hasil pengelompokan menunjukkan bahwa label *Teknologi Informasi* memiliki jumlah terbanyak, yaitu 286 record. Selain itu, terdapat variasi penulisan program studi lain yang berbeda dari nama pada tabel referensi. Hal ini menunjukkan bahwa diperlukan pemetaan nama program studi agar data memiliki penamaan yang konsisten.

---

## 15. Menampilkan Variasi Label Jenis Kelamin

**Query SQL:**

```sql
SELECT
    jk_raw,
    COUNT(*) AS jumlah
FROM src.mahasiswa
GROUP BY jk_raw
ORDER BY jk_raw;
```

**Hasil eksekusi:**

![Gambar 20. Variasi label jenis kelamin](hasil%20unit1.1/soal17.png)


**Interpretasi:**  Terdapat enam variasi label jenis kelamin, yaitu F, L, Laki-laki, M, P, dan Perempuan. Meskipun penulisannya berbeda, label tersebut mengarah pada dua kategori yang sama, yaitu laki-laki dan perempuan. Oleh karena itu, diperlukan penyesuaian format label pada tahap pengolahan berikutnya.

---

## 16. Menampilkan Sampel Record Tabel Mahasiswa

**Query SQL:**

```sql
SELECT *
FROM src.mahasiswa
LIMIT 5;
```

**Hasil eksekusi:**

![Gambar 21. Sampel lima record mahasiswa](hasil%20unit1.1/soal18.png)

*Lima baris pertama berdasarkan urutan baris pada file sumber (tanpa `ORDER BY`).*

**Interpretasi:** Lima record yang ditampilkan memberikan gambaran mengenai susunan dan isi data mahasiswa. Dari sampel tersebut dapat dilihat bahwa beberapa kolom masih memiliki variasi format penulisan. Namun, pemeriksaan lima record saja belum cukup untuk menggambarkan seluruh kondisi dataset sehingga diperlukan analisis terhadap keseluruhan data.


---

## 17. Mengidentifikasi Source dengan Jumlah Baris Terbesar

**Query SQL:**

```sql
SELECT 'program_studi' AS source, COUNT(*) AS rows FROM src.program_studi
UNION ALL SELECT 'semester', COUNT(*) FROM src.semester
UNION ALL SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah
UNION ALL SELECT 'krs', COUNT(*) FROM src.krs
UNION ALL SELECT 'nilai', COUNT(*) FROM src.nilai
UNION ALL SELECT 'aktivitas_lms', COUNT(*) FROM src.aktivitas_lms
UNION ALL SELECT 'pembayaran', COUNT(*) FROM src.pembayaran
UNION ALL SELECT 'kelulusan', COUNT(*) FROM src.kelulusan
ORDER BY rows DESC;
```

**Hasil eksekusi:**

![Gambar 25. Source dengan jumlah baris terbesar](hasil%20unit1.1/soal19.png)


**Source dengan jumlah baris terbanyak:** `aktivitas_lms`

**Jumlah baris:** 200.356

**Interpretasi:** Tabel aktivitas_lms memiliki jumlah data paling banyak, yaitu 200.356 baris. Hal ini menunjukkan bahwa data aktivitas mahasiswa pada LMS memiliki volume yang lebih besar dibandingkan sumber lainnya. Jumlah data tersebut perlu diperhatikan dalam proses pengolahan selanjutnya
---

## 18. Mengidentifikasi Indikasi Relasi Mahasiswa dengan Tabel Transaksi

**Query SQL:**

```sql
SELECT 'krs' AS source,
       COUNT(DISTINCT nim) AS distinct_nim
FROM src.krs
UNION ALL
SELECT 'nilai', COUNT(DISTINCT nim) FROM src.nilai
UNION ALL
SELECT 'aktivitas_lms', COUNT(DISTINCT nim) FROM src.aktivitas_lms
UNION ALL
SELECT 'pembayaran', COUNT(DISTINCT nim) FROM src.pembayaran
UNION ALL
SELECT 'kelulusan', COUNT(DISTINCT nim) FROM src.kelulusan;
```

**Hasil eksekusi:**

![Gambar 26. Jumlah NIM unik pada tabel transaksi/aktivitas](hasil%20unit1.1/soal20.png)


### 18.1 Catatan relasi awal

| Rel ID | Source A | Key A | Source B | Key B | Dugaan hubungan bisnis | Catatan/verifikasi lanjutan |
|---|---|---|---|---|---|---|
| REL01 | `mahasiswa` | `nim` | `krs` | `nim` | 1 mahasiswa : banyak KRS | Uji orphan NIM KRS terhadap mahasiswa |
| REL02 | `mahasiswa` | `nim` | `nilai` | `nim` | 1 mahasiswa : banyak nilai | Uji orphan NIM nilai; cocokkan dengan KRS |
| REL03 | `mahasiswa` | `nim` | `aktivitas_lms` | `nim` | 1 mahasiswa : banyak aktivitas LMS | Uji orphan NIM LMS |
| REL04 | `mahasiswa` | `nim` | `pembayaran` | `nim` | 1 mahasiswa : banyak pembayaran | Uji orphan NIM pembayaran |
| REL05 | `mahasiswa` | `nim` | `kelulusan` | `nim` | 1 mahasiswa : 0/1 outcome kelulusan secara bisnis | Uji duplikasi kelulusan dan orphan NIM |

**Interpretasi:** Kolom nim ditemukan pada tabel mahasiswa serta lima tabel lainnya, yaitu KRS, nilai, aktivitas LMS, pembayaran, dan kelulusan. Kesamaan atribut tersebut menunjukkan adanya hubungan antara data mahasiswa dengan data transaksi maupun aktivitas akademik. Namun, hubungan tersebut masih perlu diuji lebih lanjut untuk memastikan bahwa setiap NIM memiliki pasangan data yang sesuai.

---

## 19. Ringkasan Hasil Initial Profiling

| No. | Aspek yang diperiksa | Temuan berdasarkan hasil query | Tindak lanjut yang disarankan |
|---:|---|---|---|
| 1 | Kesiapan environment PostgreSQL | Server dan database dapat diakses; versi dan user tercatat | Pertahankan konfigurasi untuk unit berikutnya |
| 2 | Ketersediaan schema dan tabel | Schema `src` dan 10 tabel tersedia | Tidak ada |
| 3 | Keberhasilan impor dataset | 10 file CSV termuat; jumlah baris sesuai acuan | Pertahankan raw data tanpa perubahan |
| 4 | Jumlah baris setiap source | 6 s.d. 200.356 baris; sesuai acuan | Tidak ada |
| 5 | Jumlah kolom setiap source | 5 s.d. 11 kolom | Tidak ada |
| 6 | Keunikan NIM mahasiswa | 1.965 baris vs 1.950 NIM unik; 15 baris berlebih | Selidiki apakah duplikat persis atau historis |
| 7 | Rentang angkatan | 2021 s.d. 2024 | Tidak ada |
| 8 | Kelengkapan kota asal | 30 record kosong (1,53%) | Tentukan penanganan pada ETL |
| 9 | Variasi label program studi | 30 label vs 6 program studi resmi | Susun tabel mapping label ke kode prodi |
| 10 | Variasi label jenis kelamin | 6 label untuk 2 konsep | Standardisasi ke L/P pada tahap transformasi |
| 11 | Ukuran source terbesar | `aktivitas_lms` (200.356 baris) | Rencanakan pemrosesan bertahap |
| 12 | Indikasi relasi antartabel | `nim` muncul di 5 tabel transaksi | Uji integritas referensial pada Unit 1.2 |

---

## 20. Kesimpulan

## 20. Kesimpulan

Berdasarkan praktikum Modul 1 Unit 1.1, persiapan source layer dan proses initial data profiling pada database akademik berhasil dilakukan menggunakan PostgreSQL melalui DBeaver. Schema `src` berhasil dibuat dengan 10 tabel sumber, dan seluruh dataset UADW v1.0 berhasil diimpor sesuai dengan tabel tujuan masing-masing. Hasil verifikasi juga menunjukkan bahwa jumlah baris dan struktur kolom telah sesuai dengan data yang digunakan dalam praktikum.

Dari proses initial profiling, ditemukan beberapa kondisi pada dataset mahasiswa yang perlu diperhatikan, yaitu adanya 15 baris berlebih pada pemeriksaan NIM, sebanyak 30 record kota asal yang kosong, serta variasi penulisan program studi dan jenis kelamin. Selain itu, data mahasiswa memiliki rentang angkatan 2021–2024, sedangkan tabel `aktivitas_lms` menjadi sumber dengan jumlah data terbesar, yaitu 200.356 baris.

Secara keseluruhan, praktikum ini memberikan gambaran awal mengenai struktur, jumlah, dan kondisi data akademik yang tersedia. Hasil pemeriksaan tersebut dapat dijadikan dasar untuk proses selanjutnya, khususnya dalam mengidentifikasi duplikasi, memeriksa kelengkapan data, menguji hubungan antartabel, serta melakukan cleaning dan standardisasi pada tahap pengolahan berikutnya. Seluruh data pada unit ini tetap dipertahankan dalam bentuk raw tanpa perubahan.