-- p05_ddl_kopma_25430027.sql
-- Struktur 8 tabel Kopma sesuai skema kanonik (Modul 4, Tabel 4.2; Lampiran C).
-- Disusun oleh: Gilang Pangestu (NIM 25430027), Kelas A.
-- Kode AB merujuk ke p02_kebutuhan_data_kopma_25430027.md.
-- Skrip dapat dijalankan ulang dari basis data kosong.

USE kopma_027;

-- Hapus tabel lama dari anak ke induk, agar tidak tertahan kunci tamu
DROP TABLE IF EXISTS detail_pembelian;
DROP TABLE IF EXISTS detail_penjualan;
DROP TABLE IF EXISTS pembelian;
DROP TABLE IF EXISTS penjualan;
DROP TABLE IF EXISTS pemasok;
DROP TABLE IF EXISTS barang;
DROP TABLE IF EXISTS anggota;
DROP TABLE IF EXISTS petugas;

-- ===== Tabel induk (master) =====

CREATE TABLE petugas (
  id_petugas      SMALLINT     NOT NULL AUTO_INCREMENT,
  kode_petugas    CHAR(3)      NOT NULL,              -- mis. K03, tercetak di nota
  nama_petugas    VARCHAR(100) NOT NULL,
  peran_petugas   ENUM('kasir','gudang','ketua') NOT NULL,
  CONSTRAINT pk_petugas PRIMARY KEY (id_petugas),
  CONSTRAINT uq_petugas_kode UNIQUE (kode_petugas)
) ENGINE=InnoDB;

CREATE TABLE anggota (
  id_anggota          INT          NOT NULL AUTO_INCREMENT,
  no_anggota          CHAR(6)      NOT NULL,          -- mis. A-0457
  nim_anggota         CHAR(10)     NOT NULL,
  nama_anggota        VARCHAR(100) NOT NULL,
  prodi_anggota       VARCHAR(60)  NOT NULL,
  no_hp_anggota       VARCHAR(15)  NULL,              -- data pribadi (UU PDP)
  status_anggota      ENUM('aktif','nonaktif') NOT NULL DEFAULT 'aktif',  -- AB-02: hanya anggota aktif yang memperoleh diskon
  tgl_daftar_anggota  DATE         NOT NULL,
  CONSTRAINT pk_anggota PRIMARY KEY (id_anggota),
  CONSTRAINT uq_anggota_no  UNIQUE (no_anggota),      -- AB-05: pencarian lewat nomor anggota
  CONSTRAINT uq_anggota_nim UNIQUE (nim_anggota)      -- AB-05: NIM anggota unik
) ENGINE=InnoDB;

CREATE TABLE barang (
  id_barang          INT           NOT NULL AUTO_INCREMENT,
  kode_barang        VARCHAR(10)   NOT NULL,          -- mis. ATK-001
  nama_barang        VARCHAR(100)  NOT NULL,
  kategori_barang    ENUM('ATK','makanan','minuman') NOT NULL,
  harga_jual_barang  DECIMAL(12,2) NOT NULL,          -- harga yang berlaku saat ini
  stok_barang        INT           NOT NULL DEFAULT 0,
  stok_min_barang    INT           NOT NULL DEFAULT 5,  -- AB-06: batas pemicu pesanan pembelian
  CONSTRAINT pk_barang PRIMARY KEY (id_barang),
  CONSTRAINT uq_barang_kode UNIQUE (kode_barang),
  CONSTRAINT ck_barang_stok  CHECK (stok_barang >= 0),        -- AB-03: stok tidak boleh negatif
  CONSTRAINT ck_barang_harga CHECK (harga_jual_barang >= 0)
) ENGINE=InnoDB;

CREATE TABLE pemasok (
  id_pemasok       INT          NOT NULL AUTO_INCREMENT,
  nama_pemasok     VARCHAR(100) NOT NULL,
  telepon_pemasok  VARCHAR(15)  NULL,
  alamat_pemasok   VARCHAR(200) NULL,
  CONSTRAINT pk_pemasok PRIMARY KEY (id_pemasok)
) ENGINE=InnoDB;

-- ===== Tabel transaksi (berkunci tamu) =====

CREATE TABLE penjualan (
  id_penjualan       INT           NOT NULL AUTO_INCREMENT,
  no_nota_penjualan  CHAR(12)      NOT NULL,          -- mis. PJ-2609-0142
  tgl_penjualan      DATETIME      NOT NULL,          -- tanggal dan jam (KI-01 per hari)
  id_petugas         SMALLINT      NOT NULL,          -- setiap nota wajib punya kasir
  id_anggota         INT           NULL,              -- AB-02: NULL = pembeli umum
  bayar_penjualan    DECIMAL(12,2) NOT NULL,          -- uang yang diterima dari pembeli
  CONSTRAINT pk_penjualan PRIMARY KEY (id_penjualan),
  CONSTRAINT uq_penjualan_nota UNIQUE (no_nota_penjualan),    -- AB-01: nomor nota unik
  CONSTRAINT fk_penjualan_petugas FOREIGN KEY (id_petugas) REFERENCES petugas (id_petugas),
  CONSTRAINT fk_penjualan_anggota FOREIGN KEY (id_anggota) REFERENCES anggota (id_anggota),  -- AB-02
  CONSTRAINT ck_penjualan_bayar CHECK (bayar_penjualan >= 0)
) ENGINE=InnoDB;

CREATE TABLE detail_penjualan (
  id_penjualan                   INT           NOT NULL,
  id_barang                      INT           NOT NULL,
  qty_detail_penjualan           SMALLINT      NOT NULL,
  harga_satuan_detail_penjualan  DECIMAL(12,2) NOT NULL,  -- AB-04: harga saat transaksi, tidak ikut harga barang
  CONSTRAINT pk_detail_penjualan PRIMARY KEY (id_penjualan, id_barang),
  CONSTRAINT fk_detail_penjualan_penjualan FOREIGN KEY (id_penjualan)
    REFERENCES penjualan (id_penjualan) ON DELETE CASCADE,  -- nota dibatalkan, rinciannya ikut terhapus
  CONSTRAINT fk_detail_penjualan_barang FOREIGN KEY (id_barang)
    REFERENCES barang (id_barang),                          -- barang yang pernah terjual tidak boleh dihapus
  CONSTRAINT ck_detail_penjualan_qty   CHECK (qty_detail_penjualan > 0),
  CONSTRAINT ck_detail_penjualan_harga CHECK (harga_satuan_detail_penjualan >= 0)
  -- AB-01 (minimal satu baris barang per nota) tidak dapat dijaga constraint; diselesaikan dengan transaksi di Modul 14
) ENGINE=InnoDB;

CREATE TABLE pembelian (
  id_pembelian         INT         NOT NULL AUTO_INCREMENT,
  no_faktur_pembelian  VARCHAR(20) NOT NULL,          -- nomor dari pemasok; tidak unik antar-pemasok
  tgl_pembelian        DATE        NOT NULL,
  id_pemasok           INT         NOT NULL,
  status_pembelian     ENUM('dipesan','diterima') NOT NULL DEFAULT 'dipesan',  -- AB-06: dipesan saat stok < minimum
  CONSTRAINT pk_pembelian PRIMARY KEY (id_pembelian),
  CONSTRAINT fk_pembelian_pemasok FOREIGN KEY (id_pemasok) REFERENCES pemasok (id_pemasok)
) ENGINE=InnoDB;

CREATE TABLE detail_pembelian (
  id_pembelian                 INT           NOT NULL,
  id_barang                    INT           NOT NULL,
  qty_detail_pembelian         INT           NOT NULL,
  harga_beli_detail_pembelian  DECIMAL(12,2) NOT NULL,  -- harga modal per unit
  CONSTRAINT pk_detail_pembelian PRIMARY KEY (id_pembelian, id_barang),
  CONSTRAINT fk_detail_pembelian_pembelian FOREIGN KEY (id_pembelian)
    REFERENCES pembelian (id_pembelian) ON DELETE CASCADE,
  CONSTRAINT fk_detail_pembelian_barang FOREIGN KEY (id_barang)
    REFERENCES barang (id_barang),
  CONSTRAINT ck_detail_pembelian_qty   CHECK (qty_detail_pembelian > 0),
  CONSTRAINT ck_detail_pembelian_harga CHECK (harga_beli_detail_pembelian >= 0)
) ENGINE=InnoDB;