# S4: pemeriksaan spec `core-widgets-and-templates`

Tanggal: 2026-11-26. Berkas: `.kiro/specs/core-widgets-and-templates/{requirements,design,tasks}.md`.
Isi berbahasa Indonesia; istilah teknis dan id task tetap Inggris. Tidak ada commit atau push. `docs/brief/` tidak diubah.

## Ringkasan

- Requirements: 19 requirement, 153 acceptance criteria (AC). Semua tanda "(see Q#)" sudah dihapus.
- Tasks: 60 task. 56 `[kode]` atau `[dok]` dan 4 `[manual]` untuk user (M1 sampai M4).
- Celah: 0 pemblokir, 13 non-pemblokir (tabel di bawah).
- Setiap AC punya minimal satu task dan satu bagian design (tabel keterlacakan).

## Perubahan requirements dari jawaban user

| Jawaban | Perubahan |
|---|---|
| Q2: billing GitHub Actions sudah beres | Req 18.9: CI diverifikasi lokal (YAML parse, `actionlint` bila ada, tiap langkah `run` di salinan bersih), laporan menyatakan itu bukan run hosted. Req 18.10: run hosted pertama setelah user push dicatat sebagai langkah manual user, bukan pemblokir kode. Task K2 dan M4. |
| Q5: B | Req 14.7: tidak ada `integration_test/`; README menyatakan "semua tipe tes" = unit, bloc, widget, stress, a11y, golden, PBT. Task H6 (cek folder tidak ada) dan Z1. |
| Q6: A | Req 13.10: tombol "Check connection" dihapus bersama `PlaceholderPage`. Keputusan design D9: `ConnectionCheckCubit`, state, tes, DI, string `checkConnection*`, dan `Env.connectionCheckUrl` ikut dihapus karena tidak ada pemakai lain; `placeholderTitle` diganti `appTitle`. Bukti jaringan APK (skeleton-foundation 3.5 dan 24.9) dicatat sudah terbukti dan dilepas lewat Req 19.4. Task H6. |
| Q1, Q3, Q4, Q7 sampai Q10 | Default dari S3 dipakai. Bagian pengantar requirements diganti dengan daftar keputusan. |

## Temuan saat menulis design (masuk Revision notes di design.md)

1. `architecture_test.dart` memuat `_reservedNames` yang melarang deklarasi `AdaptiveScaffold`, `AdaptiveBuilder`, `PageColumn`, `AdaptiveGrid`, `ActionGroup`. Aturan larangan Material hanya berlaku di `lib/app`. Task A4 menghapus reservasi dan memperluas larangan ke `core/widgets`, `core/layout`, `features`.
2. `kiri_check` 1.4.0 bergantung pada `package:test`, bukan `flutter_test`, sehingga blok `forAll` tidak menerima `WidgetTester`. `stressProperty` (Req 9.8) punya spike dan dua cadangan di task A7.
3. `subosito/flutter-action` tidak membaca `.fvmrc`; workflow membaca versi dengan `jq` dari `skeleton/.fvmrc` (task K1).
4. `.fvmrc` ada di `skeleton/`, bukan di root repo. `tool/` di root belum berisi apa pun dan tidak punya `pubspec.yaml`, jadi skrip `create_app` dan `sync_core` hanya memakai `dart:` core (D8). Tesnya ada di `skeleton/test/repo_tools/` dan dikecualikan dari salinan `create_app` (D7).
5. Aturan satu tipe publik per berkas (arsitektur 22.3) berlaku, jadi enum varian dan `ToastController` mendapat berkas sendiri (D1).
6. `tokens.g.dart` belum punya token lebar dialog, tinggi toast, ukuran grab handle; task A5 menambahkannya lewat `design/tokens.yaml`, bukan literal di widget (D13).
7. `Req 13.5` ("HomeView di dalam AdaptiveScaffold") dan `Req 8.5` (AppShell memakai AdaptiveScaffold) dipertemukan: shell memegang scaffold, `HomeView` menjadi body (design R5).

## Keterlacakan: requirement ke task dan ke design

Singkatan design: **Act** Action, **Inp** Input, **Con** Content, **Fb** Feedback, **Ov** Overlay, **Lay** Layout, **Str** Stress harness,
**A11y** Accessibility checks, **Gold** Golden setup, **Home** Home feature, **Brk** Bricks, **CA** create_app, **SC** sync_core, **CI** CI, **Cat** Catalog block format,
**Rules** Rules every widget follows, **Test** Testing strategy.

| Req | AC | Task | Design |
|---|---|---|---|
| 1 | 1.1 | A3 (inventory 25 nama), semua task B1 sampai G2 (satu widget tiap task) | Cat, D1 |
| 1 | 1.2 | B2 sampai G2 (lokasi file), A4 (aturan arsitektur) | D1, File map |
| 1 | 1.3 | A3 (blok untuk primitif dan pemindai), B2 sampai G2 (blok per widget) | Cat |
| 1 | 1.4 | A3, Z2 (strict) | D6, Cat |
| 1 | 1.5 | A3 (tes gagal bila `CATALOG.md` ada) | Cat |
| 1 | 1.6 | Z1 | Test |
| 2 | 2.1 | A4, A5, semua task widget (template W) | Rules, D13 |
| 2 | 2.2 | A4 | Why the Pressable and Material boundary is one rule |
| 2 | 2.3 | semua task widget (aturan arsitektur 17.9/18.7 yang sudah ada) | Rules |
| 2 | 2.4 | P1, semua task widget | Strings, D4 |
| 2 | 2.5 | template W (kasus reduced motion), B2, D3, F3, G1, G2 | Rules |
| 2 | 2.6 | template W (kasus hit area touch), B2 sampai D3 | Rules |
| 2 | 2.7 | template W (semantik, focus ring, hover fill), B1 | Rules |
| 2 | 2.8 | template W (kasus invarians tema) | Rules |
| 2 | 2.9 | semua task widget yang memakai ikon, A4 | Rules |
| 2 | 2.10 | A4, template W | D3, Layering |
| 3 | 3.1 sampai 3.5 | B2 | Act |
| 3 | 3.6 | B3 | Act |
| 3 | 3.7, 3.8 | B4 | Act |
| 3 | 3.9 | C4 | Act |
| 4 | 4.1 sampai 4.3 | D1 | Inp |
| 4 | 4.4 | D2 | Inp |
| 4 | 4.5, 4.6 | D3 | Inp |
| 4 | 4.7, 4.8 | D4 | Inp |
| 5 | 5.1, 5.2 | E1 | Con |
| 5 | 5.3 | E2 | Con |
| 5 | 5.4 | E3 | Con |
| 5 | 5.5 | E4 | Con |
| 5 | 5.6, 5.7 | E1, E2, E3, E4 | Con, Rules |
| 6 | 6.1 | F1 | Fb |
| 6 | 6.2, 6.3 | F2, P1 | Fb, Strings |
| 6 | 6.4, 6.5 | F3 | Fb, D14 |
| 6 | 6.6, 6.7 | F4 (6.7 juga B4 untuk pill tanpa toast) | Fb |
| 7 | 7.1 sampai 7.4 | G2 (7.4 butuh G1) | Ov |
| 7 | 7.5 | G1 | Ov |
| 7 | 7.6 | G1, G2 | Ov |
| 7 | 7.7 | A4, G1, G2 | Ov, Why the Pressable and Material boundary is one rule |
| 8 | 8.1 sampai 8.4 | C5 | Lay |
| 8 | 8.5 | H5 | Home |
| 8 | 8.6 | C2 | Lay |
| 8 | 8.7 | C1, C3 | Lay |
| 8 | 8.8 | C2, C5 | Lay |
| 9 | 9.1 sampai 9.7 | A1 | Str |
| 9 | 9.8 | A7 | Str (stressProperty), Revision R3 |
| 9 | 9.9 | A1 | Str (self-tests) |
| 9 | 9.10 | A1 | Str |
| 10 | 10.1, 10.2 | A6 | A11y |
| 10 | 10.3 | A6 (harness), semua widget interaktif (template W) | A11y |
| 11 | 11.1 sampai 11.5 | A2 | Gold |
| 11 | 11.6 | A2 (`app_root_test.dart`) | Gold |
| 11 | 11.7 | A2, H7 (hash dua kali jalan) | Gold |
| 11 | 11.8 | Z1 | Test |
| 12 | 12.1, 12.2, 12.4 | B1 sampai G2 (template W) | Test, Gold |
| 12 | 12.3 | H7 (dan C5 untuk goldens scaffold) | Home tests |
| 12 | 12.5 | A3, Z2 | D6 |
| 12 | 12.6 | M1 | Gold (Review) |
| 13 | 13.1 | H1, H5 (FEATURE.md) | Home |
| 13 | 13.2 | H1 | Home |
| 13 | 13.3 | H2 | Home |
| 13 | 13.4 | H3 | Home |
| 13 | 13.5, 13.6 | H4 | Home |
| 13 | 13.7 | H5 (juga H2 dan H3 untuk anotasi DI) | Home |
| 13 | 13.8 | H3, H4 | Home |
| 13 | 13.9 | H4 | Home |
| 13 | 13.10 | H6 | D9, Home |
| 13 | 13.11 | H1, Z2 | Home |
| 14 | 14.1 | H1, H2 | Home tests |
| 14 | 14.2 | H3 | Home tests |
| 14 | 14.3, 14.4 | H4 | Home tests |
| 14 | 14.5 | H7 | Home tests |
| 14 | 14.6 | H2 | Home tests |
| 14 | 14.7 | H6 (tidak ada `integration_test/`), Z1 | D10 |
| 15 | 15.1, 15.2, 15.5, 15.6 | I1 | Brk |
| 15 | 15.3 | I2 (page), I3 (bloc) | Brk |
| 15 | 15.4 | I4 (usecase), I5 (core_widget) | Brk |
| 15 | 15.7 | I6 | Brk |
| 15 | 15.8 | Z1 | Brk |
| 16 | 16.1, 16.2, 16.3 | J1, J2 | CA |
| 16 | 16.4, 16.5 | J2 | CA |
| 16 | 16.6, 16.7 | J3 | CA |
| 16 | 16.8 | J4 | CA |
| 16 | 16.9, 16.10 | J5 | CA |
| 16 | 16.11 | J4, J5, Z3 | CA |
| 16 | 16.12 | J1 | CA |
| 16 | 16.13 | M2 (dan J5 untuk build web otomatis) | CA, Risks |
| 17 | 17.1, 17.4, 17.6, 17.7, 17.8 | S2 | SC |
| 17 | 17.2, 17.3, 17.5 | S1 | SC |
| 18 | 18.1 sampai 18.8 | K1 | CI |
| 18 | 18.9 | K1 (tes parse), K2 (jalankan langkah) | CI, D11 |
| 18 | 18.10 | M4 | D11 |
| 19 | 19.1 sampai 19.3 | Z3 | Test |
| 19 | 19.4 | Z3 (gerbang penuh), H6 (3.5 dan 24.9 dilepas) | D9 |
| 19 | 19.5 | Z1 | Test |
| 19 | 19.6 | Z3 (`git diff origin/main -- docs/brief` kosong), A4 (tidak ada kit/hook baru) | Test |
| 19 | 19.7 | Z3, M1, M2, M4 | Test |

Cakupan: 153 dari 153 AC punya task dan bagian design. Pengecekan silang: Req 3.9 dan 8.x layout ada di lane C, Req 9 dan 10 di lane P, Req 11 dan 12 tersebar di lane P dan lane widget.

## Daftar task per lane

| Lane | Task | Jumlah |
|---|---|---|
| P prasyarat | P1, A1 sampai A7 | 8 |
| B action | B1 sampai B4 | 4 |
| C layout | C1 sampai C5 | 5 |
| D input | D1 sampai D4 | 4 |
| E content | E1 sampai E4 | 4 |
| F feedback | F1 sampai F4 | 4 |
| G overlay | G1, G2 | 2 |
| H home | H1 sampai H7 | 7 |
| I bricks | I1 sampai I6 | 6 |
| J create_app | J1 sampai J5 | 5 |
| S sync_core | S1, S2 | 2 |
| K CI | K1, K2 | 2 |
| Z final | Z1 sampai Z3 | 3 |
| M manual | M1 sampai M4 | 4 |
| Total | | 60 |

Lane B sampai G berjalan paralel setelah P1 dan A1 sampai A6, dengan batas file di tabel "Parallel lanes and file boundaries" di `tasks.md`.
Pemilik file bersama: lane P (`pubspec.yaml`, `dart_test.yaml`, `.gitignore`, `design/tokens.yaml`, `tokens.g.dart`, `test/helpers/*`), A4 lalu H1 lalu Z2 (`architecture_test.dart`), P1 dan H3 (ARB), lane H (`lib/app/**`), Z1 (`README.md`), berkas hasil generate tidak diedit tangan.

## Celah

### Pemblokir

Tidak ada. Setiap task punya input yang sudah ada di repo atau dihasilkan task sebelumnya.

### Non-pemblokir

| # | Celah | Dampak | Penanganan |
|---|---|---|---|
| 1 | `stressProperty` (Req 9.8): `kiri_check` tidak bisa memegang `WidgetTester`. | Req 9.8 bisa hanya terpenuhi sebagian. | Task A7: spike 30 menit, jalur utama, cadangan kedua, cadangan ketiga (Random bersemai) dengan catatan di README. A7 tidak memblokir lane lain. |
| 2 | Req 9.2 menyebut 17 render per widget, sedangkan Req 10.1 butuh a11y terang dan gelap di 375×812. Quick hanya punya 375×812 gelap. | Widget interaktif jadi 18 render. | Design: tes `interactive` menambah satu kasus terang 375×812. Disarankan angka di Req 9.2 dijelaskan "17 untuk widget non-interaktif". Tidak mengubah acceptance. |
| 3 | Req 8.6 "70 karakter": lebar kolom diaproksimasi (35 em). | Selisih kecil tergantung font. | Dicatat di design; tes memeriksa batas lebar, bukan jumlah karakter. |
| 4 | Req 11.7 (piksel sama dua kali jalan) belum pernah dijalankan; Mac ini Intel. | Bisa gagal. | A2 dan H7 mencatat hash; hasil beda dilaporkan sebagai temuan, tidak ditutup dengan toleransi. |
| 5 | Req 12.2 meminta state hover, pressed, fokus dalam satu gambar. | Butuh gestur di test untuk tiap galeri; usaha lebih besar. | Template W dan A2 (`goldenGallery` dengan `prepare`). Bila satu state tak bisa ditampilkan, task mencatat alasannya di `S5-<task>.md`. |
| 6 | Req 12.6 dan 11.7 butuh mata user. | Tidak otomatis. | M1. |
| 7 | Req 16.13: build Android dan iOS bergantung toolchain (lisensi Android SDK, Xcode). | Tidak bisa dibuktikan oleh agen. | M2 mencatat penyebab; web dan macOS wajib. Sesuai keputusan S3 Q10. |
| 8 | Req 15.6 dan 15.7: tes bricks butuh `mason` dan `pub get` di salinan sementara (sekitar 30 sampai 60 detik). | Gerbang lokal lebih lambat. | Satu salinan sementara dipakai bersama untuk kelima brick (design Bricks). Tes skip dengan pesan jelas bila `mason` tidak ada. |
| 9 | Req 13.5 dan 8.5 tampak bertabrakan. | Salah baca bisa membuat dua scaffold bersarang. | Design R5: shell memegang `AdaptiveScaffold`, `HomeView` jadi body, golden memakai `pumpInShell`. |
| 10 | Req 4.8 (tema bertahan setelah restart) sudah dilakukan `AppSettingsCubit`. | Widget hanya memanggil. | Task D4 memakai tes restart tingkat cubit dengan `InMemoryKeyValueStore`. |
| 11 | Req 19.3 meminta waktu jalan profil `full`; jumlah kasus besar. | Waktu jalan bisa panjang. | Design mengelompokkan fixture per (ukuran, skala, tema, input); Z3 mencatat waktunya. |
| 12 | Req 3.8 ("tick dikembalikan saat gagal") ambigu: tick muncul sebelum hasil salin diketahui. | Perilaku optimistis. | Design dan B4: tick muncul saat ditekan, kembali bila `onCopy` mengembalikan `false` atau melempar. |
| 13 | `app_root_test.dart` (A2) dan `test/app/**` (H5) berada di folder yang sama. | Risiko konflik kecil. | A2 memiliki berkas itu; H5 hanya mengedit bila route berubah dan mencatatnya. |

## Yang tidak diperiksa

Tidak ada kode yang dijalankan atau dikompilasi, jadi tanda tangan API di design belum dicompile dan token baru di A5 belum diverifikasi terhadap generator. Jumlah AC (153) dihitung dari requirements.md, bukan diverifikasi ulang dengan alat.
