# S3: tinjauan requirements `core-widgets-and-templates`

Tanggal: 2026-11-26. Pengganti "Analyze Requirements". Berkas: `.kiro/specs/core-widgets-and-templates/requirements.md`
(19 requirement, 153 acceptance criteria). Dibandingkan dengan `docs/brief/` (02, 03 §6-§7, 04 §7/§11/§12, 10, 11),
hasil `skeleton-foundation` di `skeleton/` (README, deviasi, W-notes), dan `spikes/crew-run/C2, C3, C5, C7`.
Isi berbahasa Indonesia; istilah teknis tetap Inggris.

Ringkasan: 10 pertanyaan. **Perlu jawaban user (memengaruhi acceptance): Q2, Q5, Q6.** Sisanya (Q1, Q3, Q4, Q7, Q8, Q9, Q10)
sudah saya putuskan dengan default; user cukup keberatan bila tidak setuju. Requirements memakai default itu dan menandai
`(see Q#)`.

## Perlu jawaban user

### Q2. Cara memverifikasi CI selama GitHub Actions gagal karena billing (memengaruhi acceptance)
Fakta: run `spike-pages` gagal karena billing akun (C3), jadi tidak ada run hosted. Brief 10 §2 meminta `ci.yml` dan job `template`,
tetapi acceptance "CI hijau" tidak mungkin dibuktikan.
Opsi:
- A. Verifikasi lokal: YAML dicek parse (dan `actionlint` bila terpasang), setiap langkah `run` dijalankan berurutan di salinan bersih di Mac ini, laporan menyatakan "tidak ada run hosted". Run hosted pertama dicatat setelah billing beres (bukan gerbang spec).
- B. Tahan spec sampai billing beres. Memblokir Phase 1 tanpa batas waktu.
- C. Jalankan workflow lokal dengan `act` (Docker). Belum tentu terpasang, dan runner Ubuntu di Docker tidak identik dengan hosted.
Rekomendasi: A. Req 18.9 dan 18.10 mengikuti A. Jawaban diperlukan karena menentukan arti "CI selesai" di acceptance.

### Q5. Apakah `integration_test/` ikut di contoh `home` (memengaruhi acceptance)
Brief 10 §1: integration test "satu happy path per app". Prompt sumber berkata "home example feature with all test types", tetapi daftar tipe tes
di 10 §1 menaruh integration di tingkat app, bukan skeleton. Integration test butuh device/emulator/Chrome driver, memperlambat Quality_Gate, dan
tidak jalan di CI tanpa setup tambahan.
Opsi:
- A. Sertakan satu happy path di `skeleton/integration_test/` (buka app, daftar tampil, ganti tema), dijalankan manual di macOS/Chrome, tidak di CI.
- B. Tidak sertakan; "semua tipe tes" berarti unit, bloc, widget, stress, a11y, golden, PBT. Integration ada di app Orbit/Tally.
Rekomendasi: B bila "all test types" dibaca mengikuti kolom "Required for" di 10 §1 (integration hanya per app); A bila user ingin literal. Req 14.7 bersyarat pada jawaban ini.

### Q6. Nasib tombol "Check connection" saat `PlaceholderPage` diganti `home` (memengaruhi acceptance)
Acceptance `skeleton-foundation` (Req 3.5, 24.9) bergantung pada tombol itu untuk membuktikan Release_APK menjangkau jaringan. `home` membaca daftar statis, jadi tidak memanggil jaringan.
Opsi:
- A. Hapus bersama `PlaceholderPage`; bukti jaringan Release_APK jadi tidak ada lagi di skeleton (Orbit akan membuktikannya).
- B. Pertahankan sebagai aksi sekunder kecil di `home` (AppButton.secondary), dengan `ConnectionCheckCubit` tetap. Menyimpan bukti, tetapi menaruh kode demo di contoh yang disalin ke semua app, dan `create_app --clean` harus menghapusnya.
- C. Pindahkan ke halaman terpisah `/debug` yang tidak masuk destinasi shell.
Rekomendasi: A. Brief 03 §7 mendefinisikan `home` tanpa aksi jaringan, dan `create_app` menyalin ke setiap app; Req 3.5 sudah terbukti di Phase 1. Req 13.10 menyebut kedua cabang sampai dijawab.

## Diputuskan dengan default

### Q1. `kit` belum ada: `{@catalog}`, CATALOG.md, WID002/UI005, `kit check` di CI
Brief 03 §6 mensyaratkan `{@catalog}` dan stress test per widget, yang di Phase 2 diperiksa `kit`. Acceptance roadmap berkata "minus kit check".
Default: tulis blok `{@catalog}` dan tes pemindai buatan sendiri sebagai pengganti WID002 (Req 1.4) dan UI005 (Req 12.5); tidak membuat `CATALOG.md` (Req 1.5); CI dan `sync_core` tidak memanggil `kit` (Req 17.7, 18.5).
Alternatif: menulis CATALOG.md tangan. Ditolak karena akan stale dan GEN002 di Phase 2 menganggap file itu hasil generate.

### Q3. Mason tersedia atau tidak
Dicek: `mason` 0.1.4 (`mason_cli`) ada di `PATH` (`~/.pub-cache/bin/mason`), core `mason` 0.1.3. Default: bricks diverifikasi sungguhan dengan `mason make` ke salinan sementara skeleton, lalu `build_runner`, `analyze`, dan tes hasilnya (Req 15.6-15.7). Tes dilewati dengan pesan jelas hanya bila `mason` tidak ada; CI memasang `mason_cli` versi terpasang (Req 18.7). Risiko: `mason make` menimpa/menambah berkas; tes memakai folder sementara. `mason-lock.json` di-commit.

### Q4. Daftar persis core widget di 03 §6.1
Tabel 03 §6.1 memuat 23 widget baru ditambah dua primitif yang sudah ada (`TactileSurface`, `Pressable`), jadi 25 nama (Req 1.1): primitive 2; action 3 (`AppButton`, `AppIconButton`, `AppPill`); input 4 (`AppTextField`, `SearchField`, `AppSegmented`, `ThemeModeSwitch`); content 4; feedback 5 (`EmptyState`, `ErrorView`, `LoadingView`, `SkeletonBlock`, `AppToast`+`ToastController`); overlay 2 (`AppDialog`+`showConfirm`, `AppSheet`); layout 5. Default: `ToastController` dan `showConfirm` bukan widget terpisah (ikut `AppToast` dan `AppDialog`, tanpa goldennya sendiri); `MinHitArea` dan `PressFill` adalah detail internal, tanpa blok katalog. Widget 03 §6.2 (Orbit/Tally) dan stretch tidak ikut. Penempatan `core/layout` untuk lima widget layout mengikuti 03 §4, meski tabel 03 §6.1 mencantumkannya sebagai "core widgets".
Catatan: `04` §7 memuat `AppChoiceList`/`AppChoiceTiles`/`Figure` dkk., semuanya sengaja di luar scope.

### Q7. Goldens hanya dibuat di Mac ini
Konsekuensi: CI tidak membandingkan (Req 18.7), tes golden gagal jelas di non-macOS (Req 11.4) alih-alih menimpa, goldens di-commit. Brief S9 (identik antar-run) belum pernah dijalankan; default: Req 11.7 meminta dua run berurutan menghasilkan piksel sama, dan bila tidak identik dilaporkan sebagai temuan (bukan ditutup-tutupi dengan toleransi).
Risiko: Mac lain (Apple Silicon vs Intel ini) bisa menghasilkan piksel sedikit beda; goldens dibuat di Mac Intel ini.

### Q8. Granularitas golden per widget
Default: satu gambar per widget per tema berisi galeri varian/state (Req 12.2), bukan satu berkas per varian. Total sekitar 25 x 2 = 50 gambar widget, 2 x 3 shell, 6 `HomeView`. Menjaga ukuran repo dan kemudahan review di 2x zoom. Alternatif per-varian memberi diff lebih halus tetapi ratusan berkas.

### Q9. Berkas `api/` dan `.kiro/steering/product.md` belum ada
`create_app` brief mereset file itu, tetapi kit/toolkit (Phase 2) yang membuatnya. Default: dilewati tanpa error bila tidak ada (Req 16.7).

### Q10. "Berjalan di web, Android, iOS, macOS" di acceptance 1
Mesin ini Intel Mac; lisensi Android SDK harus diterima user (catatan `skeleton-foundation` Q18); iOS butuh simulator/Xcode. Default: web dan macOS wajib diverifikasi dari app hasil `create_app` (build + run); Android dan iOS dicoba dan kegagalan dilaporkan dengan penyebabnya, tidak dianggap kegagalan spec bila penyebabnya toolchain (Req 16.13).

## Catatan konsistensi dengan yang sudah dibangun

- `lib/features/` kini ada: tes arsitektur (`architecture_test.dart:477`) menegaskan sebaliknya, jadi diubah (Req 13.11, 19.4). Pernyataan "tidak ada golden/stress" di `skeleton/README.md` dan `test/docs/readme_test.dart` ikut diperbarui (Req 11.8).
- `AppShell` jadi `AdaptiveScaffold` (menutup `TODO` dan jawaban Q1 di S1); `PlaceholderPage` mengganti tombol tema dengan `ThemeModeSwitch` (menutup `SEAM`).
- Penambahan string l10n wajib di `app_en.arb` dan `app_id.arb`; `arb_test.dart` menjaga keduanya sejajar.
- `kiri_check` 1.4.0 sudah terpasang; `stressProperty` memakainya (Req 9.8).
- `docs/brief/` tidak diubah. Brief 02 menyebut `bricks/` dan `mason.yaml` di `skeleton/` dan `tool/create_app.dart` di root repo; requirements mengikuti itu.
- Tidak ada `design.md` atau `tasks.md`; tidak ada commit atau push.
