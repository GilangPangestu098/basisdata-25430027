# Normalisasi Proyek - Klinik Gigi Sehat Ceria GP

Disusun oleh: Gilang Pangestu (NIM 25430027), Kelas A. Sumber: `p02_kebutuhan_data_25430027.md` (dokumen sumber Lembar Kunjungan, aturan bisnis AB-01 sampai AB-20, kamus data) dan `p03_erd_25430027.md`.

Notasi: <u>garis bawah</u> = kunci primer, `*` = kunci tamu, `{ }` = grup berulang.

## 1. Titik awal UNF: Lembar Kunjungan

Dokumen sumber yang dipakai adalah **Lembar Kunjungan** dari Pertemuan 2 (24 isian). Satu lembar berisi satu kunjungan dengan dua grup berulang: baris layanan/tindakan (maksimal tiga, AB-02) dan baris pembayaran (boleh lebih dari satu, AB-08).

```
KUNJUNGAN_UNF (no_kunjungan, tanggal_kunjungan, waktu_kunjungan, no_pasien, nama_pasien,
  kode_dokter_gigi, nama_dokter_gigi, keluhan_kunjungan, diagnosis_kunjungan, gigi_yang_ditangani_kunjungan,
  { kode_layanan_tindakan, nama_layanan_tindakan, tarif_saat_kunjungan, jumlah, subtotal_layanan },
  total_layanan, batas_waktu_pembayaran, keterlambatan_pembayaran, denda_keterlambatan, total_tagihan,
  { tanggal_pembayaran, jumlah_dibayar, keterangan_pembayaran },
  status_pembayaran)
```

**Anomali bila Lembar Kunjungan disimpan apa adanya sebagai satu tabel:**

| Anomali | Contoh pada Klinik |
|---|---|
| Ubah | Nama pasien Raka Pratama dan nama dokter drg. Nabila Putri tertulis di setiap lembar kunjungan. Jika nama dokter dikoreksi hanya pada sebagian lembar, satu kode DOK-003 punya dua nama. |
| Sisip | Pasien baru, dokter baru, atau layanan baru tidak dapat dicatat sebelum ada kunjungan, padahal AB-20 mengizinkan pasien dan dokter yang belum memiliki kunjungan. |
| Hapus | Menghapus satu-satunya kunjungan yang memakai layanan "Penambalan gigi" ikut menghapus kode, nama, dan tarif layanan tersebut. |

## 2. Dependensi fungsional

Dependensi diturunkan dari aturan bisnis dan kamus data Pertemuan 2, bukan dari contoh lembar.

| Kode | Dependensi fungsional | Dasar |
|---|---|---|
| FD1 | no_kunjungan → tanggal_kunjungan, waktu_kunjungan, no_pasien, kode_dokter_gigi, keluhan_kunjungan, diagnosis_kunjungan, gigi_yang_ditangani_kunjungan, batas_waktu_pembayaran, denda_keterlambatan, status_kunjungan | AB-01 (nomor kunjungan unik), AB-20 (tepat satu pasien dan satu dokter), AB-11 (denda final per kunjungan) |
| FD2 | no_pasien → nama_pasien, tanggal_lahir_pasien, jenis_kelamin_pasien, no_hp_pasien, alamat_pasien | AB-12 (nomor pasien unik) |
| FD3 | kode_dokter_gigi → nama_dokter_gigi | Kamus data: kode dokter unik DOK-NNN |
| FD4 | kode_layanan_tindakan → nama_layanan_tindakan, tarif_layanan_tindakan | Kamus data: kode layanan unik LY-NNN |
| FD5 | (no_kunjungan, kode_layanan_tindakan) → tarif_saat_kunjungan, jumlah | AB-03 (tarif disimpan per baris detail), AB-02 (jumlah unit per baris) |
| FD6 | no_pembayaran → no_kunjungan, tanggal_pembayaran, jumlah_dibayar, keterangan_pembayaran | AB-09 (nomor pembayaran unik, tepat satu kunjungan) |
| FD7 | tarif_saat_kunjungan, jumlah → subtotal_layanan | Turunan |

**Dependensi yang tidak berlaku:**
- kode_layanan_tindakan → tarif_saat_kunjungan. Menurut AB-03, tarif pada kunjungan lama tetap meskipun tarif master berubah, jadi layanan yang sama bisa punya tarif berbeda di kunjungan berbeda.
- no_kunjungan → no_pembayaran. Satu kunjungan dapat memiliki beberapa pembayaran (AB-08).
- tanggal_kunjungan → batas_waktu_pembayaran. Saat ini batas = tanggal + 7 hari (AB-04), tetapi Pertemuan 2 memutuskan batas disimpan agar kunjungan lama tidak ikut berubah bila aturan itu diganti. Karena aturan bisa berubah, dua kunjungan bertanggal sama tidak dijamin punya batas yang sama, sehingga ini bukan dependensi fungsional dan bukan pelanggaran 3NF.

## 3. 1NF: menghilangkan grup berulang

Ada dua grup berulang yang **saling bebas**. Jika keduanya diratakan ke satu tabel, kunjungan dengan 3 layanan dan 2 pembayaran menjadi 3 × 2 = 6 baris berisi pasangan layanan-pembayaran yang sebenarnya tidak berhubungan, dan jumlah dibayar akan terhitung ganda. Karena itu setiap grup dikeluarkan ke relasinya sendiri dengan membawa kunci induknya. Baris pembayaran diberi identitas no_pembayaran (AB-09).

```
KUNJUNGAN_1NF (no_kunjungan, tanggal_kunjungan, waktu_kunjungan, no_pasien, nama_pasien,
  kode_dokter_gigi, nama_dokter_gigi, keluhan_kunjungan, diagnosis_kunjungan, gigi_yang_ditangani_kunjungan,
  batas_waktu_pembayaran, denda_keterlambatan, status_kunjungan)
DETAIL_1NF (no_kunjungan*, kode_layanan_tindakan, nama_layanan_tindakan, tarif_saat_kunjungan, jumlah)
PEMBAYARAN_1NF (no_pembayaran, no_kunjungan*, tanggal_pembayaran, jumlah_dibayar, keterangan_pembayaran)
```

Kunci primer: KUNJUNGAN_1NF = <u>no_kunjungan</u>, DETAIL_1NF = <u>(no_kunjungan, kode_layanan_tindakan)</u>, PEMBAYARAN_1NF = <u>no_pembayaran</u>. Nilai turunan (subtotal, total layanan, keterlambatan, total tagihan, status pembayaran) tidak dibawa; keputusannya ada di bagian 6. status_kunjungan ditambahkan sebagai elemen internal sistem sesuai Pertemuan 2.

Contoh isi DETAIL_1NF untuk kunjungan KJG-2026-0001:

| no_kunjungan | kode_layanan_tindakan | nama_layanan_tindakan | tarif_saat_kunjungan | jumlah |
|---|---|---|---|---|
| KJG-2026-0001 | LY-001 | Pemeriksaan gigi | 75000 | 1 |
| KJG-2026-0001 | LY-002 | Pembersihan karang gigi | 150000 | 1 |
| KJG-2026-0001 | LY-003 | Penambalan gigi | 125000 | 1 |

Kode LY-002 dan LY-003 adalah ilustrasi; kamus data hanya mencontohkan LY-001.

## 4. 2NF: menghilangkan ketergantungan parsial

Hanya DETAIL_1NF yang memiliki kunci komposit. Di sana nama_layanan_tindakan hanya bergantung pada kode_layanan_tindakan (FD4), yaitu sebagian kunci. Atribut itu dipisah ke relasi layanan:

```
LAYANAN_TINDAKAN (kode_layanan_tindakan, nama_layanan_tindakan, tarif_layanan_tindakan)
DETAIL_KUNJUNGAN (no_kunjungan*, kode_layanan_tindakan*, tarif_saat_kunjungan, jumlah)
```

tarif_saat_kunjungan dan jumlah tetap di DETAIL_KUNJUNGAN karena bergantung pada seluruh kunci (FD5). tarif_layanan_tindakan (tarif master) berasal dari kamus data dan berbeda arti dengan tarif_saat_kunjungan. KUNJUNGAN_1NF dan PEMBAYARAN_1NF memiliki kunci tunggal sehingga otomatis memenuhi 2NF.

## 5. 3NF: menghilangkan ketergantungan transitif

Di KUNJUNGAN_1NF masih ada dua rantai:

- no_kunjungan → no_pasien → nama_pasien (FD1, FD2)
- no_kunjungan → kode_dokter_gigi → nama_dokter_gigi (FD1, FD3)

Pasien dan dokter gigi dipisah menjadi relasi sendiri. Hasil 3NF dengan kunci alami:

```
PASIEN (no_pasien, nama_pasien, tanggal_lahir_pasien, jenis_kelamin_pasien, no_hp_pasien, alamat_pasien)
DOKTER_GIGI (kode_dokter_gigi, nama_dokter_gigi)
LAYANAN_TINDAKAN (kode_layanan_tindakan, nama_layanan_tindakan, tarif_layanan_tindakan)
KUNJUNGAN (no_kunjungan, tanggal_kunjungan, waktu_kunjungan, no_pasien*, kode_dokter_gigi*,
  keluhan_kunjungan, diagnosis_kunjungan, gigi_yang_ditangani_kunjungan,
  batas_waktu_pembayaran_kunjungan, denda_keterlambatan_kunjungan, status_kunjungan)
DETAIL_KUNJUNGAN (no_kunjungan*, kode_layanan_tindakan*, tarif_saat_kunjungan_detail_kunjungan, jumlah_detail_kunjungan)
PEMBAYARAN (no_pembayaran, no_kunjungan*, tanggal_pembayaran, jumlah_dibayar_pembayaran, keterangan_pembayaran)
```

| Relasi | Kunci primer | Kunci tamu |
|---|---|---|
| PASIEN | <u>no_pasien</u> | – |
| DOKTER_GIGI | <u>kode_dokter_gigi</u> | – |
| LAYANAN_TINDAKAN | <u>kode_layanan_tindakan</u> | – |
| KUNJUNGAN | <u>no_kunjungan</u> | no_pasien, kode_dokter_gigi |
| DETAIL_KUNJUNGAN | <u>(no_kunjungan, kode_layanan_tindakan)</u> | no_kunjungan, kode_layanan_tindakan |
| PEMBAYARAN | <u>no_pembayaran</u> | no_kunjungan |

Atribut tambahan PASIEN (tanggal lahir, jenis kelamin, nomor HP, alamat) tidak ada di Lembar Kunjungan, tetapi ada di kamus data dan bergantung langsung pada no_pasien.

## 6. Keputusan nilai turunan

| Nilai | Cara menghitung | Keputusan | Alasan |
|---|---|---|---|
| subtotal_detail_kunjungan | tarif_saat_kunjungan × jumlah | Tidak disimpan | Kedua pembentuknya disimpan per baris dan terkunci setelah Selesai (AB-15) |
| total_layanan_kunjungan | jumlah semua subtotal pada kunjungan | Tidak disimpan | Dapat dihitung dari detail kunjungan |
| keterlambatan_kunjungan | selisih hari dari batas_waktu_pembayaran ke tanggal pelunasan atau tanggal pemeriksaan (AB-04) | Tidak disimpan | Nilainya terus berubah setiap hari selama belum Lunas |
| total_tagihan_kunjungan | total layanan + denda yang berlaku (AB-05, AB-06) | Tidak disimpan | Dapat dihitung dari detail dan denda |
| status_pembayaran_kunjungan | Lunas jika pembayaran kumulatif ≥ total tagihan (AB-07) | Tidak disimpan | Dapat dihitung dari pembayaran dan total tagihan; jika disimpan, koreksi pembayaran (AB-16, AB-17) berisiko membuat status tidak cocok |
| denda_keterlambatan_kunjungan (denda final) | denda yang berlaku pada tanggal pelunasan | **Disimpan** | AB-11: potret denda saat Lunas. Dikosongkan bila koreksi membuat status kembali Belum Lunas (AB-17) |
| batas_waktu_pembayaran_kunjungan | tanggal kunjungan + 7 hari (AB-04) | **Disimpan** | Potret aturan saat kunjungan dibuat; dihitung ulang hanya bila tanggal dikoreksi saat Berjalan (AB-14) |
| tarif_saat_kunjungan_detail_kunjungan | disalin dari tarif master | **Disimpan** | AB-03: tidak boleh ikut berubah bila tarif master berubah |

Pola keputusannya sama dengan Kopma: nilai yang dapat dihitung ulang dari data operasional tidak disimpan agar tidak mungkin tidak konsisten, sedangkan nilai yang merupakan potret aturan atau harga pada saat transaksi disimpan agar riwayatnya tidak berubah.

## 7. Skema relasional akhir dan pemeriksaan BCNF

Sesuai konvensi buku, setiap tabel memakai kunci pengganti `id_<nama_tabel>` sebagai kunci primer, dan kode alami menjadi kunci unik.

| Tabel | Kunci primer | Kunci unik | Kunci tamu |
|---|---|---|---|
| pasien | id_pasien | no_pasien (AB-12) | – |
| dokter_gigi | id_dokter_gigi | kode_dokter_gigi | – |
| layanan_tindakan | id_layanan_tindakan | kode_layanan_tindakan | – |
| kunjungan | id_kunjungan | no_kunjungan (AB-01) | id_pasien, id_dokter_gigi |
| detail_kunjungan | (id_kunjungan, id_layanan_tindakan) | – | id_kunjungan, id_layanan_tindakan |
| pembayaran | id_pembayaran | no_pembayaran (AB-09) | id_kunjungan |

**Pemeriksaan BCNF** (setiap penentu harus kunci kandidat):

| Tabel | Penentu yang ada | Kunci kandidat | BCNF? |
|---|---|---|---|
| pasien | id_pasien, no_pasien | id_pasien, no_pasien | Ya |
| dokter_gigi | id_dokter_gigi, kode_dokter_gigi | id_dokter_gigi, kode_dokter_gigi | Ya |
| layanan_tindakan | id_layanan_tindakan, kode_layanan_tindakan | id_layanan_tindakan, kode_layanan_tindakan | Ya |
| kunjungan | id_kunjungan, no_kunjungan | id_kunjungan, no_kunjungan | Ya |
| detail_kunjungan | (id_kunjungan, id_layanan_tindakan) | (id_kunjungan, id_layanan_tindakan) | Ya |
| pembayaran | id_pembayaran, no_pembayaran | id_pembayaran, no_pembayaran | Ya |

Semua tabel memenuhi BCNF. Nama pasien, nama dokter, nama layanan, dan nomor HP tidak dijamin unik oleh aturan bisnis, sehingga bukan penentu. Pemeriksaan ini memakai kunci alami, karena kunci pengganti tidak menghapus dependensi fungsional.

## 8. Perubahan ERD proyek

Hasil normalisasi menghasilkan enam tabel yang sama dengan ERD Pertemuan 3 (`p03_erd_25430027.png`), lengkap dengan kunci primer, kunci unik, dan kunci tamu yang sama. **ERD tidak perlu diubah.**

Satu hal yang kini diputuskan final: atribut turunan yang di ERD ditandai `/` (subtotal, total layanan, keterlambatan, total tagihan, status pembayaran) tetap tidak disimpan, sedangkan denda final dan batas waktu pembayaran tetap disimpan, sesuai bagian 6.