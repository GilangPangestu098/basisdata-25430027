-- p05_ddl_25430027.sql
-- Milestone Proyek 5: struktur 6 tabel Klinik Gigi Sehat Ceria GP
-- sesuai skema relasional akhir (p04_normalisasi_25430027.md, bagian 7).
-- Disusun oleh: Gilang Pangestu (NIM 25430027), Kelas A.
-- Kode AB merujuk ke p02_kebutuhan_data_25430027.md.
-- Skrip dapat dijalankan ulang dari basis data kosong.

USE klinik_027;

-- Hapus tabel lama dari anak ke induk, agar tidak tertahan kunci tamu
DROP TABLE IF EXISTS pembayaran;
DROP TABLE IF EXISTS detail_kunjungan;
DROP TABLE IF EXISTS kunjungan;
DROP TABLE IF EXISTS layanan_tindakan;
DROP TABLE IF EXISTS dokter_gigi;
DROP TABLE IF EXISTS pasien;

-- ===== Tabel induk (master) =====
-- AB-20: pasien dan dokter gigi boleh dicatat walaupun belum memiliki kunjungan

CREATE TABLE pasien (
  id_pasien             INT          NOT NULL AUTO_INCREMENT,
  no_pasien             VARCHAR(12)  NOT NULL,          -- nomor pasien, dipakai di Lembar Kunjungan
  nama_pasien           VARCHAR(100) NOT NULL,
  tanggal_lahir_pasien  DATE         NOT NULL,
  jenis_kelamin_pasien  ENUM('L','P') NOT NULL,
  no_hp_pasien          VARCHAR(15)  NULL,              -- data pribadi (UU PDP)
  alamat_pasien         VARCHAR(200) NULL,              -- data pribadi (UU PDP)
  CONSTRAINT pk_pasien PRIMARY KEY (id_pasien),
  CONSTRAINT uq_pasien_no UNIQUE (no_pasien)            -- AB-12: nomor pasien unik
) ENGINE=InnoDB;

CREATE TABLE dokter_gigi (
  id_dokter_gigi    SMALLINT     NOT NULL AUTO_INCREMENT,
  kode_dokter_gigi  CHAR(7)      NOT NULL,              -- mis. DOK-003
  nama_dokter_gigi  VARCHAR(100) NOT NULL,
  CONSTRAINT pk_dokter_gigi PRIMARY KEY (id_dokter_gigi),
  CONSTRAINT uq_dokter_gigi_kode UNIQUE (kode_dokter_gigi)  -- kamus data: kode DOK-NNN unik
) ENGINE=InnoDB;

CREATE TABLE layanan_tindakan (
  id_layanan_tindakan     SMALLINT      NOT NULL AUTO_INCREMENT,
  kode_layanan_tindakan   CHAR(6)       NOT NULL,       -- mis. LY-001
  nama_layanan_tindakan   VARCHAR(100)  NOT NULL,
  tarif_layanan_tindakan  DECIMAL(12,2) NOT NULL,       -- tarif master yang berlaku saat ini
  CONSTRAINT pk_layanan_tindakan PRIMARY KEY (id_layanan_tindakan),
  CONSTRAINT uq_layanan_tindakan_kode UNIQUE (kode_layanan_tindakan),  -- kamus data: kode LY-NNN unik
  CONSTRAINT ck_layanan_tindakan_tarif CHECK (tarif_layanan_tindakan >= 0)
) ENGINE=InnoDB;

-- ===== Tabel transaksi (berkunci tamu) =====

CREATE TABLE kunjungan (
  id_kunjungan                      INT           NOT NULL AUTO_INCREMENT,
  no_kunjungan                      CHAR(13)      NOT NULL,  -- mis. KJG-2026-0001
  tanggal_kunjungan                 DATE          NOT NULL,
  waktu_kunjungan                   TIME          NOT NULL,
  id_pasien                         INT           NOT NULL,  -- AB-20: tepat satu pasien
  id_dokter_gigi                    SMALLINT      NOT NULL,  -- AB-20: tepat satu dokter gigi
  keluhan_kunjungan                 VARCHAR(255)  NOT NULL,
  diagnosis_kunjungan               VARCHAR(255)  NULL,      -- diisi dokter setelah pemeriksaan
  gigi_yang_ditangani_kunjungan     VARCHAR(50)   NULL,
  batas_waktu_pembayaran_kunjungan  DATE          NOT NULL,  -- AB-04: tanggal + 7 hari, disimpan sebagai potret
  denda_keterlambatan_kunjungan     DECIMAL(12,2) NULL,      -- AB-11: denda final saat Lunas; NULL bila belum/kembali Belum Lunas (AB-17)
  status_kunjungan                  ENUM('Berjalan','Selesai') NOT NULL DEFAULT 'Berjalan',  -- AB-14, AB-15
  CONSTRAINT pk_kunjungan PRIMARY KEY (id_kunjungan),
  CONSTRAINT uq_kunjungan_no UNIQUE (no_kunjungan),         -- AB-01: nomor kunjungan unik
  CONSTRAINT fk_kunjungan_pasien FOREIGN KEY (id_pasien)
    REFERENCES pasien (id_pasien),                          -- pasien yang punya riwayat kunjungan tidak boleh dihapus
  CONSTRAINT fk_kunjungan_dokter_gigi FOREIGN KEY (id_dokter_gigi)
    REFERENCES dokter_gigi (id_dokter_gigi),                -- dokter yang punya riwayat kunjungan tidak boleh dihapus
  CONSTRAINT ck_kunjungan_batas CHECK (batas_waktu_pembayaran_kunjungan >= tanggal_kunjungan),  -- AB-04
  CONSTRAINT ck_kunjungan_denda CHECK (denda_keterlambatan_kunjungan IS NULL
                                       OR denda_keterlambatan_kunjungan >= 0)  -- AB-05, AB-11
  -- Nilai turunan (subtotal, total layanan, keterlambatan, total tagihan, status pembayaran)
  -- sengaja tidak disimpan; dihitung dari detail dan pembayaran (AB-05 s.d. AB-07)
) ENGINE=InnoDB;

CREATE TABLE detail_kunjungan (
  id_kunjungan                          INT           NOT NULL,
  id_layanan_tindakan                   SMALLINT      NOT NULL,
  tarif_saat_kunjungan_detail_kunjungan DECIMAL(12,2) NOT NULL,  -- AB-03: tarif saat kunjungan, tidak ikut tarif master
  jumlah_detail_kunjungan               SMALLINT      NOT NULL DEFAULT 1,  -- AB-02: jumlah unit per baris
  CONSTRAINT pk_detail_kunjungan PRIMARY KEY (id_kunjungan, id_layanan_tindakan),
  CONSTRAINT fk_detail_kunjungan_kunjungan FOREIGN KEY (id_kunjungan)
    REFERENCES kunjungan (id_kunjungan) ON DELETE CASCADE,  -- kunjungan dihapus, rinciannya ikut terhapus
  CONSTRAINT fk_detail_kunjungan_layanan_tindakan FOREIGN KEY (id_layanan_tindakan)
    REFERENCES layanan_tindakan (id_layanan_tindakan),      -- layanan yang pernah dipakai tidak boleh dihapus
  CONSTRAINT ck_detail_kunjungan_jumlah CHECK (jumlah_detail_kunjungan > 0),                   -- AB-02
  CONSTRAINT ck_detail_kunjungan_tarif  CHECK (tarif_saat_kunjungan_detail_kunjungan >= 0)     -- AB-03
  -- AB-02 (maksimal 3 baris layanan per kunjungan, aturan batas P + 2) menyangkut jumlah baris
  -- per transaksi, sehingga tidak dapat dijaga CHECK; diselesaikan dengan transaksi di Modul 14.
  -- AB-15 (detail terkunci setelah kunjungan Selesai) juga melibatkan tabel lain; ditandai untuk Modul 14.
) ENGINE=InnoDB;

CREATE TABLE pembayaran (
  id_pembayaran              INT           NOT NULL AUTO_INCREMENT,
  no_pembayaran              VARCHAR(15)   NOT NULL,
  id_kunjungan               INT           NOT NULL,      -- AB-09: tepat satu kunjungan; AB-08: satu kunjungan boleh banyak pembayaran
  tanggal_pembayaran         DATE          NOT NULL,
  jumlah_dibayar_pembayaran  DECIMAL(12,2) NOT NULL,
  keterangan_pembayaran      VARCHAR(100)  NULL,
  CONSTRAINT pk_pembayaran PRIMARY KEY (id_pembayaran),
  CONSTRAINT uq_pembayaran_no UNIQUE (no_pembayaran),     -- AB-09: nomor pembayaran unik
  CONSTRAINT fk_pembayaran_kunjungan FOREIGN KEY (id_kunjungan)
    REFERENCES kunjungan (id_kunjungan),                  -- kunjungan yang sudah dibayar tidak boleh dihapus (bukti keuangan)
  CONSTRAINT ck_pembayaran_jumlah CHECK (jumlah_dibayar_pembayaran > 0)
  -- AB-07 (Lunas bila pembayaran kumulatif >= total tagihan) dan koreksi pembayaran (AB-16, AB-17)
  -- melibatkan banyak baris dan tabel, sehingga dihitung saat kueri, bukan dijaga CHECK.
) ENGINE=InnoDB;