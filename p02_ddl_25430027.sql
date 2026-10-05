-- Mengaktifkan database proyek
USE klinik_027;

-- 1. Membuat Tabel Pasien (Tabel Induk)
CREATE TABLE pasien_027 (
    id_pasien INT AUTO_INCREMENT PRIMARY KEY,
    nama_pasien VARCHAR(100) NOT NULL,
    tgl_lahir DATE NOT NULL,
    alamat TEXT,
    no_hp VARCHAR(15) UNIQUE NOT NULL
);

-- 2. Membuat Tabel Dokter (Tabel Induk)
CREATE TABLE dokter_027 (
    id_dokter INT AUTO_INCREMENT PRIMARY KEY,
    nama_dokter VARCHAR(100) NOT NULL,
    spesialisasi VARCHAR(50) NOT NULL,
    no_hp VARCHAR(15) NOT NULL
);

-- 3. Membuat Tabel Obat (Tabel Induk)
CREATE TABLE obat_027 (
    id_obat INT AUTO_INCREMENT PRIMARY KEY,
    nama_obat VARCHAR(100) NOT NULL,
    stok INT NOT NULL DEFAULT 0,
    harga DECIMAL(10,2) NOT NULL
);

-- 4. Membuat Tabel Rekam Medis (Tabel Relasi/Transaksi)
CREATE TABLE rekam_medis_027 (
    id_rekam INT AUTO_INCREMENT PRIMARY KEY,
    id_pasien INT,
    id_dokter INT,
    tgl_periksa DATETIME NOT NULL,
    keluhan TEXT NOT NULL,
    diagnosa TEXT NOT NULL,
    FOREIGN KEY (id_pasien) REFERENCES pasien_027(id_pasien) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_dokter) REFERENCES dokter_027(id_dokter) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. Latihan Modifikasi Tabel (ALTER TABLE)
ALTER TABLE dokter_027 ADD COLUMN jadwal_praktik VARCHAR(50) AFTER spesialisasi;