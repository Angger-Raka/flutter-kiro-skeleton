# S1: tinjauan requirements `skeleton-foundation`

Tanggal: 2026-11-24. Pengganti "Analyze Requirements" (IDE kena rate limit). Berkas yang ditinjau:
`.kiro/specs/skeleton-foundation/requirements.md` (24 requirement). Dibandingkan dengan `docs/brief/` (02, 03, 04, 11),
`P1-prep.md`, dan draft `design.md`. Tidak ada keputusan yang saya tebak: yang belum ada di brief ditandai pertanyaan,
dan requirements merujuknya dengan `(see Q#)`. Isi di bawah memakai bahasa Indonesia; istilah teknis tetap Inggris.

Ringkasan: 21 pertanyaan terbuka. Prioritas **Tinggi** (memengaruhi acceptance atau scope): Q1, Q2, Q4, Q13. Sisanya sedang atau rendah.

## A. Konflik dan celah antara brief, roadmap, dan draft design

### Q1. "Adaptive shell" di acceptance vs `AdaptiveScaffold` di luar scope (Tinggi)
Acceptance roadmap: skeleton berjalan "with the adaptive shell". Prompt pembuka menaruh `AdaptiveScaffold` dan layout
widget lain di spec `core-widgets-and-templates` (03 §6.1: kategori layout), tetapi 03 §4 mencantumkan
`core/layout/adaptive_scaffold.dart` di `core/layout/`, dan prompt pembuka menyebut `core/layout` dalam scope. Draft
design memilih `AppShell` berupa `Scaffold` tipis dan menunda `AdaptiveScaffold`.
Opsi:
- A. Ikuti draft design: `AppShell` tipis yang hanya mengikuti `WindowClass`/`InputMode` (tema dibangun ulang). "Adaptive" = tema/ukuran, tanpa rail atau tab bar.
- B. Bangun `AdaptiveScaffold` (rail + panel + tab bar, 04 §7) di spec ini. Memenuhi kata "adaptive shell" secara literal, tetapi memperlebar scope dan memindahkan pekerjaan dari spec berikutnya.
- C. Bangun versi minimal: rail ikon di tablet/desktop dan tab bar bawah di mobile, tanpa floating panel dan top strip.
Rekomendasi: A, lalu ubah kalimat acceptance di requirements 24.8 menjadi "shell bereaksi terhadap window class". Alasan: prompt pembuka eksplisit menyebut widget lain di luar scope; `AdaptiveScaffold` ada di daftar 03 §6.1 (spec berikutnya). Perlu konfirmasi karena acceptance roadmap bisa dibaca B. Req 20.6, 21.6, dan 24.8 saat ini mengikuti A.

### Q2. Cara pengguna mengganti tema di Phase 1 (Tinggi)
Acceptance menuntut tema dapat diganti System/Light/Dark dan bertahan setelah restart. `ThemeModeSwitch` (dan
`AppSegmented` yang dipakainya) milik `core-widgets-and-templates`, dan `home` juga di luar scope. Tanpa kontrol, acceptance
tidak bisa diuji.
Opsi:
- A. Halaman placeholder berisi kontrol sementara dari `Pressable` + `TactileSurface` (tiga tombol System/Light/Dark, dan dua untuk locale), diberi tanda seam untuk diganti `ThemeModeSwitch`.
- B. Pakai `SegmentedButton` Material di placeholder, dengan catatan sementara. Melanggar aturan TAC001 secara semangat, tetapi cepat.
- C. Tombol hanya saat debug (`kDebugMode`). Tidak memenuhi uji di APK rilis.
Rekomendasi: A. Memakai primitive spec ini dan menunjukkan fondasi tactile bekerja. Req 21.7 mengikuti A.

### Q3. Sumber data Radix_Scales (Sedang)
04 §4.3: tidak ada nilai warna diketik tangan; data dihasilkan `fetch_radix.dart` dari `radix-ui/colors` commit `dbdb854`
(milik spec `kit-check-tokens`). Prompt Phase 1: "checked-in Radix scales for sand, slate, blue, green, red, amber".
Draft design menaruhnya di `tool/radix/radix_scales.dart`, tanpa menyebut cara memperolehnya.
Opsi:
- A. Skrip kecil sekali jalan yang mengambil `light.ts`/`dark.ts` di commit `dbdb854` untuk enam skala, hasilnya di-commit, plus catatan asal dan lisensi MIT di `THIRD_PARTY_NOTICES.md` (sudah memuat Radix, perlu dicek).
- B. Salin nilai dari paket pub `radix_colors` bila ada.
- C. Ketik tangan. Melanggar 04 §4.3.
Rekomendasi: A. Req 13.2 mensyaratkan "bukan ketik tangan"; sumbernya belum ditetapkan. Perlu juga diputuskan apakah skrip pengambil ikut di-commit (rekomendasi: ya, `tool/radix/fetch_scales.dart`, tanpa dependensi baru).

### Q4. Bukti "release APK reaches the network" (Tinggi)
Tidak ada endpoint atau layar yang memanggil jaringan di spec ini (tanpa fitur). Perlu cara menguji.
Opsi:
- A. Placeholder memuat satu tombol "Check connection" yang memanggil `ApiClient` ke URL dari `Env` (mis. `HEALTH_URL` di `env/example.json`) dan menampilkan hasil (sukses/`Failure`).
- B. Uji manual sekali: `flutter build apk --release`, pasang, lalu lihat log DNS/HTTP lewat `adb logcat`. Tanpa kode UI.
- C. Panggilan otomatis saat startup yang dicatat di log. Menambah efek samping di bootstrap.
Rekomendasi: A dengan URL default yang aman dan publik (perlu Anda tentukan, mis. `https://example.com`). Alternatif B bila ingin tanpa UI. Req 3.5 dan 24.9 mengikuti A, bergantung pada keputusan URL.

### Q13. Cakupan tes, termasuk PBT (Tinggi)
Prompt pembuka melarang "test harness" (stress/golden), tetapi 01 §success dan design mengharapkan `flutter test` hijau.
Draft design punya 20 correctness properties dan memakai `kiri_check` (03 §2, S10), namun `kiri_check` tidak ada di daftar
dependensi draft. Roadmap menandai spec ini tanpa label PBT (hanya `kit-check-tokens` yang ber-label PBT).
Opsi:
- A. Unit/bloc test untuk logika inti (daftar di req 23.4), tanpa PBT. Properti pada draft tetap menjadi contoh uji berbasis tabel.
- B. A ditambah PBT dengan `kiri_check` untuk properti 1–10, 17–18 (settings, mapper, blur, window class). Menambah satu dev dependency.
- C. Semua 20 properti sebagai PBT. Terlalu besar untuk 2 hari (19–20 Nov sudah lewat).
Rekomendasi: B. Murah untuk logika murni, dan menunjukkan PBT lebih awal. Req 23.4 dan 23.5 saat ini menyebut A dengan PBT sebagai tambahan bersyarat; perlu kalimat final.

## B. Hal yang belum ditentukan

### Q5. Registrasi font Space Grotesk dan Plus Jakarta Sans di `pubspec.yaml` (Sedang)
Berkasnya sudah ada, tetapi `typography.heading: null` secara default dan fontnya baru dipakai bila app mengganti tokens.
Opsi: A. Daftarkan hanya Inter. B. Daftarkan ketiganya. Rekomendasi: A pada `pubspec.yaml` skeleton (aplikasi yang memilih heading face
menambahkan entri; ukuran bundle lebih kecil), dan berkas lain dibiarkan di folder. Namun spike tipografi (S21: x-height, tabular figures) belum
dijalankan, jadi `size_factor` untuk dua font lain belum diketahui. Req 17.7 mengikuti A.

### Q6. Redaksi data sensitif di Logger (Rendah)
Bukan ada di brief/draft; saya menambah req 6.6 karena `debugPrint` tidak ter-strip di rilis. Opsi: A. Pertahankan. B. Hapus dari spec ini dan tunda ke feature API.
Rekomendasi: A, biaya kecil (satu fungsi redaksi untuk header `Authorization`). Mohon konfirmasi karena ini penambahan di luar brief.

### Q7. Locale perangkat yang tidak didukung (Rendah)
Brief: locale `system | en | id`. Tidak jelas apa yang dipakai saat perangkat berbahasa lain. Rekomendasi: jatuh ke `en`
(template ARB). Req 10.4 mengikuti ini.

### Q8. Isi ARB (Rendah)
Foundation tidak punya fitur; string apa yang ada? Draft design: "hanya string fondasi". Rekomendasi: label placeholder, label kontrol tema/locale
(System, Light, Dark; English, Indonesia), pesan `Failure` dua baris (03 §5: `ErrorView` memetakan tiap `Failure`, tetapi `ErrorView` milik spec lain; teksnya cukup menunggu),
dan label tombol cek koneksi (Q4). Req 12.3 menyatakan "hanya yang dipakai fondasi".

### Q9. `json_serializable`/`json_annotation` ikut atau tidak (Rendah)
Open item di draft. Rekomendasi: tunda ke fitur pertama (tidak ada DTO). Req 2.5 meminta README mencatat pilihan.

### Q10. Berkas generated dan lockfile di-commit? (Sedang)
`tokens.g.dart` wajib di-commit (02 `.gitignore`). Brief diam soal `injection.config.dart`, `*.freezed.dart`, `*.g.dart` lain, dan `pubspec.lock`;
`create_app` memang mengecualikan `pubspec.lock` saat menyalin, tetapi itu soal app, bukan skeleton.
Opsi: A. Commit semua generated + lockfile skeleton (agen bisa membaca dan CI tidak butuh build_runner). B. Ignore generated kecuali `tokens.g.dart`.
Rekomendasi: A untuk lockfile dan `injection.config.dart`; B untuk `*.freezed.dart`. Setengah-setengah ini perlu persetujuan. Req 2.6 dan 7.5 mengikuti rekomendasi.

### Q11. Lokasi Logger (Rendah)
Draft memakai `core/log/logger.dart`, sedangkan 03 §4 tidak mencantumkan `core/log/` (hanya menyebut "core `Logger`" di §5). Rekomendasi: pakai `core/log/` dan
catat di README sebagai penyimpangan kecil (req 22.5).

### Q12. Reset DI untuk tes (Rendah)
Req 7.4 saya tambahkan agar `configureDependencies()` dapat dipanggil ulang di tes. Opsi: A. Pertahankan (`getIt.reset()` helper). B. Hapus; tes memakai instance sendiri.
Rekomendasi: A.

### Q14. Windows dan Linux (Rendah)
`flutter create` membuat enam platform, tetapi acceptance hanya empat dan mesin ini macOS. Rekomendasi: folder dibuat dan dipertahankan tanpa dibangun;
`create_app` nanti perlu ID bundle untuk keduanya (02). Req 24.10 mengikuti ini. Apakah "Display name Skeleton" juga diterapkan di Windows/Linux (req 1.3)? Rekomendasi: ya, kalau hanya perubahan teks.

### Q15. Lokasi `.fvmrc` (Sedang)
Brief 03 §2 menyebut `.fvmrc included` pada skeleton; P1-prep menulis "belum ada". Rekomendasi: `skeleton/.fvmrc` (ikut tersalin oleh `create_app`), bukan di root repo.
Perlu juga memutuskan apakah repo root punya `.fvmrc` untuk spikes (di luar spec).

### Q16. Penyimpangan 3.50 vs 3.44.8 (Rendah)
Disetujui; brief tidak diubah. Catatan: 03 §2 menyatakan "pin exact versions … latest stable at that time". 3.44.8 mungkin bukan versi terbaru saat ini, tetapi itulah yang terpasang dan teruji (P1-prep §3). Tidak perlu tindakan; dicatat agar README menjelaskan alasannya.

### Q17. Hue identitas dan skala yang belum ada (Sedang)
`tokens.yaml` default memuat `identity: [cyan, violet, plum, pink, lime, purple]`, tetapi hanya enam skala yang di-check-in (sand, slate, blue, green, red, amber)
dan draft menyatakan hue tak dikenal = error. Berarti `identity` harus kosong di Phase 1 atau skalanya ditambah. Opsi: A. `identity: []` di Phase 1 dan `kit tokens` menambahkannya
(rekomendasi, sesuai prompt pembuka yang menyebut enam skala). B. Tambah enam skala. Req 13.1 tidak menyebut identity (mengikuti A).

### Q18. Android SDK license (Sedang, prasyarat)
P1-prep: lisensi Android berstatus unknown. `flutter build apk --release` akan gagal sampai `flutter doctor --android-licenses` dijalankan (menyentuh luar repo, tindakan Anda).
Req 24.9 bergantung ini. Rekomendasi: jalankan sebelum tahap implementasi.

### Q19. SurfaceScope tanpa leluhur (Rendah)
Req 15.9 (perilaku default saat tidak ada `TactileSurface`) saya tambahkan, tidak ada di brief. Opsi: A. Default ke scope `panel` dari tema aktif. B. Assert/throw.
Rekomendasi: A, supaya widget tidak crash di tes. Perlu konfirmasi karena menetapkan perilaku baru.

### Q20. Skala press dan batas minSdk/iOS target (Rendah)
Req 16.1 memakai "value configured" karena brief hanya menyebut `.97` untuk tombol dan `.92/.94` untuk ikon (04 §7), tanpa nilai bawaan `Pressable`. Rekomendasi: parameter wajib, tanpa default.
Versi minimum Android (`minSdk`) dan iOS tidak ditentukan brief; rekomendasi: ikuti default template Flutter 3.44.8 dan catat di README.

### Q21. Kriteria yang sulit diuji secara otomatis (informasi)
Tidak butuh keputusan, hanya tanda: req 14.8 (perbandingan blur dengan tangkapan browser, S16) dan 24.1–24.9 diverifikasi manual, bukan lewat tes;
req 12.6 dan 22.4 (copy rules, tanpa literal warna) baru dapat dicek otomatis setelah `kit check` (Phase 2), jadi di spec ini diperiksa lewat tinjauan/`grep`.
Rekomendasi: tulis task verifikasi manual terpisah di `tasks.md` untuk 24.x dan 14.8.

## C. Konsistensi dengan draft `design.md`

- Draft sudah selaras dengan requirements pada: scope (§Overview), `AppShell` tipis, urutan build, error handling, 20 properti.
- Perlu disesuaikan setelah jawaban: Q1 (AppShell vs AdaptiveScaffold), Q2/Q4 (placeholder page tidak ada di draft; `_RootPlaceholder` hanya kerangka), Q10 (draft tidak menyebut commit generated), Q13 (`kiri_check` tidak ada di tabel Dependencies draft), Q17 (draft mengasumsikan hue tak dikenal = error).
- Draft menandai "mechanism is the implementer's choice" untuk theme builder per window class; requirements 19.4 hanya mewajibkan perilaku.
- design.md tidak diubah.
