# Dokumen Kebutuhan Data - Koperasi Mahasiswa Sejahtera (Kopma)

Disusun oleh: Gilang Pangestu (NIM 25430027), Kelas A. Dokumen ini adalah contoh dari modul Pertemuan 2 (studi kasus Kopma). Dokumen untuk proyek pribadi (tema Klinik) dibuat terpisah.

## 1. Latar belakang dan aktivitas organisasi

Koperasi Mahasiswa Sejahtera (Kopma) adalah koperasi fiktif yang menjual alat tulis, makanan ringan, dan minuman di lingkungan kampus. Pembelinya dapat berupa anggota atau umum. Mahasiswa yang ingin menjadi anggota mendaftar dengan menyerahkan NIM, nama, program studi, dan nomor HP, lalu memperoleh nomor anggota berformat A-xxxx. Anggota yang berstatus aktif mendapat diskon 5% untuk setiap nota.

Tiga kasir bekerja bergantian per sif untuk mencatat penjualan dan mencetak nota. Setiap sore, petugas gudang memeriksa stok. Bila stok suatu barang berada di bawah batas minimum, petugas membuat pesanan pembelian ke pemasok. Ketika barang datang, stok bertambah sesuai faktur pemasok. Setiap awal bulan, ketua koperasi menerima laporan omzet, barang terlaris, barang dengan stok menipis, dan anggota paling aktif.

Dari wawancara, ada tiga masalah yang menunjukkan kebutuhan data: harga barang sering naik sehingga nota lama membingungkan, stok di buku catatan kadang bernilai minus, dan anggota sering lupa membawa kartu sehingga harus dicari lewat NIM.

## 2. Aktor dan proses bisnis

| Kode | Proses bisnis | Aktor | Pemicu |
|------|---------------|-------|--------|
| PB-01 | Mendaftarkan anggota | Kasir (atas permintaan mahasiswa) | Mahasiswa ingin menjadi anggota |
| PB-02 | Mencatat penjualan | Kasir | Pembeli membayar di kasir |
| PB-03 | Memesan barang ke pemasok | Petugas gudang | Stok di bawah batas minimum |
| PB-04 | Menerima barang dari pemasok | Petugas gudang | Barang datang bersama faktur |
| PB-05 | Menyusun laporan bulanan | Ketua koperasi | Awal bulan |

## 3. Dokumen sumber yang dianalisis

Dokumen sumber: nota penjualan Kopma (Gambar 2.5 di buku modul), dengan contoh nomor nota PJ-2609-0142.

| Elemen data | Disimpan atau turunan | Catatan |
|-------------|-----------------------|---------|
| Nomor nota | Disimpan | Identitas transaksi; harus unik (AB-01) |
| Tanggal dan jam | Disimpan | Identitas transaksi |
| Kasir (kode dan nama) | Disimpan sebagai relasi ke petugas | Yang dicatat kode petugasnya; nama diambil dari data petugas |
| Anggota (nomor dan nama) | Disimpan sebagai relasi ke anggota, opsional | Penjualan boleh tanpa anggota (AB-02) |
| Nama barang | Disimpan sebagai relasi ke barang | Diambil dari data barang |
| Qty | Disimpan | Jumlah barang pada tiap baris nota |
| Harga satuan | Disimpan (harga saat transaksi) | Tidak berubah meski harga barang kemudian naik (AB-04) |
| Subtotal per baris | Turunan | Dihitung dari qty dikali harga |
| Jumlah | Turunan | Penjumlahan semua subtotal |
| Diskon anggota | Turunan | Nilainya (Rp1.450 pada contoh) dihitung dari persentase 5% atas jumlah; persentasenya berasal dari aturan AB-02 |
| Total | Turunan | Jumlah dikurangi diskon |
| Bayar tunai | Disimpan | Data pembayaran |
| Kembali | Turunan | Bayar tunai dikurangi total |

Dari 13 isian pada nota, 8 disimpan (termasuk tiga relasi ke petugas, anggota, dan barang) dan 5 adalah nilai turunan.

## 4. Entitas kandidat dan elemen data

| Entitas kandidat | Elemen data utama | Sumber |
|------------------|-------------------|--------|
| Anggota | nomor anggota, NIM, nama, program studi, nomor HP, status aktif | Formulir pendaftaran |
| Barang | kode, nama, kategori, harga jual, stok, batas minimum stok | Daftar barang, faktur |
| Penjualan | nomor nota, tanggal-jam, kasir, anggota (opsional), bayar | Nota penjualan |
| Detail penjualan | nomor nota, barang, qty, harga saat transaksi | Nota penjualan |
| Petugas | kode petugas, nama, peran (kasir/gudang/ketua) | Wawancara |
| Pemasok | kode, nama, telepon, alamat | Faktur pemasok |
| Pembelian dan detailnya | nomor faktur, tanggal, pemasok, barang, qty, harga beli | Faktur pemasok |

## 5. Aturan bisnis

| Kode | Aturan bisnis |
|------|---------------|
| AB-01 | Setiap nota memiliki nomor unik dan minimal satu baris barang. |
| AB-02 | Penjualan boleh tanpa anggota (pembeli umum); jika ada, anggota harus berstatus aktif untuk memperoleh diskon 5%. |
| AB-03 | Stok barang tidak boleh negatif; penjualan ditolak bila qty melebihi stok tersedia. |
| AB-04 | Harga jual yang dipakai pada nota disimpan per baris dan tidak berubah meski harga barang kemudian naik. |
| AB-05 | NIM anggota unik; pencarian anggota dapat dilakukan lewat nomor anggota atau NIM. |
| AB-06 | Pesanan pembelian dibuat bila stok kurang dari batas minimum barang tersebut. |

## 6. Kebutuhan informasi

| Kode | Kebutuhan informasi | Data yang diperlukan |
|------|---------------------|----------------------|
| KI-01 | Omzet dan jumlah nota per hari dan per bulan | Penjualan, detail penjualan |
| KI-02 | Lima barang terlaris per bulan berdasarkan qty | Detail penjualan, barang |
| KI-03 | Barang dengan stok di bawah batas minimum | Barang |
| KI-04 | Sepuluh anggota dengan belanja terbesar per bulan | Penjualan, detail penjualan, anggota |

## 7. Matriks CRUD

Keterangan: C = create (membuat), R = read (membaca), U = update (mengubah), D = delete (menghapus).

| Proses | Anggota | Barang | Penjualan | Detail | Pemasok | Pembelian |
|--------|---------|--------|-----------|--------|---------|-----------|
| PB-01 Daftar anggota | C | | | | | |
| PB-02 Catat penjualan | R | R, U | C | C | | |
| PB-03 Pesan ke pemasok | | R | | | R | C |
| PB-04 Terima barang | | U | | | R | U |
| PB-05 Laporan bulanan | R | R | R | R | | R |

Catatan: pada kolom Pemasok belum ada proses yang memberi huruf C. Hal ini dibahas pada Titik Analisis 3.

## 8. Kamus data awal

Cuplikan kamus data awal Kopma. Kolom penanggung jawab menunjukkan siapa yang bertanggung jawab atas kebenaran data tersebut.

| Elemen | Arti | Contoh | Aturan | Penanggung jawab |
|--------|------|--------|--------|------------------|
| `no_anggota` | Nomor anggota koperasi | A-0457 | Unik, format A-4 digit | Ketua |
| `nim_anggota` | NIM anggota | 2301010123 | Unik, 10 digit | Ketua |
| `no_hp_anggota` | Nomor HP anggota | 0812xxxx | Data pribadi, akses terbatas | Ketua |
| `no_nota_penjualan` | Nomor nota penjualan | PJ-2609-0142 | Unik per nota | Kasir |
| `harga_satuan_detail_penjualan` | Harga jual saat transaksi | 4000 | Bilangan bulat >= 0 (rupiah) | Kasir |
| `stok_barang` | Jumlah barang tersedia | 35 | Bilangan bulat >= 0 (AB-03) | Petugas gudang |

## 9. Kebutuhan non-fungsional data

- **Volume:** perkiraan sekitar 150 nota per hari.
- **Retensi:** data transaksi disimpan minimal lima tahun.
- **Privasi:** nomor HP anggota hanya boleh dilihat oleh ketua. Pembatasan akses data pribadi seperti ini sejalan dengan kewajiban pengendali data dalam Undang-Undang Pelindungan Data Pribadi.

## 10. Isu kualitas data yang diantisipasi

| Isu | Asal | Cara mengantisipasi |
|-----|------|---------------------|
| Harga pada nota lama berubah mengikuti harga barang terbaru | Keluhan ketua koperasi | Harga saat transaksi disimpan per baris nota (AB-04) |
| Stok bernilai minus di buku catatan | Keluhan petugas gudang | Stok tidak boleh negatif; penjualan ditolak bila qty melebihi stok (AB-03) |
| Anggota sulit dicari saat lupa membawa kartu | Keluhan kasir | Pencarian lewat nomor anggota atau NIM, dan NIM bersifat unik (AB-05) |
| Nomor nota ganda | Kebutuhan identitas transaksi | Nomor nota unik dan setiap nota minimal satu baris barang (AB-01) |
