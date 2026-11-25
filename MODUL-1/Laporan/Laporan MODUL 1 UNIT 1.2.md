# LAPORAN MODUL 1 UNIT 1.2

# DATA PROFILING DAN DATA QUALITY ASSESSMENT

---

## Identitas Laporan
## Identitas Laporan

| Identitas | Keterangan |
|---|---|
| Nama | Baiq Nadya Fairuz Qutratu'ain |
| NIM | 240306057 |
| Modul | 1 |
| Unit | 1.2 |
| Tanggal Praktikum | 5 November 2026 |
| DBMS| PostgreSQL |
| Database | uadw_lab |
| Schema | src |
---

## Tujuan Praktikum

Setelah menyelesaikan praktikum ini, mahasiswa diharapkan mampu:

1. Melakukan profiling terhadap struktur dan ukuran dataset akademik.
2. Memeriksa kualitas data berdasarkan aspek *uniqueness*, *completeness*, *validity*, dan *consistency*.
3. Mengidentifikasi indikasi duplikasi pada tabel master maupun transaksi.
4. Memeriksa keterhubungan data antar-tabel (*referential integrity*).
5. Menyusun interpretasi berdasarkan hasil eksekusi query SQL tanpa langsung mengubah data sumber.

## Ketentuan Pengerjaan

1. Menggunakan PostgreSQL dan schema `src` dengan dataset UADW v1.0.
2. Data pada source layer dipertahankan dalam kondisi asli (*raw data*).
3. Praktikum berfokus pada pemeriksaan: tidak ada `UPDATE`, `DELETE`, deduplikasi, atau standardisasi pada tabel `src`.
4. Seluruh query tersimpan pada file `SQL/modul_1_unit_1.2.sql` dan dijalankan melalui SQL Editor DBeaver.
5. Screenshot hasil eksekusi disisipkan pada bagian bukti masing-masing soal.

---

# 1. Menyiapkan dan Memverifikasi Environment Praktikum

### 1.1 Memeriksa versi PostgreSQL

```sql
SELECT version();
```

**Hasil eksekusi:**


![Gambar 27. Hasil SELECT version()](hasil%20unit.1.2/versi_postgre.png)


### 1.2 Memeriksa database dan user aktif

```sql
SELECT
    current_database() AS database_aktif,
    current_user      AS user_aktif;
```

**Hasil eksekusi:**


![Gambar 28. Hasil database dan user aktif](hasil%20unit.1.2/database_aktif.png)


### 1.3 Memastikan schema `src` tersedia

```sql
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'src';
```

**Hasil eksekusi:**


![Gambar 29. Hasil pemeriksaan schema src](hasil%20unit.1.2/schema_src.png)
 

---

# 2. Profiling Struktur dan Ukuran Dataset

## 2.1 Soal 1 — Menghitung jumlah record setiap tabel

**Tujuan pemeriksaan**  
Mengetahui jumlah record pada sepuluh tabel sumber database akademik.

**Query SQL**

```sql
SELECT 'program_studi' AS nama_dataset, COUNT(*) AS jumlah_record FROM src.program_studi
UNION ALL SELECT 'semester', COUNT(*) FROM src.semester
UNION ALL SELECT 'mahasiswa', COUNT(*) FROM src.mahasiswa
UNION ALL SELECT 'dosen', COUNT(*) FROM src.dosen
UNION ALL SELECT 'mata_kuliah', COUNT(*) FROM src.mata_kuliah
UNION ALL SELECT 'krs', COUNT(*) FROM src.krs
UNION ALL SELECT 'nilai', COUNT(*) FROM src.nilai
UNION ALL SELECT 'aktivitas_lms', COUNT(*) FROM src.aktivitas_lms
UNION ALL SELECT 'pembayaran', COUNT(*) FROM src.pembayaran
UNION ALL SELECT 'kelulusan', COUNT(*) FROM src.kelulusan;
```

**Hasil eksekusi**

![Gambar 30. Soal 1 – Jumlah record setiap tabel](hasil%20unit.1.2/soal1.png)


**Interpretasi**

Berdasarkan hasil query, tabel aktivitas_lms memiliki jumlah record terbanyak, yaitu 200.356 baris. Sementara itu, tabel program_studi memiliki jumlah paling sedikit, yaitu 6 baris. Perbedaan jumlah ini menunjukkan bahwa setiap tabel memiliki fungsi dan volume data yang berbeda. Tabel transaksi seperti KRS, nilai, dan aktivitas LMS menyimpan lebih banyak catatan dibandingkan tabel referensi. Selisih jumlah record antara KRS dan nilai juga menjadi hal yang perlu diperhatikan dalam pemeriksaan berikutnya.

## 2.2 Soal 2 — Menghitung jumlah kolom setiap tabel

**Tujuan pemeriksaan**  
Mengetahui jumlah kolom pada setiap tabel dalam schema `src`.

**Query SQL**

```sql
SELECT table_name AS nama_tabel, COUNT(*) AS jumlah_kolom
FROM information_schema.columns
WHERE table_schema = 'src'
GROUP BY table_name
ORDER BY table_name ASC;
```

**Hasil eksekusi**

![Gambar 31. Soal 2 – Jumlah kolom setiap tabel](hasil%20unit.1.2/soal2.png)


**Interpretasi**

Hasil pemeriksaan menunjukkan bahwa setiap tabel memiliki jumlah kolom antara 5 sampai 11 kolom. Tabel mahasiswa memiliki jumlah kolom terbanyak, yaitu 11 kolom, sedangkan tabel program_studi memiliki 5 kolom. Perbedaan tersebut menunjukkan bahwa informasi yang disimpan pada setiap tabel disesuaikan dengan kebutuhan masing-masing. Secara umum, struktur kolom sudah menggambarkan pembagian data dalam database akademik.

---

# 3. Profiling Tabel Mahasiswa

## 3.1 Soal 3 — Mengukur keunikan NIM

**Tujuan pemeriksaan**  
Mengetahui jumlah record mahasiswa, jumlah NIM unik, dan indikasi kelebihan record berdasarkan NIM.

**Query SQL**

```sql
SELECT
    COUNT(*) AS jumlah_seluruh_record,
    COUNT(DISTINCT nim) AS jumlah_nim_unik,
    COUNT(*) - COUNT(DISTINCT nim) AS indikasi_kelebihan_record_duplikat
FROM src.mahasiswa;
```

**Hasil eksekusi**

![Gambar 32. Soal 3 – Keunikan NIM mahasiswa](hasil%20unit.1.2/soal3.png)


**Interpretasi**

Dari 1.965 record mahasiswa, hanya terdapat 1.950 NIM yang berbeda. Artinya, terdapat selisih sebanyak 15 record yang menunjukkan adanya NIM dengan kemunculan lebih dari satu kali. Hasil ini menunjukkan bahwa NIM belum sepenuhnya unik pada tabel mahasiswa. Oleh karena itu, perlu dilakukan pemeriksaan lebih lanjut terhadap record yang memiliki NIM sama.

## 3.2 Soal 4 — Mengidentifikasi NIM duplikat

**Tujuan pemeriksaan**  
Menampilkan NIM yang muncul lebih dari satu kali beserta jumlah kemunculannya.

**Query SQL**

```sql
SELECT nim, COUNT(*) AS jumlah_kemunculan
FROM src.mahasiswa
GROUP BY nim
HAVING COUNT(*) > 1
ORDER BY jumlah_kemunculan DESC, nim ASC;
```

**Hasil eksekusi**

![Gambar 33. Soal 4 – NIM duplikat (bagian 1 dari 2)](hasil%20unit.1.2/soal4.png)


Hasil query menampilkan **15 baris** (15 NIM), masing-masing muncul 2 kali.


**Interpretasi**

Hasil query menemukan 15 NIM yang muncul lebih dari satu kali, dengan masing-masing NIM tercatat sebanyak dua kali. Setelah membandingkan atribut lainnya, record tersebut memiliki isi yang sama. Dengan demikian, pengulangan tersebut mengarah pada duplikasi identik. Temuan ini perlu dicatat sebagai masalah kualitas data, tetapi belum dilakukan penghapusan karena tahap praktikum masih berfokus pada pemeriksaan.


## 3.3 Soal 5 — Memeriksa kelengkapan kota asal mahasiswa

**Tujuan pemeriksaan**  
Menghitung jumlah record dengan `kota_asal_raw` kosong, `NULL`, atau hanya berisi spasi.

**Query SQL**

```sql
SELECT COUNT(*) AS jumlah_kota_asal_kosong
FROM src.mahasiswa
WHERE kota_asal_raw IS NULL
   OR BTRIM(kota_asal_raw) = '';

```

**Hasil eksekusi**

![Gambar 35. Soal 5 – Kelengkapan kota asal](hasil%20unit.1.2/soal5.png)


**Interpretasi**

Ditemukan sebanyak 30 record mahasiswa yang belum memiliki informasi kota asal. Jumlah tersebut sekitar 1,53% dari keseluruhan 1.965 record mahasiswa. Data yang kosong ini dapat menyebabkan informasi mengenai asal wilayah mahasiswa menjadi kurang lengkap. Oleh karena itu, atribut kota asal perlu diperhatikan apabila nantinya digunakan untuk analisis berdasarkan wilayah.

## 3.4 Soal 6 — Distribusi mahasiswa berdasarkan program studi (prodi_raw)

**Tujuan pemeriksaan**  
Menampilkan frekuensi setiap label pada kolom `prodi_raw`.

**Query SQL**

```sql
SELECT prodi_raw, COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY prodi_raw
ORDER BY jumlah_mahasiswa DESC, prodi_raw;
```

**Hasil eksekusi**

![Gambar 36. Soal 6 – Distribusi prodi_raw (bagian 1 dari 3)](hasil%20unit.1.2/soal6.png)


**Interpretasi**

Hasil pengelompokan menunjukkan bahwa penulisan program studi belum sepenuhnya seragam. Terdapat enam nama program studi yang sesuai dengan data referensi, sedangkan 435 record lainnya menggunakan variasi penulisan yang berbeda. Perbedaan tersebut menunjukkan bahwa nama program studi yang sama dapat tercatat dalam beberapa bentuk penulisan. Kondisi ini dapat memengaruhi hasil pengelompokan jumlah mahasiswa berdasarkan program studi.

## 3.5 Soal 7 — Menghitung variasi penulisan program studi

**Tujuan pemeriksaan**  
Menghitung jumlah nilai berbeda pada kolom `prodi_raw`.

**Query SQL**

```sql
SELECT COUNT(DISTINCT prodi_raw) AS jumlah_variasi_nama_prodi
FROM src.mahasiswa
WHERE prodi_raw IS NOT NULL
  AND BTRIM(prodi_raw) <> '';
```

**Hasil eksekusi**

![Gambar 39. Soal 7 – Variasi penulisan program studi](hasil%20unit.1.2/soal7.png)


**Interpretasi**

Berdasarkan hasil query, ditemukan 30 variasi nilai pada kolom prodi_raw, sedangkan tabel referensi hanya memiliki enam nama program studi resmi. Artinya, terdapat 24 variasi tambahan yang belum sesuai dengan penamaan pada tabel referensi. Perbedaan ini menunjukkan bahwa atribut program studi masih memerlukan pemeriksaan agar setiap mahasiswa dapat dikelompokkan berdasarkan program studi yang tepat.

## 3.6 Soal 8 — Distribusi jenis kelamin (jk_raw)

**Tujuan pemeriksaan**  
Menampilkan setiap nilai `jk_raw` dan frekuensi kemunculannya.

**Query SQL**

```sql
SELECT jk_raw, COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY jk_raw
ORDER BY jumlah_mahasiswa DESC, jk_raw;
```

**Hasil eksekusi**

![Gambar 40. Soal 8 – Distribusi jk_raw](hasil%20unit.1.2/soal8.png)

**Interpretasi**

Hasil pemeriksaan menunjukkan terdapat enam bentuk penulisan jenis kelamin, yaitu L, P, Laki-laki, Perempuan, M, dan F. Keenam bentuk tersebut mengarah pada dua kategori jenis kelamin, tetapi menggunakan kode dan istilah yang berbeda. Sebanyak 437 record atau sekitar 22,2% menggunakan bentuk selain kode L dan P. Hal ini menunjukkan bahwa penulisan jenis kelamin belum konsisten dan perlu diperiksa menggunakan acuan kategori yang sama.

## 3.7 Soal 9 — Distribusi status mahasiswa (status_raw)

**Tujuan pemeriksaan**  
Menampilkan variasi nilai `status_raw` dan jumlah record pada setiap status.

**Query SQL**

```sql
SELECT status_raw, COUNT(*) AS jumlah_record
FROM src.mahasiswa
GROUP BY status_raw
ORDER BY jumlah_record DESC, status_raw;
```

**Hasil eksekusi**

![Gambar 39. Soal 9 – Distribusi status_raw](hasil%20unit.1.2/soal9.png)


**Interpretasi**

Dari hasil pengelompokan ditemukan enam variasi penulisan status mahasiswa yang mewakili tiga kategori, yaitu Aktif, Lulus, dan Cuti. Perbedaan penulisan muncul karena penggunaan huruf kapital dan spasi yang tidak seragam. Terdapat 43 record dengan penulisan yang berbeda dari bentuk standar. Jika tidak diperhatikan, variasi tersebut dapat membuat satu status terbaca sebagai beberapa kategori berbeda ketika dilakukan analisis.

## 3.8 Soal 10 — Distribusi kode program studi (kode_prodi_raw)

**Tujuan pemeriksaan**  
Menampilkan nilai `kode_prodi_raw` dan frekuensi kemunculannya.

**Query SQL**

```sql
SELECT kode_prodi_raw, COUNT(*) AS jumlah_mahasiswa
FROM src.mahasiswa
GROUP BY kode_prodi_raw
ORDER BY jumlah_mahasiswa DESC, kode_prodi_raw;
```

**Hasil eksekusi**

![Gambar 40. Soal 10 – Distribusi kode_prodi_raw (bagian 1 dari 3)](hasil%20unit.1.2/soal10.png)


Nilai yang ditulis dengan tanda kutip memiliki spasi di depan/belakang.

**Interpretasi**

Hasil query menunjukkan terdapat 24 variasi penulisan kode program studi, sedangkan tabel referensi hanya menyediakan enam kode resmi. Kode IF menjadi kode yang paling sering ditemukan, yaitu sebanyak 336 record. Selain itu, terdapat 208 record yang memiliki perbedaan penulisan, terdiri dari 136 record dengan tambahan spasi dan 72 record menggunakan huruf kecil. Setelah diperiksa menggunakan konsep TRIM dan UPPER, seluruh kode dapat dicocokkan dengan kode pada tabel referensi. Hal ini menunjukkan bahwa perbedaannya terdapat pada cara penulisan kode.

## 3.9 Soal 11 — Nama program studi tidak sesuai standar

**Tujuan pemeriksaan**  
Menghitung record mahasiswa dengan `prodi_raw` yang tidak cocok persis dengan `program_studi.nama_prodi`.

**Query SQL**

```sql
SELECT COUNT(*) AS jumlah_prodi_tidak_ditemukan
FROM src.mahasiswa m
WHERE m.prodi_raw IS NOT NULL
  AND BTRIM(m.prodi_raw) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM src.program_studi p
      WHERE p.nama_prodi = m.prodi_raw
```

**Hasil eksekusi**

![Gambar 43. Soal 11 – Nama program studi tidak sesuai standar](hasil%20unit.1.2/soal11.png)


**Interpretasi**

Hasil pemeriksaan menemukan 435 record mahasiswa dengan nama program studi yang tidak cocok secara persis dengan tabel referensi. Jumlah tersebut setara dengan sekitar 22,1% dari keseluruhan data mahasiswa. Ketidaksesuaian ini dapat disebabkan oleh singkatan, perbedaan huruf kapital, tambahan spasi, atau variasi penulisan lainnya. Oleh karena itu, setiap nama program studi perlu diperiksa kembali agar dapat dipasangkan dengan data referensi yang sesuai.

## 3.10 Soal 12 — Variasi format tanggal masuk

**Tujuan pemeriksaan**  
Mengelompokkan `tanggal_masuk_raw` berdasarkan format `YYYY-MM-DD`, `DD/MM/YYYY`, `DD-Mon-YYYY`, dan `OTHER`.

**Query SQL**

```sql
WITH klasifikasi AS (
    SELECT
        CASE
            WHEN tanggal_masuk_raw ~ '^\d{4}-\d{2}-\d{2}$'        THEN 'YYYY-MM-DD'
            WHEN tanggal_masuk_raw ~ '^\d{2}/\d{2}/\d{4}$'        THEN 'DD/MM/YYYY'
            WHEN tanggal_masuk_raw ~ '^\d{2}-[A-Za-z]{3}-\d{4}$'   THEN 'DD-Mon-YYYY'
            ELSE 'OTHER'
        END AS format_tanggal
    FROM src.mahasiswa
)
SELECT
    f.format_tanggal,
    COUNT(k.format_tanggal) AS jumlah_record
FROM (VALUES ('YYYY-MM-DD'), ('DD/MM/YYYY'), ('DD-Mon-YYYY'), ('OTHER')) AS f(format_tanggal)
LEFT JOIN klasifikasi k ON k.format_tanggal = f.format_tanggal
GROUP BY f.format_tanggal
ORDER BY jumlah_record DESC;
```

**Hasil eksekusi**

![Gambar 44. Soal 12 – Variasi format tanggal masuk](hasil%20unit.1.2/soal12.png)

**Interpretasi**

Hasil klasifikasi menunjukkan bahwa terdapat tiga format tanggal masuk, yaitu YYYY-MM-DD sebanyak 1.429 record, DD/MM/YYYY sebanyak 346 record, dan DD-Mon-YYYY sebanyak 190 record. Tidak ditemukan data yang masuk kategori OTHER. Meskipun seluruh data sudah mengikuti salah satu pola yang diperiksa, penggunaan beberapa format berbeda dapat menyulitkan pengolahan dan perbandingan data tanggal. Selain itu, pola penulisan yang sesuai belum tentu menjamin bahwa tanggal tersebut benar-benar valid.

---

# 4. Profiling Tabel KRS

## 4.1 Soal 13 — Jumlah record KRS vs krs_id unik

**Tujuan pemeriksaan**  
Membandingkan jumlah seluruh record KRS dengan jumlah `krs_id` yang unik.

**Query SQL**

```sql
SELECT
    COUNT(*) AS jumlah_seluruh_record_krs,
    COUNT(DISTINCT krs_id) AS jumlah_krs_id_unik
FROM src.krs;
```

**Hasil eksekusi**

![Gambar 45. Soal 13 – Record KRS vs krs_id unik](hasil%20unit.1.2/soal13.png)

**Interpretasi**

Hasil perhitungan menunjukkan bahwa tabel KRS memiliki 57.025 record, sedangkan jumlah krs_id unik sebanyak 57.000. Terdapat selisih 25 record yang menunjukkan adanya ID KRS yang digunakan lebih dari satu kali. Kondisi ini menjadi indikasi awal adanya duplikasi pada tabel KRS sehingga perlu diperiksa berdasarkan kombinasi atribut lainnya.


## 4.2 Soal 14 — Duplikasi pengambilan mata kuliah (nim, kode_mk, semester_id)

**Tujuan pemeriksaan**  
Menemukan kombinasi `nim`, `kode_mk`, dan `semester_id` yang muncul lebih dari satu kali pada tabel KRS.

**Query SQL**

```sql
SELECT nim, kode_mk, semester_id, COUNT(*) AS jumlah_kemunculan
FROM src.krs
GROUP BY nim, kode_mk, semester_id
HAVING COUNT(*) > 1
ORDER BY jumlah_kemunculan DESC, nim, kode_mk, semester_id;
```

**Hasil eksekusi**

![Gambar 46. Soal 14 – Duplikasi pengambilan mata kuliah (bagian 1 dari 3)](hasil%20unit.1.2/soal14.png)


Hasil query menampilkan **25 kombinasi** `nim + kode_mk + semester_id`, masing-masing dengan `jumlah` = 2.


**Interpretasi**

Hasil pengelompokan menemukan 25 kombinasi NIM, kode mata kuliah, dan semester yang masing-masing muncul sebanyak dua kali. Pemeriksaan terhadap atribut lainnya menunjukkan bahwa baris-baris tersebut memiliki isi yang sama, termasuk nilai krs_id. Dengan demikian, data tersebut mengarah pada duplikasi identik. Apabila digunakan langsung dalam analisis, pengulangan ini dapat menyebabkan jumlah pengambilan mata kuliah dan perhitungan SKS menjadi lebih besar dari jumlah sebenarnya.

## 4.3 Soal 15 — Kelebihan record KRS akibat duplikasi

**Tujuan pemeriksaan**  
Menghitung total record yang melebihi satu record pada setiap kelompok duplikat.

**Query SQL**

```sql
SELECT COALESCE(SUM(jumlah_kemunculan - 1), 0) AS total_kelebihan_record_duplikat
FROM (
    SELECT COUNT(*) AS jumlah_kemunculan
    FROM src.krs
    GROUP BY nim, kode_mk, semester_id
    HAVING COUNT(*) > 1
) AS kelompok_duplikat;
```

**Hasil eksekusi**

![Gambar 49. Soal 15 – Kelebihan record KRS akibat duplikasi](hasil%20unit.1.2/soal15.png)


**Interpretasi**

Hasil perhitungan menunjukkan terdapat 25 record tambahan akibat pengulangan data pada tabel KRS. Setiap kelompok duplikat memiliki dua baris, sehingga terdapat satu record berlebih pada setiap kelompok. Hasil ini sesuai dengan pemeriksaan sebelumnya yang menemukan 25 kombinasi duplikat. Dengan demikian, kedua pemeriksaan tersebut menunjukkan adanya penggandaan record pada tabel KRS.

---

# 5. Profiling Tabel Nilai

## 5.1 Soal 16 — Nilai angka kosong

**Tujuan pemeriksaan**  
Menghitung record dengan `nilai_angka` kosong, `NULL`, atau hanya berisi spasi.

**Query SQL**

```sql
SELECT COUNT(*) AS jumlah_nilai_angka_kosong
FROM src.nilai
WHERE nilai_angka IS NULL;
```

**Hasil eksekusi**

![Gambar 50. Soal 16 – Nilai angka kosong](hasil%20unit.1.2/soal16.png)


**Interpretasi**

Ditemukan 20 record pada tabel nilai yang tidak memiliki nilai angka. Pada record yang sama, atribut nilai huruf juga tidak terisi. Kondisi ini menunjukkan bahwa informasi hasil penilaian belum tersedia secara lengkap. Data tersebut perlu diperiksa lebih lanjut karena dapat memengaruhi perhitungan rata-rata dan analisis hasil akademik mahasiswa.

## 5.2 Soal 17 — Nilai angka di luar rentang 0-100

**Tujuan pemeriksaan**  
Menghitung nilai angka di luar rentang 0–100 (nilai kosong tidak dihitung).

**Query SQL**

```sql
SELECT COUNT(*) AS jumlah_nilai_di_luar_rentang
FROM src.nilai
WHERE nilai_angka IS NOT NULL
  AND (nilai_angka < 0 OR nilai_angka > 100);
```

**Hasil eksekusi**

![Gambar 51. Soal 17 – Nilai angka di luar rentang 0–100](hasil%20unit.1.2/soal17.png)


**Interpretasi**

Hasil pemeriksaan menemukan 12 record dengan nilai angka di luar rentang 0–100. Jumlah tersebut terdiri dari enam nilai negatif dan enam nilai yang melebihi 100. Nilai terendah tercatat sebesar -18, sedangkan nilai tertinggi mencapai 106. Hasil ini menunjukkan adanya nilai yang tidak sesuai dengan batas penilaian yang digunakan sehingga perlu ditelusuri kembali sumber dan penyebab pencatatannya.


## 5.3 Soal 18 — Statistik deskriptif nilai valid

**Tujuan pemeriksaan**  
Menghitung jumlah nilai valid, minimum, maksimum, dan rata-rata untuk nilai angka dalam rentang 0–100.

**Query SQL**

```sql
SELECT
    COUNT(*) AS jumlah_record_nilai_valid,
    MIN(nilai_angka) AS nilai_terendah,
    MAX(nilai_angka) AS nilai_tertinggi,
    AVG(nilai_angka) AS nilai_rata_rata
FROM src.nilai
WHERE nilai_angka BETWEEN 0 AND 100;
```

**Hasil eksekusi**

![Gambar 52. Soal 18 – Statistik deskriptif nilai valid (bagian 1 dari 2)](hasil%20unit.1.2/soal18.png)


Jumlah valid = 57.000 − 20 (kosong) − 12 (di luar rentang 0–100) = 56.968. Sebagai pembanding, tanpa filter rentang nilai berkisar −18 sampai 106 (rata-rata 77,39) sehingga outlier memperlebar rentang.

**Interpretasi**

Setelah nilai kosong dan nilai di luar rentang dikecualikan, diperoleh 56.968 record yang memenuhi kriteria nilai valid. Nilai terendah adalah 34,8, nilai tertinggi 100,0, dan rata-rata sebesar 77,40. Hasil tersebut memberikan gambaran mengenai nilai mahasiswa berdasarkan data yang berada dalam rentang 0–100. Dengan demikian, statistik ini lebih tepat digunakan untuk menggambarkan persebaran nilai dibandingkan perhitungan yang masih memasukkan nilai di luar rentang.

## 5.4 Soal 19 — Konsistensi nilai angka dan nilai huruf

**Tujuan pemeriksaan**  
Menghitung record dengan ketidaksesuaian antara `nilai_angka` dan `nilai_huruf` berdasarkan aturan konversi pada soal.

**Query SQL**

```sql
WITH nilai_valid AS (
    SELECT
        nilai_id,
        NULLIF(TRIM(nilai_angka::text), '')::numeric AS angka,
        TRIM(nilai_huruf) AS huruf
    FROM src.nilai
)
SELECT COUNT(*) AS letter_mismatch FROM nilai_valid
WHERE angka BETWEEN 0 AND 100
  AND huruf IS DISTINCT FROM CASE
        WHEN angka >= 85 THEN 'A'
        WHEN angka >= 80 THEN 'AB'
        WHEN angka >= 75 THEN 'B'
        WHEN angka >= 70 THEN 'BC'
        WHEN angka >= 60 THEN 'C'
        WHEN angka >= 50 THEN 'D'
        ELSE 'E'
      END;
```

**Hasil eksekusi**

![Gambar 54. Soal 19 – Konsistensi nilai angka dan nilai huruf](hasil%20unit.1.2/soal19.png)


**Interpretasi**

Hasil pemeriksaan menemukan 20 record yang memiliki ketidaksesuaian antara nilai angka dan nilai huruf berdasarkan aturan konversi yang digunakan dalam query. Sebagai contoh, nilai angka 68,2 seharusnya masuk kategori C, tetapi tercatat D. Sementara itu, nilai 82,8 tercatat B, padahal berdasarkan aturan pemeriksaan seharusnya AB. Temuan ini menunjukkan bahwa sebagian data nilai belum mengikuti aturan konversi yang digunakan sehingga perlu dibandingkan kembali dengan ketentuan penilaian resmi.


## 5.5 Soal 20 — Konsistensi nilai angka dan status kelulusan

**Tujuan pemeriksaan**  
Menghitung record dengan ketidaksesuaian antara `nilai_angka` dan `status_lulus` (≥ 60 = Lulus, < 60 = Tidak Lulus).

**Query SQL**

```sql
WITH nilai_valid AS (
    SELECT
        NULLIF(TRIM(nilai_angka::text), '')::numeric AS angka,
        TRIM(status_lulus) AS status_lulus
    FROM src.nilai
)
SELECT COUNT(*) AS status_mismatch
FROM nilai_valid
WHERE angka BETWEEN 0 AND 100
  AND ( (angka >= 60 AND status_lulus IS DISTINCT FROM 'Lulus')
     OR (angka <  60 AND status_lulus IS DISTINCT FROM 'Tidak Lulus') );
```

**Hasil eksekusi**

![Gambar 55. Soal 20 – Konsistensi nilai angka dan status kelulusan](hasil%20unit.1.2/soal20.png)


Sebagai pembanding, pemeriksaan **nilai_huruf vs status_lulus** pada profiling awal menemukan 17 record tidak konsisten. Pemeriksaan tersebut berbasis huruf sehingga berbeda dengan soal ini yang berbasis nilai angka.

**Interpretasi**

Hasil query menunjukkan angka 0, yang berarti tidak ditemukan ketidaksesuaian antara nilai angka dan status kelulusan berdasarkan aturan yang digunakan. Seluruh nilai minimal 60 memiliki status Lulus, sedangkan nilai di bawah 60 memiliki status Tidak Lulus. Dengan demikian, hubungan antara nilai angka dan status kelulusan sudah sesuai pada pemeriksaan ini. Namun, hasil tersebut tidak berarti seluruh data penilaian sudah konsisten karena masih ditemukan ketidaksesuaian antara nilai angka dan nilai huruf pada pemeriksaan sebelumnya.

## 5.6 Soal 21 — Duplikasi record nilai

**Tujuan pemeriksaan**  
Menampilkan kombinasi `nim`, `kode_mk`, `semester_id` yang tercatat lebih dari satu kali pada tabel nilai.

**Query SQL**

```sql
SELECT nim, kode_mk, semester_id, COUNT(*) AS jumlah_kemunculan
FROM src.nilai
GROUP BY nim, kode_mk, semester_id
HAVING COUNT(*) > 1
ORDER BY jumlah_kemunculan DESC, nim, kode_mk, semester_id;
```

**Hasil eksekusi**

![Gambar 56. Soal 21 – Duplikasi record nilai](hasil%20unit.1.2/soal21.png)


Query menghasilkan **0 baris** (tidak ada kombinasi yang muncul lebih dari satu kali).

**Interpretasi**

Hasil query tidak menemukan kombinasi NIM, kode mata kuliah, dan semester yang muncul lebih dari satu kali. Selain itu, jumlah record sebanyak 57.000 sesuai dengan jumlah nilai_id unik. Hasil ini menunjukkan bahwa tidak ditemukan indikasi duplikasi berdasarkan atribut yang diperiksa pada tabel nilai. Dengan demikian, keunikan kombinasi tersebut sudah terpenuhi berdasarkan hasil query.

---

# 6. Pemeriksaan Referential Integrity pada KRS dan Nilai

## 6.1 Soal 22 — NIM KRS tidak terdaftar di mahasiswa

**Tujuan pemeriksaan**  
Menghitung record yang NIM pada tabel KRS tidak ditemukan pada tabel referensinya.

**Query SQL**

```sql
SELECT COUNT(*) AS krs_nim_tidak_terdaftar
FROM src.krs k
LEFT JOIN src.mahasiswa m ON k.nim = m.nim
WHERE m.nim IS NULL;
```

**Hasil eksekusi**

![Gambar 57. Soal 22 – NIM KRS tidak terdaftar](hasil%20unit.1.2/soal22.png)


**Interpretasi**

Hasil pemeriksaan menunjukkan terdapat 0 record NIM pada tabel KRS yang tidak ditemukan di tabel mahasiswa. Artinya, seluruh NIM yang digunakan pada tabel KRS memiliki pasangan pada tabel mahasiswa. Dengan demikian, relasi antara kedua tabel berdasarkan atribut NIM sudah sesuai pada pemeriksaan ini dan tidak ditemukan data yatim (orphan record).


## 6.2 Soal 23 — NIM nilai tidak terdaftar di mahasiswa

**Tujuan pemeriksaan**  
Menghitung record yang NIM pada tabel nilai tidak ditemukan pada tabel referensinya.

**Query SQL**

```sql
SELECT COUNT(*) AS nim_tidak_terdaftar
FROM src.nilai n
LEFT JOIN src.mahasiswa m ON n.nim = m.nim
WHERE m.nim IS NULL;
```

**Hasil eksekusi**

![Gambar 58. Soal 23 – NIM nilai tidak terdaftar](hasil%20unit.1.2/soal23.png)


**Interpretasi**

Hasil query menunjukkan tidak ditemukan NIM pada tabel nilai yang tidak memiliki pasangan di tabel mahasiswa. Seluruh NIM pada tabel nilai dapat ditemukan pada tabel referensi. Hal ini menunjukkan bahwa hubungan antara data nilai dan data mahasiswa sudah terpenuhi berdasarkan pemeriksaan atribut NIM.


## 6.3 Soal 24 — Kode MK nilai tidak ada di mata_kuliah

**Tujuan pemeriksaan**  
Menghitung record yang `kode_mk` pada tabel nilai tidak ditemukan pada tabel referensinya.

**Query SQL**

```sql
SELECT COUNT(*) AS orphan_nilai_mk
FROM src.nilai n
LEFT JOIN src.mata_kuliah mk ON n.kode_mk = mk.kode_mk
WHERE mk.kode_mk IS NULL;
```

**Hasil eksekusi**

![Gambar 59. Soal 24 – Kode MK nilai tidak terdaftar](hasil%20unit.1.2/soal24.png)


**Interpretasi**

Hasil pemeriksaan menghasilkan 0 record yang memiliki kode mata kuliah tidak terdaftar. Artinya, seluruh kode_mk pada tabel nilai dapat ditemukan pada tabel mata_kuliah. Dengan demikian, relasi antara kedua tabel berdasarkan kode mata kuliah sudah sesuai dan tidak ditemukan data yatim pada pemeriksaan ini.

## 6.4 Soal 25 — Semester nilai tidak ada di semester

**Tujuan pemeriksaan**  
Menghitung record yang `semester_id` pada tabel nilai tidak ditemukan pada tabel referensinya.

**Query SQL**

```sql
SELECT COUNT(*) AS orphan_nilai_semester
FROM src.nilai n
LEFT JOIN src.semester s ON n.semester_id = s.semester_id
WHERE s.semester_id IS NULL;
```

**Hasil eksekusi**

![Gambar 60. Soal 25 – Semester nilai tidak terdaftar](hasil%20unit.1.2/soal25.png)


**Interpretasi**

Hasil query menunjukkan tidak ditemukan semester_id pada tabel nilai yang tidak memiliki pasangan pada tabel semester. Seluruh data semester yang digunakan pada tabel nilai dapat ditemukan pada tabel referensi. Hal ini menunjukkan bahwa hubungan antara tabel nilai dan tabel semester sudah terpenuhi berdasarkan atribut yang diperiksa.

---

# 7. Profiling Aktivitas LMS

## 7.1 Soal 26 — Duplikasi aktivitas LMS (lms_event_id)

**Tujuan pemeriksaan**  
Membandingkan jumlah seluruh record aktivitas LMS dengan jumlah `lms_event_id` unik.

**Query SQL**

```sql
SELECT
    COUNT(*)                          AS raw_rows,
    COUNT(DISTINCT lms_event_id)      AS distinct_event_id,
    COUNT(*) - COUNT(DISTINCT lms_event_id) AS duplicate_excess
FROM src.aktivitas_lms;
```

**Hasil eksekusi**

![Gambar 61. Soal 26 – Duplikasi aktivitas LMS](hasil%20unit.1.2/soal26.png)


**Interpretasi**

Hasil perbandingan menunjukkan bahwa tabel aktivitas LMS memiliki 200.356 record, sedangkan jumlah lms_event_id unik sebanyak 200.326. Dengan demikian, terdapat 30 record tambahan. Pemeriksaan lanjutan menunjukkan bahwa record tambahan tersebut memiliki isi yang sama dengan baris lainnya. Hal ini mengindikasikan adanya duplikasi identik yang dapat menyebabkan jumlah aktivitas LMS tercatat lebih besar apabila tidak diperhatikan dalam proses analisis.

## 7.2 Soal 27 — Distribusi tipe aktivitas LMS

**Tujuan pemeriksaan**  
Menampilkan setiap `tipe_event` dan jumlah aktivitas pada masing-masing tipe.

**Query SQL**

```sql
SELECT
    tipe_event,
    COUNT(*) AS jumlah
FROM src.aktivitas_lms
GROUP BY tipe_event
ORDER BY jumlah DESC, tipe_event;
```

**Hasil eksekusi**

![Gambar 62. Soal 27 – Distribusi tipe aktivitas LMS](hasil%20unit.1.2/soal27.png)

**Interpretasi**

Hasil pengelompokan menunjukkan bahwa aktivitas LMS terdiri dari lima jenis event. Aktivitas view_material menjadi jenis yang paling banyak dilakukan dengan 56.040 record, sedangkan forum_post memiliki jumlah paling sedikit, yaitu 10.000 record. Hasil ini memperlihatkan bahwa aktivitas melihat materi lebih banyak tercatat dibandingkan aktivitas lainnya. Selain itu, tidak ditemukan perbedaan penulisan pada label tipe aktivitas yang diperiksa.

## 7.3 Soal 28 — Skor kuis kosong pada quiz_attempt

**Tujuan pemeriksaan**  
Menghitung aktivitas `quiz_attempt` yang tidak memiliki skor pada `skor_kuis`.

**Query SQL**

```sql
SELECT COUNT(*) AS quiz_missing_score
FROM src.aktivitas_lms
WHERE tipe_event = 'quiz_attempt'
  AND (skor_kuis IS NULL OR TRIM(skor_kuis::text) = '');
```

**Hasil eksekusi**

![Gambar 63. Soal 28 – Skor kuis kosong pada quiz_attempt](hasil%20unit.1.2/soal28.png)


**Interpretasi**

Hasil pemeriksaan menunjukkan bahwa tidak ditemukan aktivitas quiz_attempt yang memiliki skor kuis kosong. Artinya, seluruh 40.321 record percobaan kuis sudah memiliki informasi skor. Berdasarkan pemeriksaan kelengkapan tersebut, atribut skor kuis pada jenis aktivitas ini sudah terisi seluruhnya.


## 7.4 Soal 29 — Skor pada aktivitas selain kuis

**Tujuan pemeriksaan**  
Menghitung aktivitas selain `quiz_attempt` yang tetap memiliki nilai pada `skor_kuis`.

**Query SQL**

```sql
SELECT COUNT(*) AS nonquiz_with_score
FROM src.aktivitas_lms
WHERE tipe_event <> 'quiz_attempt'
  AND skor_kuis IS NOT NULL
  AND TRIM(skor_kuis::text) <> '';
```

**Hasil eksekusi**

![Gambar 64. Soal 29 – Skor pada aktivitas selain kuis](hasil%20unit.1.2/soal29.png)


**Interpretasi**

Hasil query menunjukkan angka 0, yang berarti tidak ditemukan skor kuis pada aktivitas selain quiz_attempt. Hasil ini sesuai dengan fungsi atribut skor_kuis, yaitu menyimpan nilai untuk aktivitas percobaan kuis. Dengan demikian, pengisian skor pada aktivitas LMS sudah sesuai dengan jenis aktivitas yang diperiksa.

---

# 8. Profiling Tabel Pembayaran

## 8.1 Soal 30 — Nominal pembayaran negatif

**Tujuan pemeriksaan**  
Menghitung record pembayaran dengan `nominal_bayar` kurang dari nol.

**Query SQL**

```sql
SELECT COUNT(*) AS negative_payment
FROM src.pembayaran
WHERE nominal_bayar < 0;
```

**Hasil eksekusi**

![Gambar 65. Soal 30 – Nominal pembayaran negatif](hasil%20unit.1.2/soal30.png)


**Interpretasi**

Ditemukan lima record pembayaran yang memiliki nominal negatif, dengan nilai minimum sebesar -5.750.000. Seluruh transaksi tersebut tercatat dengan status Lunas. Kondisi ini perlu diperiksa karena nominal negatif dapat memengaruhi perhitungan total pembayaran. Perlu dipastikan apakah nilai tersebut merupakan pencatatan koreksi atau pengembalian dana, maupun akibat kesalahan input.

## 8.2 Soal 31 — Pembayaran positif tanpa tanggal bayar

**Tujuan pemeriksaan**  
Menghitung pembayaran bernominal positif tetapi `tanggal_bayar_raw` kosong.

**Query SQL**

```sql
SELECT COUNT(*) AS positive_payment_missing_date
FROM src.pembayaran
WHERE nominal_bayar > 0
  AND (tanggal_bayar_raw IS NULL OR TRIM(tanggal_bayar_raw) = '');
```

**Hasil eksekusi**

![Gambar 66. Soal 31 – Pembayaran positif tanpa tanggal bayar](hasil%20unit.1.2/soal31.png)



**Interpretasi**

Hasil query menemukan 12 transaksi dengan nominal pembayaran positif tetapi tidak memiliki tanggal pembayaran. Dari jumlah tersebut, 10 transaksi berstatus Lunas dan dua transaksi berstatus Cicilan. Kondisi ini menunjukkan bahwa masih terdapat transaksi yang belum memiliki informasi waktu pembayaran secara lengkap. Oleh karena itu, tanggal pada transaksi tersebut perlu dikonfirmasi agar riwayat pembayaran dapat ditelusuri dengan baik.

## 8.3 Soal 32 — Distribusi status pembayaran

**Tujuan pemeriksaan**  
Menampilkan jumlah record berdasarkan setiap nilai `status_pembayaran`.

**Query SQL**

```sql
SELECT status_pembayaran, COUNT(*) AS jumlah_record
FROM src.pembayaran
GROUP BY status_pembayaran
ORDER BY jumlah DESC, status_pembayaran;
```

**Hasil eksekusi**

![Gambar 67. Soal 32 – Distribusi status pembayaran](hasil%20unit.1.2/soal32.png)



**Interpretasi**

Berdasarkan hasil pengelompokan, terdapat tiga kategori status pembayaran, yaitu Lunas, Cicilan, dan Belum Lunas. Status Lunas memiliki jumlah terbanyak, yaitu 7.962 record atau sekitar 83,8% dari keseluruhan transaksi. Selanjutnya, terdapat 1.077 transaksi berstatus Cicilan dan 461 transaksi berstatus Belum Lunas. Hasil ini menunjukkan bahwa sebagian besar transaksi sudah tercatat lunas, sedangkan transaksi lainnya masih memiliki pembayaran yang belum diselesaikan.

---

# 9. Profiling Tabel Kelulusan

## 9.1 Soal 33 — Duplikasi data kelulusan

**Tujuan pemeriksaan**  
Membandingkan jumlah seluruh record kelulusan dengan jumlah NIM unik.

**Query SQL**

```sql
SELECT
    COUNT(*)                         AS raw_rows,
    COUNT(DISTINCT nim)              AS distinct_graduate_nim,
    COUNT(*) - COUNT(DISTINCT nim)   AS duplicate_excess
FROM src.kelulusan;
```

**Hasil eksekusi**

![Gambar 68. Soal 33 – Duplikasi data kelulusan](hasil%20unit.1.2/soal33.png)



**Interpretasi**

Hasil pemeriksaan menunjukkan terdapat selisih dua record antara jumlah keseluruhan data kelulusan dan jumlah NIM unik. Dua NIM yang ditemukan muncul sebanyak dua kali, yaitu 21SI0036 dan 21BD0005. Setelah diperiksa, kedua baris tersebut memiliki isi yang sama sehingga mengarah pada duplikasi identik. Kondisi ini dapat menyebabkan jumlah lulusan tercatat lebih banyak dari jumlah mahasiswa yang sebenarnya.

## 9.2 Soal 34 — Status kelulusan tepat waktu

**Tujuan pemeriksaan**  
Menampilkan jumlah record berdasarkan setiap nilai `status_tepat_waktu`.

**Query SQL**

```sql
SELECT status_tepat_waktu, COUNT(*) AS jumlah_mahasiswa
FROM src.kelulusan
GROUP BY status_tepat_waktu
ORDER BY jumlah_mahasiswa DESC, status_tepat_waktu;
```

**Hasil eksekusi**

![Gambar 69. Soal 34 – Status kelulusan tepat waktu](hasil%20unit.1.2/soal34.png)



**Interpretasi**

Seluruh 347 record pada tabel kelulusan memiliki status tepat waktu. Setelah memperhitungkan dua record duplikat, terdapat 345 mahasiswa unik dan semuanya tercatat lulus tepat waktu. Data tersebut terdiri dari 308 mahasiswa dengan masa studi 46 bulan dan 39 mahasiswa dengan masa studi 47 bulan. Karena tidak ditemukan kategori tidak tepat waktu, perbandingan antara mahasiswa yang lulus tepat waktu dan terlambat belum dapat dilakukan. Kondisi ini perlu dikonfirmasi untuk memastikan apakah memang belum terdapat data lulusan terlambat atau informasinya belum tercatat.

---

# 10. Pemeriksaan Relasi Antar-Tabel

## 10.1 Soal 35 — Aktivitas LMS dengan NIM tidak terdaftar

**Tujuan pemeriksaan**  
Menghitung record yang NIM pada aktivitas LMS tidak ditemukan pada tabel referensinya.

**Query SQL**

```sql
SELECT COUNT(*) AS orphan_lms_student
FROM src.aktivitas_lms a
LEFT JOIN src.mahasiswa m ON a.nim = m.nim
WHERE m.nim IS NULL;
```

**Hasil eksekusi**

![Gambar 70. Soal 35 – Aktivitas LMS dengan NIM tidak terdaftar](hasil%20unit.1.2/soal35.png)



**Interpretasi**

Hasil pemeriksaan menunjukkan tidak ditemukan NIM pada tabel aktivitas LMS yang tidak terdaftar di tabel mahasiswa. Artinya, seluruh aktivitas LMS yang diperiksa memiliki hubungan dengan data mahasiswa yang sesuai. Dengan demikian, relasi antara aktivitas LMS dan mahasiswa berdasarkan NIM sudah terpenuhi pada pemeriksaan ini.

## 10.2 Soal 36 — Aktivitas LMS dengan kode MK tidak terdaftar

**Tujuan pemeriksaan**  
Menghitung record yang `kode_mk` pada aktivitas LMS tidak ditemukan pada tabel referensinya.

**Query SQL**

```sql
SELECT COUNT(*) AS orphan_lms_course
FROM src.aktivitas_lms a
LEFT JOIN src.mata_kuliah mk ON a.kode_mk = mk.kode_mk
WHERE mk.kode_mk IS NULL;
```

**Hasil eksekusi**

![Gambar 71. Soal 36 – Aktivitas LMS dengan kode MK tidak terdaftar](hasil%20unit.1.2/soal36.png)



**Interpretasi**

Hasil query menunjukkan angka 0, yang berarti seluruh kode mata kuliah pada tabel aktivitas LMS dapat ditemukan pada tabel mata_kuliah. Tidak ditemukan kode mata kuliah yang tidak memiliki pasangan pada tabel referensi. Dengan demikian, hubungan antara aktivitas LMS dan data mata kuliah sudah sesuai berdasarkan atribut kode_mk.

## 10.3 Soal 37 — Pembayaran dengan NIM tidak terdaftar

**Tujuan pemeriksaan**  
Menghitung record yang NIM pada pembayaran tidak ditemukan pada tabel referensinya.

**Query SQL**

```sql
SELECT COUNT(*) AS orphan_payment_student
FROM src.pembayaran p
LEFT JOIN src.mahasiswa m ON p.nim = m.nim
WHERE m.nim IS NULL;
```

**Hasil eksekusi**

![Gambar 72. Soal 37 – Pembayaran dengan NIM tidak terdaftar](hasil%20unit.1.2/soal37.png)



**Interpretasi**

Hasil pemeriksaan menunjukkan tidak terdapat NIM pada tabel pembayaran yang tidak ditemukan di tabel mahasiswa. Artinya, seluruh transaksi pembayaran yang diperiksa dapat dihubungkan dengan data mahasiswa yang sesuai. Dengan demikian, relasi antara tabel pembayaran dan mahasiswa sudah terpenuhi berdasarkan atribut NIM.

## 10.4 Soal 38 — Kelulusan dengan NIM tidak terdaftar

**Tujuan pemeriksaan**  
Menghitung record yang NIM pada kelulusan tidak ditemukan pada tabel referensinya.

**Query SQL**

```sql
SELECT COUNT(*) AS orphan_graduation_student
FROM src.kelulusan k
LEFT JOIN src.mahasiswa m ON k.nim = m.nim
WHERE m.nim IS NULL;
```

**Hasil eksekusi**

![Gambar 73. Soal 38 – Kelulusan dengan NIM tidak terdaftar](hasil%20unit.1.2/soal38.png)



**Interpretasi**

Hasil query menunjukkan angka 0, sehingga tidak ditemukan NIM pada tabel kelulusan yang tidak terdaftar di tabel mahasiswa. Seluruh data kelulusan memiliki pasangan pada tabel induknya. Hal ini menunjukkan bahwa relasi antara tabel kelulusan dan mahasiswa sudah sesuai berdasarkan pemeriksaan atribut NIM.

---

---

# 11. Rekapitulasi Hasil Data Profiling dan Data Quality

| No. | Area Pemeriksaan | Indikator | Hasil | Status | Catatan Temuan |
|---:|---|---|---:|---|---|
| 1 | Dataset | Jumlah record setiap tabel | 10 tabel; terbesar `aktivitas_lms` 200.356 | Tidak ditemukan masalah | Tabel transaksi jauh lebih besar dari master/referensi |
| 2 | Dataset | Jumlah kolom setiap tabel | 5–11 kolom | Tidak ditemukan masalah | Struktur sesuai definisi source |
| 3 | Mahasiswa | Kelebihan record berdasarkan NIM | 15 | Perlu pemeriksaan | 1.965 baris vs 1.950 NIM unik; duplikat persis |
| 4 | Mahasiswa | Kelompok NIM duplikat | 15 | Perlu pemeriksaan | Masing-masing muncul 2 kali |
| 5 | Mahasiswa | Kota asal kosong | 30 (1,53%) | Perlu pemeriksaan | Sebaran wilayah tidak lengkap |
| 6 | Mahasiswa | Variasi label program studi | 30 label (6 resmi) | Perlu pemeriksaan | 24 label non-canonical; perlu mapping |
| 7 | Mahasiswa | Variasi label jenis kelamin | 6 label (2 konsep) | Perlu pemeriksaan | L, P, Laki-laki, Perempuan, M, F |
| 8 | Mahasiswa | Program studi tidak cocok dengan referensi | 435 (22,1%) | Perlu pemeriksaan | Singkatan, kapitalisasi, penulisan lain |
| 9 | Mahasiswa | Variasi format tanggal masuk | 3 format; OTHER 0 | Perlu pemeriksaan | 1.429 / 346 / 190 record |
| 10 | KRS | Kelebihan record berdasarkan KRS ID | 25 | Perlu pemeriksaan | 57.025 baris vs 57.000 `krs_id` unik |
| 11 | KRS | Duplikasi kombinasi NIM–MK–semester | 25 kombinasi | Perlu pemeriksaan | Identik penuh; muncul 2 kali |
| 12 | Nilai | Nilai angka kosong | 20 | Perlu pemeriksaan | `nilai_huruf` juga kosong pada baris yang sama |
| 13 | Nilai | Nilai angka di luar rentang | 12 | Perlu pemeriksaan | 6 negatif, 6 > 100 |
| 14 | Nilai | Statistik nilai valid | 56.968 valid; min 34,8; maks 100,0; rata-rata 77,40 | Tidak ditemukan masalah | Deskriptif; rentang valid 0–100 |
| 15 | Nilai | Ketidaksesuaian nilai angka dan huruf | 20 | Perlu pemeriksaan | Skala konversi pada soal |
| 16 | Nilai | Ketidaksesuaian nilai dan status lulus | 0 | Tidak ditemukan masalah | Berbasis nilai angka valid; pembanding huruf vs status = 17 |
| 17 | Nilai | Duplikasi kombinasi NIM–MK–semester | 0 | Tidak ditemukan masalah | Key unik |
| 18 | Referential integrity | NIM KRS tidak terdaftar | 0 | Tidak ditemukan masalah | Relasi aman |
| 19 | Referential integrity | NIM nilai tidak terdaftar | 0 | Tidak ditemukan masalah | Relasi aman |
| 20 | Referential integrity | Kode MK nilai tidak terdaftar | 0 | Tidak ditemukan masalah | Relasi aman |
| 21 | Referential integrity | Semester nilai tidak terdaftar | 0 | Tidak ditemukan masalah | Relasi aman |
| 22 | LMS | Kelebihan record berdasarkan event ID | 30 | Perlu pemeriksaan | 200.356 vs 200.326 unik; duplikat persis |
| 23 | LMS | Distribusi tipe aktivitas | 5 tipe | Tidak ditemukan masalah | Label bersih |
| 24 | LMS | Skor kuis kosong | 0 | Tidak ditemukan masalah | Seluruh `quiz_attempt` memiliki skor |
| 25 | LMS | Skor pada aktivitas non-kuis | 0 | Tidak ditemukan masalah | Sesuai rancangan |
| 26 | Pembayaran | Nominal pembayaran negatif | 5 | Perlu pemeriksaan | Semua berstatus Lunas |
| 27 | Pembayaran | Pembayaran positif tanpa tanggal | 12 | Perlu pemeriksaan | 10 Lunas + 2 Cicilan |
| 28 | Pembayaran | Distribusi status pembayaran | 3 status | Tidak ditemukan masalah | Lunas 7.962; Cicilan 1.077; Belum Lunas 461 |
| 29 | Kelulusan | Kelebihan record berdasarkan NIM | 2 | Perlu pemeriksaan | 347 baris vs 345 NIM unik |
| 30 | Kelulusan | Distribusi status tepat waktu | Ya = 347; kategori lain = 0 | Perlu pemeriksaan | Hanya satu kategori; perbandingan tepat vs terlambat belum bisa dilakukan |
| 31 | Relasi LMS | NIM aktivitas LMS tidak terdaftar | 0 | Tidak ditemukan masalah | Relasi aman |
| 32 | Relasi LMS | Kode MK aktivitas LMS tidak terdaftar | 0 | Tidak ditemukan masalah | Relasi aman |
| 33 | Relasi pembayaran | NIM pembayaran tidak terdaftar | 0 | Tidak ditemukan masalah | Relasi aman |
| 34 | Relasi kelulusan | NIM kelulusan tidak terdaftar | 0 | Tidak ditemukan masalah | Relasi aman |

---

**Catatan validasi:** angka pada tabel hasil dan interpretasi harus sama dengan keluaran query yang benar-benar dijalankan pada database praktikum. Jika hasil aktual berbeda, perbarui angka dan interpretasi terkait; jangan mempertahankan angka contoh.

# 12. Kesimpulan Praktikum

Berdasarkan pelaksanaan Praktikum Modul 1 Unit 1.2 tentang Data Profiling dan Data Quality Assessment, dapat disimpulkan bahwa dataset akademik UADW v1.0 memiliki struktur data yang saling berhubungan dan dapat diperiksa menggunakan PostgreSQL. Pemeriksaan dilakukan terhadap sepuluh tabel sumber dengan memperhatikan jumlah record, struktur kolom, keunikan data, kelengkapan, validitas, konsistensi, serta hubungan antar-tabel.

Hasil pemeriksaan menunjukkan bahwa masih terdapat beberapa permasalahan kualitas data. Permasalahan tersebut meliputi duplikasi record pada tabel mahasiswa, KRS, aktivitas LMS, dan kelulusan dengan total 72 baris berlebih. Selain itu, ditemukan data kota asal yang kosong, variasi penulisan program studi dan jenis kelamin, perbedaan format tanggal, serta beberapa nilai yang tidak memenuhi aturan validitas.

Tabel mahasiswa menjadi salah satu tabel yang memerlukan perhatian karena memiliki beberapa permasalahan sekaligus, terutama pada keunikan NIM, kelengkapan informasi, dan konsistensi penulisan atribut. Tabel nilai juga menunjukkan beberapa ketidaksesuaian, seperti nilai kosong, nilai di luar rentang 0–100, dan perbedaan antara nilai angka dengan nilai huruf. Pada tabel pembayaran ditemukan nominal negatif dan transaksi tanpa tanggal pembayaran yang perlu dikonfirmasi lebih lanjut.

Di sisi lain, pemeriksaan hubungan antar-tabel menunjukkan bahwa tidak ditemukan record yatim (*orphan records*) pada seluruh relasi yang diuji. Hal ini menunjukkan bahwa setiap data yang diperiksa memiliki pasangan pada tabel referensinya berdasarkan atribut penghubung yang digunakan.

Secara keseluruhan, praktikum ini berhasil memberikan gambaran mengenai kondisi dan kualitas dataset akademik sebelum memasuki tahap pengolahan berikutnya. Seluruh temuan digunakan sebagai bahan evaluasi dan belum dilakukan perubahan terhadap data sumber. Dengan demikian, hasil profiling dapat dijadikan dasar untuk menentukan proses pemeriksaan, perbaikan, dan pengolahan data pada tahap selanjutnya.

## 12.1 Temuan Utama

Berdasarkan hasil Data Profiling dan Data Quality Assessment, diperoleh beberapa temuan penting sebagai berikut.

1. **Duplikasi data pada beberapa tabel.** Ditemukan kelebihan 72 record yang terindikasi sebagai duplikasi identik, terdiri dari 15 record pada tabel mahasiswa, 25 pada KRS, 30 pada aktivitas LMS, dan 2 pada kelulusan. Kondisi ini dapat menyebabkan perhitungan jumlah data menjadi tidak akurat apabila tidak diperhatikan dalam proses analisis.

2. **Ketidaklengkapan dan ketidakkonsistenan data mahasiswa.** Terdapat 30 record mahasiswa yang tidak memiliki informasi kota asal. Selain itu, ditemukan 30 variasi penulisan program studi yang memengaruhi 435 record dan enam variasi penulisan jenis kelamin yang ditemukan pada 437 record. Kondisi ini menunjukkan bahwa beberapa atribut mahasiswa belum memiliki format penulisan yang seragam.

3. **Perbedaan format dan kode data.** Kolom tanggal masuk mahasiswa menggunakan tiga format penulisan, yaitu `YYYY-MM-DD`, `DD/MM/YYYY`, dan `DD-Mon-YYYY`. Selain itu, ditemukan variasi penulisan kode program studi dan status mahasiswa yang berpotensi menyebabkan kesalahan pengelompokan apabila tidak disesuaikan dengan referensi resmi.

4. **Permasalahan validitas dan konsistensi nilai akademik.** Pada tabel nilai ditemukan 20 record dengan nilai angka kosong, 12 record dengan nilai di luar rentang 0–100, serta 20 record yang tidak sesuai antara nilai angka dan nilai huruf berdasarkan aturan konversi yang digunakan. Sementara itu, pemeriksaan nilai angka terhadap status kelulusan tidak menemukan ketidaksesuaian.

5. **Ketidaksesuaian pada data pembayaran.** Ditemukan lima transaksi dengan nominal pembayaran negatif dan 12 transaksi pembayaran positif tanpa tanggal pembayaran. Kondisi ini perlu diperiksa untuk memastikan kesesuaian informasi transaksi dengan catatan pembayaran yang sebenarnya.

6. **Integritas hubungan antar-tabel terpenuhi pada relasi yang diuji.** Seluruh pemeriksaan referential integrity menghasilkan nol record yatim. Artinya, data pada tabel KRS, nilai, aktivitas LMS, pembayaran, dan kelulusan dapat ditemukan pada tabel referensi masing-masing berdasarkan atribut yang diperiksa.

7. **Data kelulusan belum memberikan gambaran perbandingan ketepatan waktu.** Seluruh 347 record kelulusan tercatat berstatus tepat waktu, dengan 345 mahasiswa unik setelah memperhitungkan duplikasi. Karena tidak ditemukan kategori terlambat, diperlukan pemeriksaan tambahan untuk memastikan apakah data tersebut memang belum tersedia atau belum tercatat.

## 12.2 Rekomendasi Pemeriksaan Lanjutan

Berdasarkan temuan yang diperoleh, terdapat beberapa pemeriksaan lanjutan yang disarankan sebelum dilakukan proses data cleaning, standardisasi, maupun deduplikasi.

1. **Memeriksa kembali data duplikat.** Melakukan peninjauan terhadap record yang terindikasi duplikat pada tabel mahasiswa, KRS, aktivitas LMS, dan kelulusan. Pemeriksaan dilakukan dengan membandingkan seluruh atribut untuk memastikan bahwa data tersebut benar-benar merupakan duplikasi dan bukan pencatatan yang memiliki tujuan berbeda.

2. **Memvalidasi kelengkapan data.** Menelusuri penyebab kosongnya informasi kota asal mahasiswa, nilai akademik, dan tanggal pembayaran. Apabila memungkinkan, lakukan pencocokan dengan dokumen atau sumber data resmi agar informasi yang belum lengkap dapat dikonfirmasi.

3. **Menyusun standar penulisan atribut.** Menentukan format yang seragam untuk nama program studi, jenis kelamin, status mahasiswa, kode program studi, dan tanggal. Tabel referensi program studi dapat digunakan sebagai acuan dalam proses pemetaan variasi nama dan kode.

4. **Memeriksa kembali validitas data akademik dan keuangan.** Melakukan verifikasi terhadap nilai angka di luar rentang 0–100, ketidaksesuaian nilai angka dengan nilai huruf, serta transaksi pembayaran bernominal negatif. Pemeriksaan harus disesuaikan dengan aturan penilaian akademik dan ketentuan pencatatan keuangan yang berlaku.

5. **Melakukan pemeriksaan lanjutan terhadap data kelulusan.** Memastikan apakah seluruh mahasiswa yang tercatat lulus tepat waktu memang sesuai dengan kondisi sebenarnya. Data mahasiswa yang belum lulus atau memiliki masa studi lebih lama perlu diperiksa agar analisis ketepatan waktu kelulusan dapat memberikan gambaran yang lebih lengkap.

6. **Menyiapkan proses pengolahan pada tahap berikutnya.** Setelah seluruh temuan dikonfirmasi, hasil pemeriksaan dapat dijadikan dasar untuk menyusun aturan cleaning, standardisasi, dan deduplikasi pada salinan data atau staging layer. Data asli pada source layer tetap dipertahankan agar dapat digunakan sebagai sumber pembanding dan dokumentasi.

Dengan melakukan pemeriksaan tersebut, proses pengolahan data selanjutnya diharapkan dapat menghasilkan dataset yang lebih lengkap, konsisten, valid, dan siap digunakan untuk kebutuhan analisis maupun pembangunan data warehouse.