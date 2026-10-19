# Normalisasi Kopma

Disusun oleh: Gilang Pangestu (NIM 25430027), Kelas A. Sumber: `p02_kebutuhan_data_kopma_25430027.md` (aturan bisnis AB-01 sampai AB-13) dan `p03_erd_kopma_25430027.png`.

Notasi: <u>garis bawah</u> = kunci primer, `*` = kunci tamu, `{ }` = grup berulang.

## D.1 UNF (bentuk tidak normal)

Spreadsheet lama Kopma menyimpan satu nota per baris, dengan barang sebagai grup berulang:

```
NOTA_UNF (no_nota_penjualan, tgl_penjualan, kode_petugas, nama_petugas, no_anggota, nama_anggota,
  { kode_barang, nama_barang, qty_detail_penjualan, harga_satuan_detail_penjualan, subtotal_detail_penjualan },
  jumlah_penjualan, diskon_penjualan, total_penjualan)
```

**Anomali pada spreadsheet ini:**

| Anomali | Contoh pada spreadsheet Kopma |
|---|---|
| Ubah | Nama anggota Budi Santoso dan nama pemasok CV. Sumber A.T.K tertulis di banyak baris. Jika hanya sebagian baris yang diperbaiki, data menjadi tidak konsisten (baris terakhir pada Gambar 4.1). |
| Sisip | Barang baru atau anggota baru tidak dapat dicatat sebelum ada nota yang memuatnya, karena kunci baris adalah nomor nota. |
| Hapus | Menghapus satu-satunya nota yang berisi suatu barang ikut menghapus kode, nama, dan harga barang itu. |

## D.2 1NF (menghilangkan grup berulang)

Satu baris untuk setiap barang di setiap nota. Semua nilai menjadi atomik dan kunci primer menjadi komposit (no_nota_penjualan, kode_barang).

```
NOTA_1NF (no_nota_penjualan, kode_barang, tgl_penjualan, kode_petugas, nama_petugas, no_anggota,
  nama_anggota, nama_barang, qty_detail_penjualan, harga_satuan_detail_penjualan,
  subtotal_detail_penjualan, jumlah_penjualan, diskon_penjualan, total_penjualan)
```

Contoh isi (nota PJ-2609-0142):

| no_nota_penjualan | kode_barang | tgl_penjualan | kode_petugas | nama_petugas | no_anggota | nama_anggota | nama_barang | qty | harga_satuan | subtotal |
|---|---|---|---|---|---|---|---|---|---|---|
| PJ-2609-0142 | BRG-001 | 2026-09-14 10:21 | K03 | Rina | A-0457 | Budi Santoso | Pulpen | 2 | 4000 | 8000 |
| PJ-2609-0142 | BRG-007 | 2026-09-14 10:21 | K03 | Rina | A-0457 | Budi Santoso | Buku tulis | 3 | 7000 | 21000 |

Tabel ini sudah 1NF, tetapi tanggal, petugas, dan anggota masih berulang di setiap baris barang. Kode barang dan nama orang pada contoh di atas adalah data ilustrasi.

## D.3 Dependensi fungsional

Dependensi diturunkan dari aturan bisnis Pertemuan 2, bukan dari isi spreadsheet.

| Kode | Dependensi fungsional | Dasar |
|---|---|---|
| FD1 | no_nota_penjualan → tgl_penjualan, kode_petugas, no_anggota | AB-01: satu nota punya satu tanggal, satu kasir, dan paling banyak satu anggota (AB-02) |
| FD2 | kode_petugas → nama_petugas | Satu kode petugas milik satu orang |
| FD3 | no_anggota → nama_anggota, nim_anggota; nim_anggota → no_anggota | AB-05: nomor anggota dan NIM sama-sama unik |
| FD4 | kode_barang → nama_barang | Satu kode untuk satu barang |
| FD5 | (no_nota_penjualan, kode_barang) → qty_detail_penjualan, harga_satuan_detail_penjualan | AB-04: harga disimpan per baris nota |
| FD6 | qty_detail_penjualan, harga_satuan_detail_penjualan → subtotal_detail_penjualan | Turunan |

Dependensi yang **tidak** berlaku: kode_barang → harga_satuan_detail_penjualan. Menurut AB-04, harga di nota dapat berbeda dari harga barang saat ini.

**Titik Analisis 1.** harga_satuan_detail_penjualan ditempatkan pada kunci (no_nota_penjualan, kode_barang) karena harga itu adalah fakta transaksi: harga yang berlaku pada nota tertentu untuk barang tertentu (AB-04). Kode barang saja tidak menentukannya, karena barang yang sama bisa terjual dengan harga berbeda pada waktu berbeda. Jika harga dipindah ke tabel barang, setiap kenaikan harga akan ikut mengubah nilai semua nota lama. Laporan omzet tahun lalu akan dihitung ulang memakai harga hari ini sehingga angkanya berubah dan tidak lagi cocok dengan uang yang benar-benar diterima.

## D.4 2NF (menghilangkan ketergantungan parsial)

FD1 hanya bergantung pada no_nota_penjualan dan FD4 hanya bergantung pada kode_barang, padahal keduanya bagian dari kunci komposit. Atribut tersebut dipisah:

```
PENJUALAN_2NF (no_nota_penjualan, tgl_penjualan, kode_petugas, nama_petugas, no_anggota, nama_anggota, bayar_penjualan)
BARANG (kode_barang, nama_barang)
DETAIL_PENJUALAN (no_nota_penjualan*, kode_barang*, qty_detail_penjualan, harga_satuan_detail_penjualan)
```

Kunci primer: PENJUALAN_2NF = <u>no_nota_penjualan</u>, BARANG = <u>kode_barang</u>, DETAIL_PENJUALAN = <u>(no_nota_penjualan, kode_barang)</u>. Setelah tahap ini, semua atribut bukan kunci di DETAIL_PENJUALAN bergantung pada seluruh kunci komposit (FD5). bayar_penjualan berasal dari nota (bayar tunai) dan bergantung pada no_nota_penjualan.

## D.5 3NF (menghilangkan ketergantungan transitif)

Di PENJUALAN_2NF masih ada dua rantai:

- no_nota_penjualan → kode_petugas → nama_petugas (FD1, FD2)
- no_nota_penjualan → no_anggota → nama_anggota (FD1, FD3)

Petugas dan anggota dipisah menjadi relasi sendiri. Hasil 3NF untuk proses penjualan:

```
PENJUALAN (no_nota_penjualan, tgl_penjualan, kode_petugas*, no_anggota*, bayar_penjualan)
DETAIL_PENJUALAN (no_nota_penjualan*, kode_barang*, qty_detail_penjualan, harga_satuan_detail_penjualan)
BARANG (kode_barang, nama_barang, kategori_barang, harga_jual_barang, stok_barang, stok_min_barang)
PETUGAS (kode_petugas, nama_petugas, peran_petugas)
ANGGOTA (no_anggota, nim_anggota, nama_anggota, prodi_anggota, no_hp_anggota, status_anggota, tgl_daftar_anggota)
```

| Relasi | Kunci primer | Kunci tamu |
|---|---|---|
| PENJUALAN | <u>no_nota_penjualan</u> | kode_petugas, no_anggota (boleh kosong, AB-02) |
| DETAIL_PENJUALAN | <u>(no_nota_penjualan, kode_barang)</u> | no_nota_penjualan, kode_barang |
| BARANG | <u>kode_barang</u> | – |
| PETUGAS | <u>kode_petugas</u> | – |
| ANGGOTA | <u>no_anggota</u> | – |

Atribut tambahan pada BARANG, PETUGAS, dan ANGGOTA berasal dari kamus data Pertemuan 2. Semuanya bergantung langsung pada kunci relasinya.

## D.6 Keputusan nilai turunan

| Nilai turunan | Cara menghitung | Keputusan | Alasan |
|---|---|---|---|
| subtotal_detail_penjualan | qty × harga_satuan_detail_penjualan | Tidak disimpan | Dua kolom pembentuknya sudah disimpan per baris dan tidak berubah (AB-04) |
| jumlah_penjualan | jumlah semua subtotal pada satu nota | Tidak disimpan | Dapat dihitung dari detail penjualan |
| diskon_penjualan | 5% × jumlah jika anggota aktif (AB-02) | Tidak disimpan | Dapat dihitung dari jumlah dan status anggota |
| total_penjualan | jumlah − diskon | Tidak disimpan | Dapat dihitung dari dua nilai di atas |
| kembali | bayar_penjualan − total | Tidak disimpan | Dapat dihitung dari bayar dan total |

Karena tidak disimpan di tabel operasional, nilai-nilai ini tidak mungkin tidak konsisten dengan detail nota.

**Titik Analisis 2.** Keputusan "total tidak disimpan" berlaku untuk data operasional, yaitu data yang masih bisa diperbaiki (misalnya qty salah ketik) sehingga total harus selalu mengikuti detailnya. Tabel arsip di Buku 2 menyimpan potret historis, yaitu nilai yang sudah final dan tidak boleh berubah lagi, termasuk bila aturan diskon atau data anggota berubah di kemudian hari. Menyimpan total di arsip justru menjaga potret itu tetap sama, jadi kedua keputusan konsisten dengan tujuan masing-masing: data operasional mengutamakan konsistensi, arsip mengutamakan keabadian nilai.

## D.7 Mencocokkan dengan skema kanonik

Proses pembelian dinormalisasi dengan pola yang sama dari faktur pemasok:

```
FAKTUR_UNF (no_faktur_pembelian, tgl_pembelian, nama_pemasok, telepon_pemasok, alamat_pemasok,
  { kode_barang, nama_barang, qty_detail_pembelian, harga_beli_detail_pembelian })
```

Grup barang dipisah menjadi DETAIL_PEMBELIAN (1NF dan 2NF), lalu data pemasok dipisah menjadi PEMASOK karena no_faktur_pembelian → pemasok → nama, telepon, alamat (3NF). Hasilnya PEMBELIAN, DETAIL_PEMBELIAN, dan PEMASOK, sehingga total ada 8 tabel, sama dengan ERD Kopma Pertemuan 3.

Perbandingan dengan skema kanonik (Tabel 4.2):

| Tabel | Hasil normalisasi (kunci alami) | Skema kanonik: kunci primer | Kunci unik | Kunci tamu |
|---|---|---|---|---|
| petugas | kode_petugas | id_petugas | kode_petugas | – |
| anggota | no_anggota | id_anggota | no_anggota, nim_anggota | – |
| barang | kode_barang | id_barang | kode_barang | – |
| pemasok | (tidak punya kode alami) | id_pemasok | – | – |
| penjualan | no_nota_penjualan | id_penjualan | no_nota_penjualan | id_petugas, id_anggota (boleh NULL) |
| detail_penjualan | (no_nota_penjualan, kode_barang) | (id_penjualan, id_barang) | – | id_penjualan, id_barang |
| pembelian | no_faktur_pembelian | id_pembelian | – | id_pemasok |
| detail_pembelian | (no_faktur_pembelian, kode_barang) | (id_pembelian, id_barang) | – | id_pembelian, id_barang |

Hasilnya cocok. Perbedaan utamanya hanya kunci pengganti `id_*` yang dipakai sebagai kunci primer, sedangkan kode alami seperti no_nota_penjualan menjadi kunci unik. Akibatnya kunci tamu juga merujuk ke `id_*`, misalnya penjualan.kode_petugas menjadi penjualan.id_petugas. Kunci pengganti tidak mengubah dependensi fungsional, sehingga pemeriksaan normalisasi tetap memakai kunci alami (Troubleshooting Masalah 3).

## D.8 Pemeriksaan BCNF

Syarat BCNF: setiap penentu (determinant) adalah kunci kandidat.

| Tabel | Penentu yang ada | Kunci kandidat | BCNF? |
|---|---|---|---|
| petugas | id_petugas, kode_petugas | id_petugas, kode_petugas | Ya |
| anggota | id_anggota, no_anggota, nim_anggota | id_anggota, no_anggota, nim_anggota (AB-05) | Ya |
| barang | id_barang, kode_barang | id_barang, kode_barang | Ya |
| pemasok | id_pemasok | id_pemasok (nama pemasok tidak dijamin unik) | Ya |
| penjualan | id_penjualan, no_nota_penjualan | id_penjualan, no_nota_penjualan (AB-01) | Ya |
| detail_penjualan | (id_penjualan, id_barang) | (id_penjualan, id_barang) | Ya |
| pembelian | id_pembelian, (id_pemasok, no_faktur_pembelian) | id_pembelian, (id_pemasok, no_faktur_pembelian) | Ya |
| detail_pembelian | (id_pembelian, id_barang) | (id_pembelian, id_barang) | Ya |

Semua tabel memenuhi BCNF. Catatan untuk pembelian: nomor faktur dibuat oleh pemasok, sehingga dua pemasok bisa memakai nomor yang sama. Karena itu no_faktur_pembelian saja bukan penentu; yang menjadi penentu adalah pasangan (id_pemasok, no_faktur_pembelian), dan pasangan itu kunci kandidat. Pasangan ini belum dijadikan kunci unik di skema kanonik dan dapat dipertimbangkan saat DDL di Modul 5.

## Tambahan: atribut poin loyalitas (Latihan E.1 Pertemuan 3)

Atribut poin dari Pertemuan 2 dan 3 tetap memenuhi 3NF dan BCNF:

| Atribut | Tabel | Dependensi | Keputusan |
|---|---|---|---|
| saldo_poin_anggota | anggota | id_anggota → saldo_poin_anggota | Disimpan (dibaca setiap transaksi untuk AB-09) |
| poin_diperoleh_penjualan | penjualan | id_penjualan → poin_diperoleh_penjualan | Disimpan (nilai nota lama tetap jika aturan AB-07 berubah) |
| poin_digunakan_penjualan | penjualan | id_penjualan → poin_digunakan_penjualan | Disimpan (pilihan anggota saat transaksi, AB-10) |
| potongan_poin_penjualan | penjualan | id_penjualan → potongan_poin_penjualan | Disimpan (nilai nota lama tetap jika tarif Rp5.000 per 50 poin berubah) |
| tagihan_penjualan | – | total − potongan_poin_penjualan | Tidak disimpan (turunan) |

poin_diperoleh_penjualan sebenarnya dapat dihitung dari jumlah_penjualan (AB-07). Kolom ini sengaja disimpan sebagai potret aturan yang berlaku saat nota dibuat, sama seperti harga_satuan_detail_penjualan pada AB-04.

## Latihan dan Modifikasi

### E.1 Beberapa nomor telepon untuk setiap pemasok

Jika semua nomor disimpan dalam satu kolom, misalnya `telepon_pemasok = '0725-41234, 0812-7788-9900'`, nilainya tidak atomik dan melanggar 1NF. Menambah kolom telepon1, telepon2, dan seterusnya juga merupakan grup berulang. Penyelesaiannya adalah memindahkan telepon ke relasi sendiri:

```
PEMASOK (id_pemasok, nama_pemasok, alamat_pemasok)
TELEPON_PEMASOK (id_pemasok*, telepon_pemasok, jenis_telepon_pemasok)
```

Kunci primer TELEPON_PEMASOK adalah <u>(id_pemasok, telepon_pemasok)</u>, sehingga satu pemasok dapat memiliki nol atau banyak nomor dan nomor yang sama tidak tercatat dua kali untuk pemasok yang sama. Kolom telepon_pemasok dihapus dari PEMASOK. jenis_telepon_pemasok (misalnya kantor atau WhatsApp) bersifat opsional dan bergantung pada seluruh kunci.

### E.2 Contoh pelanggaran 3NF: nama_anggota disimpan di penjualan

Jika nama_anggota disimpan di penjualan, muncul rantai no_nota_penjualan → no_anggota → nama_anggota (ketergantungan transitif). Contoh data:

| no_nota_penjualan | tgl_penjualan | no_anggota | nama_anggota |
|---|---|---|---|
| PJ-2609-0142 | 2026-09-14 | A-0457 | Budi Santoso |
| PJ-2609-0150 | 2026-09-16 | A-0457 | Budi Santoso |
| PJ-2610-0011 | 2026-10-02 | A-0457 | Budi Santoso |

Nama anggota ternyata salah ketik dan diperbaiki hanya pada nota yang sedang dibuka:

```sql
UPDATE penjualan_tidak_3nf
SET nama_anggota = 'Budi Santosa'
WHERE no_nota_penjualan = 'PJ-2609-0142';
```

Setelah kueri ini, anggota A-0457 punya dua nama berbeda di tabel yang sama (Budi Santosa pada satu nota, Budi Santoso pada dua nota lain). Itulah anomali ubah. Pada skema 3NF, nama hanya tersimpan sekali dan perbaikan cukup satu baris:

```sql
UPDATE anggota
SET nama_anggota = 'Budi Santosa'
WHERE no_anggota = 'A-0457';
```