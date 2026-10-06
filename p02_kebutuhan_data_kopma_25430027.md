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
| PB-06 | Menukar poin pada penjualan | Kasir (atas pilihan anggota) | Anggota aktif dengan saldo minimal 50 poin memilih menukar poin saat membayar |

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
| Barang | kode_barang, nama_barang, kategori, harga jual, stok, batas minimum stok | Daftar barang, faktur |
| Penjualan | nomor nota, tanggal-jam, kasir, anggota (opsional), bayar | Nota penjualan |
| Detail penjualan | nomor nota, barang, qty, harga saat transaksi | Nota penjualan |
| Petugas | kode petugas, nama, peran (kasir/gudang/ketua) | Wawancara |
| Pemasok | kode, nama, telepon, alamat | Faktur pemasok |
| Pembelian dan detailnya | nomor faktur, tanggal, pemasok, barang, qty, harga beli | Faktur pemasok |

### Tambahan elemen data: poin loyalitas

| Elemen | Arti | Contoh | Aturan | Disimpan atau turunan |
|---|---|---|---|---|
| saldo_poin_anggota (Anggota) | Jumlah poin loyalitas anggota saat ini | 27 (saldo awal 75, dikurangi 50, ditambah 2) | Tidak boleh negatif; awal 0 (AB-13); bertambah setelah transaksi selesai (AB-08); berkurang saat penukaran (AB-10) | Disimpan |
| poin_diperoleh_penjualan (Penjualan) | Poin yang diperoleh anggota dari satu nota | 2 | Dari Jumlah, tiap Rp10.000 = 1 poin, sisa dibuang (AB-07); 0 untuk non-anggota atau anggota tidak aktif (AB-12) | Disimpan |
| poin_digunakan_penjualan (Penjualan) | Poin yang ditukarkan pada satu nota | 50 | Kelipatan 50 dan tidak melebihi saldo (AB-09, AB-10); 0 untuk non-anggota atau anggota tidak aktif (AB-12) | Disimpan |
| potongan_poin_penjualan (Penjualan) | Nilai potongan tambahan dari penukaran poin | Rp5.000 | 50 poin = Rp5.000; tidak boleh lebih besar dari Total (AB-10, AB-11) | Disimpan |
| tagihan_penjualan (Penjualan) | Nilai yang harus dibayar anggota setelah potongan poin | Rp22.550 | Total dikurangi potongan_poin_penjualan | Turunan |

Contoh lengkap: Jumlah Rp29.000, Diskon Rp1.450, Total Rp27.550, poin digunakan 50, potongan poin Rp5.000, tagihan Rp22.550, poin diperoleh 2.

**Keputusan penyimpanan dan alasannya:**
- saldo_poin_anggota disimpan karena saldo adalah kondisi terkini yang dibaca saat transaksi untuk menentukan apakah penukaran boleh. Risikonya: jika saldo tidak sinkron dengan akumulasi poin_diperoleh_penjualan dan poin_digunakan_penjualan, anggota bisa menukar poin yang sebenarnya tidak dimiliki (misalnya saldo tersimpan 50 padahal riwayat hanya menunjukkan 30). Karena itu dua kolom di Penjualan dipakai untuk rekonsiliasi.
- potongan_poin_penjualan disimpan terpisah dari Diskon karena potongan poin adalah potongan tambahan setelah Diskon, dan nilainya tidak boleh berubah pada nota lama jika tarif Rp5.000 per 50 poin berubah di kemudian hari.
- poin_diperoleh_penjualan disimpan dengan alasan serupa: jika aturan Rp10.000 per poin berubah, poin pada nota lama harus tetap.
- tagihan_penjualan adalah turunan karena dapat dihitung dari Total dan potongan_poin_penjualan; ini sejalan dengan keputusan modul bahwa total tidak disimpan. Nama ini sengaja berbeda dari bayar_penjualan, yang di modul berarti uang yang diterima dari pembeli.

## 5. Aturan bisnis

| Kode | Aturan bisnis |
|------|---------------|
| AB-01 | Setiap nota memiliki nomor unik dan minimal satu baris barang. |
| AB-02 | Penjualan boleh tanpa anggota (pembeli umum); jika ada, anggota harus berstatus aktif untuk memperoleh diskon 5%. |
| AB-03 | Stok barang tidak boleh negatif; penjualan ditolak bila qty melebihi stok tersedia. |
| AB-04 | Harga jual yang dipakai pada nota disimpan per baris dan tidak berubah meski harga barang kemudian naik. |
| AB-05 | NIM anggota unik; pencarian anggota dapat dilakukan lewat nomor anggota atau NIM. |
| AB-06 | Pesanan pembelian dibuat bila stok kurang dari batas minimum barang tersebut. |
| AB-07 | Poin loyalitas dihitung berdasarkan Jumlah pada nota, yaitu nilai belanja sebelum Diskon. Setiap kelipatan Rp10.000 menghasilkan 1 poin dan sisa yang kurang dari Rp10.000 dibuang. Contoh: Jumlah Rp29.000 menghasilkan 2 poin; Jumlah Rp59.000 menghasilkan 5 poin, sedangkan jika dihitung dari Total Rp49.000 hanya 4 poin. |
| AB-08 | Poin yang diperoleh dari suatu nota baru ditambahkan ke saldo poin anggota setelah transaksi selesai, sehingga poin dari transaksi tersebut tidak dapat digunakan untuk penukaran pada nota yang sama. |
| AB-09 | Penukaran poin hanya dapat dilakukan jika saldo poin anggota mencukupi untuk jumlah poin yang akan ditukarkan. Jika saldo poin kurang dari jumlah poin yang akan ditukarkan, penukaran ditolak. Contoh: saldo 30 poin dan ingin menukarkan 50 poin, maka penukaran ditolak dan saldo tetap 30 poin. |
| AB-10 | Setiap 50 poin yang ditukarkan memberikan potongan sebesar Rp5.000. Penukaran hanya dapat dilakukan dalam kelipatan 50 poin. Jumlah poin yang ditukar dipilih anggota saat transaksi, tidak melebihi saldo, dan sistem tidak menukar poin secara otomatis. Contoh: saldo 100 poin, anggota memilih menukarkan 50 poin, maka poin digunakan 50 dan potongan Rp5.000; jika memilih 100 poin, potongan Rp10.000 dan saldo berkurang 100 poin. |
| AB-11 | Total = Jumlah dikurangi Diskon. Potongan dari penukaran poin merupakan potongan tambahan setelah Diskon. Penukaran poin ditolak apabila nilai potongan poin penuh lebih besar daripada Total, sehingga nilai pembayaran tidak menjadi negatif. Jika nilai potongan poin sama dengan Total, penukaran diterima dan pembayaran menjadi Rp0. Contoh: Total Rp5.000 dan anggota menukarkan 50 poin, maka potongan Rp5.000 diterima dan pembayaran Rp0; Total Rp3.000 dan menukarkan 50 poin, maka penukaran ditolak dan 50 poin tetap di saldo. |
| AB-12 | Sesuai dengan AB-02, poin loyalitas hanya diperoleh dan digunakan oleh anggota yang berstatus aktif. Transaksi tanpa anggota atau transaksi anggota yang berstatus tidak aktif tidak memperoleh dan tidak dapat menggunakan poin loyalitas. Contoh: anggota tidak aktif melakukan transaksi dengan Jumlah Rp40.000, maka poin diperoleh = 0 dan poin tidak dapat digunakan. |
| AB-13 | Anggota yang baru didaftarkan memiliki saldo poin 0. Uji: setelah proses pendaftaran anggota (PB-01), saldo poin anggota = 0. |

## 6. Kebutuhan informasi

| Kode | Kebutuhan informasi | Data yang diperlukan |
|------|---------------------|----------------------|
| KI-01 | Omzet dan jumlah nota per hari dan per bulan | Penjualan, detail penjualan |
| KI-02 | Lima barang terlaris per bulan berdasarkan qty | Detail penjualan, barang |
| KI-03 | Barang dengan stok di bawah batas minimum | Barang |
| KI-04 | Sepuluh anggota dengan belanja terbesar per bulan | Penjualan, detail penjualan, anggota |
| KI-05 | Laporan saldo poin setiap anggota | no_anggota, nama_anggota, saldo_poin_anggota |
| KI-06 | Laporan poin yang diperoleh dan digunakan per bulan | no_anggota, nama_anggota, tgl_penjualan, poin_diperoleh_penjualan, poin_digunakan_penjualan |
| KI-07 | Daftar anggota yang dapat menukar poin, yaitu anggota yang berstatus aktif dan memiliki saldo minimal 50 poin | no_anggota, nama_anggota, status_anggota, saldo_poin_anggota |

## 7. Matriks CRUD

Keterangan: C = create (membuat), R = read (membaca), U = update (mengubah), D = delete (menghapus).

| Proses | Anggota | Barang | Penjualan | Detail | Pemasok | Pembelian |
|--------|---------|--------|-----------|--------|---------|-----------|
| PB-01 Daftar anggota | C | | | | | |
| PB-02 Catat penjualan | R, U | R, U | C | C | | |
| PB-03 Pesan ke pemasok | | R | | | R | C |
| PB-04 Terima barang | | U | | | R | U |
| PB-05 Laporan bulanan | R | R | R | R | | R |
| PB-06 Tukar poin pada penjualan | R, U | | R, U | R | | |

Keputusan PB-06: penukaran poin dipertahankan sebagai proses tersendiri, tetapi tidak membuat nota baru. PB-06 menerapkan penukaran pada nota yang sedang dicatat oleh PB-02, sehingga pada Penjualan huruf CRUD-nya R, U: membaca Jumlah dan Diskon untuk memperoleh Total, lalu mengisi poin_digunakan_penjualan dan potongan_poin_penjualan. Anggota R, U karena saldo poin dibaca lalu dikurangi setelah penukaran berhasil, dan Detail R untuk memastikan nilai Jumlah sebagai dasar perhitungan. PB-02 pada Anggota R, U karena membaca status anggota (AB-12) dan menambahkan poin yang diperoleh setelah transaksi selesai (AB-08).

Keputusan PB-01: saat anggota didaftarkan, saldo_poin_anggota diinisialisasi sebesar 0 poin (AB-13).

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

### Pernyataan kebutuhan yang telah diperbaiki (Latihan E.2)

- **(a) "data anggota harus aman"**
  `no_hp_anggota` hanya boleh dilihat oleh ketua koperasi. Kasir boleh memasukkan `no_hp_anggota` saat proses PB-01 (mendaftarkan anggota), tetapi tidak boleh melihat nomor HP anggota yang sudah terdaftar. Petugas gudang tidak boleh melihat `no_hp_anggota`. Pengubahan `no_hp_anggota` setelah anggota terdaftar hanya boleh dilakukan oleh ketua. Pengujian dilakukan dengan login sebagai ketua, kasir, dan petugas gudang, lalu mencoba memasukkan, melihat, dan mengubah `no_hp_anggota`. Kebutuhan terpenuhi jika: ketua berhasil melihat dan mengubah; kasir berhasil memasukkan nomor HP saat PB-01; dan kasir serta petugas gudang ditolak saat melihat, serta ditolak saat mengubah.

- **(b) "sistem harus cepat mencari barang"**
  Saat proses PB-02, kasir dapat mencari barang berdasarkan `kode_barang` atau sebagian kata dari `nama_barang`, dengan waktu maksimal 2 detik yang dihitung sejak kasir menekan Enter sampai hasil pencarian tampil di layar. Pengujian dilakukan pada basis data dengan asumsi 1.000 barang, menggunakan 20 pencarian yang terdiri dari 10 pencarian berdasarkan kode dan 10 berdasarkan sebagian kata dari nama. Kebutuhan terpenuhi jika seluruh pencarian selesai dalam waktu maksimal 2 detik.

- **(c) "laporan stok harus akurat"**
  `stok_barang` pada data Barang harus sama dengan hasil perhitungan mulai dari stok awal pada awal hari, ditambah seluruh penerimaan barang PB-04 dan dikurangi seluruh penjualan PB-02 sampai pemeriksaan stok setiap sore; selisih yang diizinkan adalah 0. Pengujian dilakukan oleh petugas gudang setiap sore dengan mengambil sampel 20 barang dari seluruh data Barang, kemudian membandingkan `stok_barang` dengan hasil perhitungan dan memeriksa bahwa semua barang dengan `stok_barang` kurang dari batas minimum barang tercantum dalam KI-03. Kebutuhan terpenuhi jika seluruh sampel memiliki selisih 0, tidak ada stok negatif sesuai AB-03, dan tidak ada barang yang memenuhi kondisi tersebut tetapi terlewat dari laporan.

## 10. Isu kualitas data yang diantisipasi

| Isu | Asal | Cara mengantisipasi |
|-----|------|---------------------|
| Harga pada nota lama berubah mengikuti harga barang terbaru | Keluhan ketua koperasi | Harga saat transaksi disimpan per baris nota (AB-04) |
| Stok bernilai minus di buku catatan | Keluhan petugas gudang | Stok tidak boleh negatif; penjualan ditolak bila qty melebihi stok (AB-03) |
| Anggota sulit dicari saat lupa membawa kartu | Keluhan kasir | Pencarian lewat nomor anggota atau NIM, dan NIM bersifat unik (AB-05) |
| Nomor nota ganda | Kebutuhan identitas transaksi | Nomor nota unik dan setiap nota minimal satu baris barang (AB-01) |
