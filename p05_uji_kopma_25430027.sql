-- p05_uji_kopma_25430027.sql
-- Blok perintah untuk tangkapan layar Kopma Modul 5, nomor 1 sampai 11.
-- Disusun oleh: Gilang Pangestu (NIM 25430027), Kelas A.
-- Cara pakai: masuk sebagai mhs_027, lalu salin dan jalankan SATU BLOK setiap kali,
-- ambil tangkapan layar, baru lanjut ke blok berikutnya.
-- Lokasi repo: D:/praktikum/basisdata-25430027 (memakai garis miring "/").
-- Blok 3, 4, 5, 9, dan 10 SENGAJA menghasilkan galat; galat itulah buktinya.

-- ==========================================================
-- [1] p05_kopma_show_tables.png  (akhir langkah D.2)
-- ==========================================================
SELECT CURRENT_USER(), NOW();
SOURCE D:/praktikum/basisdata-25430027/p05_ddl_kopma_25430027.sql
SHOW TABLES;

-- ==========================================================
-- [2] p05_kopma_show_create_penjualan.png  (langkah D.2)
--     lalu p05_kopma_show_create_detail_penjualan.png
-- ==========================================================
SELECT CURRENT_USER(), NOW();
SHOW CREATE TABLE penjualan\G
SHOW CREATE TABLE detail_penjualan\G

-- ==========================================================
-- Persiapan langkah D.3 (tidak perlu difoto): data induk secukupnya
-- ==========================================================
INSERT INTO petugas (kode_petugas, nama_petugas, peran_petugas) VALUES
  ('K01', 'Rina Aprilia', 'kasir'),
  ('K03', 'Dimas Saputra', 'gudang');
INSERT INTO barang (kode_barang, nama_barang, kategori_barang, harga_jual_barang, stok_barang) VALUES
  ('ATK-001', 'Pulpen', 'ATK', 4000, 50),
  ('MKN-001', 'Roti cokelat', 'makanan', 5000, 20);
SELECT * FROM petugas;
SELECT * FROM barang;

-- ==========================================================
-- [3] p05_kopma_galat1452_fk.png  (langkah D.3)
--     Harapan: ERROR 1452 ... a foreign key constraint fails (fk_penjualan_petugas)
-- ==========================================================
SELECT CURRENT_USER(), NOW();
INSERT INTO penjualan (no_nota_penjualan, tgl_penjualan, id_petugas, id_anggota, bayar_penjualan)
VALUES ('PJ-2609-0199', NOW(), 99, NULL, 5000);   -- petugas 99 tidak ada

-- ==========================================================
-- [4] p05_kopma_galat4025_check.png  (langkah D.3)
--     Harapan: ERROR 4025 ... CONSTRAINT `ck_barang_stok` failed
-- ==========================================================
SELECT CURRENT_USER(), NOW();
UPDATE barang SET stok_barang = -1 WHERE id_barang = 1;   -- melanggar AB-03

-- ==========================================================
-- [5] p05_kopma_galat1062_unique.png  (langkah D.3)
--     Harapan: ERROR 1062 Duplicate entry 'ATK-001' for key 'uq_barang_kode'
-- ==========================================================
SELECT CURRENT_USER(), NOW();
INSERT INTO barang (kode_barang, nama_barang, kategori_barang, harga_jual_barang)
VALUES ('ATK-001', 'Duplikat', 'ATK', 1000);   -- kode kembar

-- ==========================================================
-- [6] p05_kopma_alter_kedaluwarsa.png  (langkah D.4)
-- ==========================================================
SELECT CURRENT_USER(), NOW();
ALTER TABLE barang ADD COLUMN tgl_kedaluwarsa DATE NULL AFTER stok_min_barang;
DESCRIBE barang;
ALTER TABLE barang DROP COLUMN tgl_kedaluwarsa;   -- dibatalkan setelah dicoba
DESCRIBE barang;

-- ==========================================================
-- [7] p05_kopma_designer.png  (langkah D.4)
--     Tidak ada perintah SQL. Buka phpMyAdmin, login sebagai mhs_027,
--     pilih kopma_027 > menu Designer (di tab "Lainnya"/"More").
--     Susun 8 tabel agar mirip ERD Pertemuan 3, lalu ambil tangkapan layar
--     dengan nama akun di pojok phpMyAdmin dan jam sistem terlihat.
-- ==========================================================

-- ==========================================================
-- [8] p05_kopma_jalan_ulang.png  (langkah D.4)
--     Harapan: semua "Query OK", tidak ada ERROR 1050 Table already exists
-- ==========================================================
SELECT CURRENT_USER(), NOW();
SOURCE D:/praktikum/basisdata-25430027/p05_ddl_kopma_25430027.sql
SHOW TABLES;

-- ==========================================================
-- [9] p05_ta3_drop_terbalik.png  (Titik Analisis 3)
--     Harapan: ERROR 1451 Cannot delete or update a parent row:
--     a foreign key constraint fails. Tabel petugas TIDAK terhapus.
-- ==========================================================
SELECT CURRENT_USER(), NOW();
DROP TABLE petugas;   -- urutan salah: induk dihapus sebelum anak (penjualan)
SHOW TABLES;          -- petugas masih ada

-- ==========================================================
-- [10] p05_latihan_e1_ck_stokmin.png  (Latihan E.1)
--      Harapan: ERROR 4025 ... CONSTRAINT `ck_barang_stok_min` failed
-- ==========================================================
SELECT CURRENT_USER(), NOW();
ALTER TABLE barang
  ADD CONSTRAINT ck_barang_stok_min CHECK (stok_min_barang >= 0);
INSERT INTO barang (kode_barang, nama_barang, kategori_barang, harga_jual_barang, stok_min_barang)
VALUES ('ATK-002', 'Penggaris', 'ATK', 3000, -1);   -- batas minimum negatif

-- ==========================================================
-- [11] p05_latihan_e2_setnull.png  (Latihan E.2)
-- ==========================================================
SELECT CURRENT_USER(), NOW();
ALTER TABLE penjualan DROP FOREIGN KEY fk_penjualan_anggota;
ALTER TABLE penjualan
  ADD CONSTRAINT fk_penjualan_anggota FOREIGN KEY (id_anggota)
  REFERENCES anggota (id_anggota) ON DELETE SET NULL;
SHOW CREATE TABLE penjualan\G

-- Bukti tambahan (boleh ikut difoto): anggota dihapus, nota tetap ada dengan id_anggota NULL
INSERT INTO petugas (kode_petugas, nama_petugas, peran_petugas) VALUES ('K01', 'Rina Aprilia', 'kasir');
INSERT INTO anggota (no_anggota, nim_anggota, nama_anggota, prodi_anggota, tgl_daftar_anggota)
VALUES ('A-0457', '2543000099', 'Budi Santoso', 'Ilmu Komputer', '2026-09-01');
INSERT INTO penjualan (no_nota_penjualan, tgl_penjualan, id_petugas, id_anggota, bayar_penjualan)
VALUES ('PJ-2609-0142', NOW(), 1, 1, 30000);
DELETE FROM anggota WHERE no_anggota = 'A-0457';
SELECT no_nota_penjualan, id_anggota FROM penjualan;

-- ==========================================================
-- Penutup (tidak perlu difoto): kembalikan struktur ke versi final modul
-- ==========================================================
SOURCE D:/praktikum/basisdata-25430027/p05_ddl_kopma_25430027.sql