# S5: perbaikan spec `core-widgets-and-templates` sesuai review R4

Tanggal: 2026-11-26. Berkas yang diubah: `.kiro/specs/core-widgets-and-templates/{requirements,design,tasks}.md`.
Tidak ada kode, `docs/brief/`, commit, atau push. Setiap klaim R4 dicek ke kode nyata di `skeleton/` sebelum diubah.

## Hasil verifikasi klaim reviewer terhadap kode

| Klaim | Bukti di kode | Hasil |
|---|---|---|
| BL1 `AppLayout` dari konstanta Dart, bukan `tokens.yaml` | `skeleton/tool/src/ladders.dart` `layoutTokens` (10 nilai); `generate_tokens_ladders_test.dart` menegaskan `[768,1200,800,1200,440,256,72,52,56,8]` | benar |
| BL2 `Duration(`, `Colors.`, `Color(0x`, `Curves.` dll. dilarang di luar `core/theme`; tidak ada token scrim | `architecture_test.dart:336-347` `_tokenLiterals`; `tokens.g.dart` `AppPalette` tanpa `scrim`; `motion.dart` berhenti di `d320` | benar |
| BL3 `TactileSurface` hanya `kind/radius/padding` | `surface.dart` konstruktor; fill dari `inner.fill`, shadow `SurfaceShadows.drop(inner)` | benar |
| BL4 `Pressable` disabled selalu `Opacity(0.6)` | `pressable.dart` `_disabledOpacity`, `Opacity` bila `onPressed == null` | benar |
| BL5 `Scaffold` di `app_shell.dart`; tes `'Material buttons and reserved names'` | `app_shell.dart:16`; `architecture_test.dart:637` | benar |
| BL6 kunci ARB sudah ada | `app_en.arb`: `themeSystem/Light/Dark`, tujuh pasang `failure*` | benar |
| BL7 satu tipe publik per berkas | `_typeFileRules`, `_typeExceptions` (MinHitArea di pressable.dart) | benar |
| BL8 `dart format .` di `check.dart`; `analysis_options.yaml` tanpa `bricks/` | `tool/check.dart` langkah format; `analysis_options.yaml` | benar |
| BL9 `app_test.dart` sudah memompa `App()` | `test/app/app_test.dart` `_pumpApp` | benar |
| SF1 `web_index_test` menegaskan `Skeleton`; README memuat path root | `web_index_test.dart:13,31-32` | benar |
| SF11 pemilih bahasa di placeholder, tes persistensi memakai `localeIndonesian` | `app_en.arb`, `app_test.dart:46-54` | benar |
| SF12 `arb_test.dart` dan `env_test.dart` memuat `checkConnection` | `arb_test.dart:47-48,68`; `env_test.dart` | benar |
| SF13 `context.inputMode` membaca `defaultTargetPlatform` | `window_class.dart:45` | benar |
| SF14c `.fvmrc` di `skeleton/`, bukan root | `skeleton/.fvmrc` ada, `../.fvmrc` tidak | benar |
| SF14a `*.freezed.dart` di-gitignore | `skeleton/.gitignore` | benar |
| Catatan: `tool/` root kosong | `ls ../tool` kosong; `create_app` belum ada | konsisten dengan spec |

Tidak ada klaim yang ditolak. Dua klaim tidak dijalankan (perilaku `IndexedStack` terhadap ticker SF4, nesting `flutter test` SF6); keduanya
diperlakukan sebagai risiko dan ditutup lewat tes di task (F3, H4) dan tag/timeout.

## Tabel butir R4 -> perubahan

| Butir | Perubahan | Berkas |
|---|---|---|
| BL1 | A5 tidak lagi memiliki `design/tokens.yaml`. Peta baru `overlayTokens` di `ladders.dart` dirender sebagai kelas `AppOverlay`; `layoutTokens` dan tes 20.4 tidak berubah; tes ladders diperbarui eksplisit. `sheetHandleHit` dipecah jadi `sheetHandleHitWidth/Height` (semua nilai satu `double`). Tabel File map dan D13 dikoreksi. | design D13, file map; tasks A5, lanes, shared files |
| BL2 | Durasi `d0/d400/d1000/d1200/d1500/d6000` ditambah di `motion.dart` (berkas tulis tangan, bukan hasil generator; ini menyimpang dari kata "lewat generator" pada keputusan: generator hanya relevan untuk kelas `AppOverlay` dan `scrim`). Token `scrim` per tema ditambah ke `AppPalette` lewat `tool/src/palette.dart`, tes palet diperbarui di A5. `barrierColor` tidak diisi. B4/F4/G2 memakai token itu. | design D13, Overlay, Action; tasks A5, B4, F4, G2 |
| BL3 | Opsi (b): D3 dan Req 2.10 ditulis ulang. Widget boleh `DecoratedBox` dengan fill palet dan shadow `surface.button()/primary()/toggle()/badge(hue)`; press/hover/focus tetap lewat `Pressable`. `TactileSurface`/`Pressable` tidak diubah. | requirements 2.10; design D3, B2, E4; tasks template W |
| BL4 | Solusi terkecil, perilaku lama utuh (D16): loading memakai `onPressed` no-op + `IgnorePointer`, tanpa redup; disabled tetap `Opacity(0.6)` milik `Pressable`; primary gelap disabled melukis ink-4/ink-8 sendiri lalu diredam 0.6 (sesuai brief 04 "disabled .6, dark primary turns solid ink-4/ink-8"). Tes menegaskan warna widget sendiri dan `Opacity` 0.6, bukan warna komposit. Tidak ada parameter baru di `Pressable`, jadi tidak ada task tambahan di lane P. | requirements 3.3; design D16, B2; tasks B2 |
| BL5 | A4 melarang `Scaffold` di `core/widgets`, `core/layout`, `features`, dan `app`, kecuali `adaptive_scaffold.dart` dan pengecualian bertanggal `app/router/app_shell.dart`; Z2 menghapus pengecualian dan menegaskan tidak tersisa. A4 menulis ulang tes `'Material buttons and reserved names'`. | tasks A4, Z2; design "Why the Pressable..." |
| BL6 | P1 hanya menambah `clear`, `close`, `dismiss`, `themeModeLabel`, `copied`, `tryAgain`. Aturan nama kunci `Loading` dicatat. Req 6.2 dan design Strings dikoreksi. | tasks P1; design Strings; requirements 6.2 |
| BL7 | `toast_request.dart` ditambah ke F4. Pemindai A3 dibatasi pada kelas inventaris; enum dan tipe pembantu serta `MinHitArea`/`PressFill` tidak butuh blok (D15, Req 1.3). | tasks A3, F4; design D15; requirements 1.3 |
| BL8 | `bricks/**` masuk `analyzer: exclude` (I1 memiliki `analysis_options.yaml`). `check.dart` memformat `lib test tool` (A2), karena `dart format` tidak punya exclude. Kedua file ikut tersalin ke app hasil `create_app`. | tasks A2, I1; design Bricks; requirements 15.6 |
| BL9 | `app_root_test.dart` dihapus dari A2. Bukti Req 11.6 adalah `app_test.dart` yang sudah ada; H5 menambah satu kasus `AdaptiveScaffold` di 390×844. | tasks A2, H5; design Golden setup; requirements 11.6 |
| BL10 | Depends: H4 + C2, D3, E4; D2 + B3; G2 + B3, D1; F4 tidak butuh B2 (aksi toast memakai `Pressable`, tanpa `Tooltip`). Diagram dependensi diperbarui. | tasks D2, G2, H4, diagram; design Sequencing |
| SF1 | J2 menulis ulang literal `web_index_test` di salinan dan mengganti `package: skeleton` di `brick.yaml`; `readme_test` dibatasi ke path dalam `skeleton/` (cek `tool/` root bersyarat). J5 mengakui kedua tes di acceptance. | tasks J2, J5, Z1; requirements 16.11 |
| SF2 | J4 mendaftar tiap tes yang menyebut home (routes, app, shell golden, arsitektur); aturan Z2 "home punya tiga lapis" bersyarat; string halaman minimal `appHomeEmptyTitle/Body`. | tasks J4, Z2; design create_app langkah 6; requirements 16.8 |
| SF3 | `AppToast({required controller, required child})`; `App` meneruskan `getIt<ToastController>()` (H5); tanpa `Tooltip`/`AppIconButton` di toast; `injection_test.dart` dimiliki F4. | design Feedback; tasks F4, H5; requirements 6.6 |
| SF4 | D14: `TickerMode(enabled: i == index)` per anak `feedbackCell`; tes F3 dan H4 (`pumpAndSettle` selesai); catatan README di Z1 diganti pada bagian risiko. | design D14, Feedback; tasks F3, H4 |
| SF5 | Angka ditetapkan: 8 kombinasi (ukuran, input) × 3 skala × 2 tema = 48 grup, 384 render. A1 menegaskan angka itu dan tidak adanya kebocoran state antar fixture. | requirements 9.3; design Profiles; tasks A1 |
| SF6 | `@Timeout(10 menit)` dan tag `slow` untuk `bricks_test`; `e2e` J4/J5 ber-timeout; skip bila `pub get` gagal karena jaringan. `slow` dideklarasikan di `dart_test.yaml` (A2). | requirements 15.7; design Bricks, Testing; tasks A2, I1, J4, J5 |
| SF7 | `git -c user.name=... -c user.email=... commit`; tes unit dengan runner palsu. | requirements 16.9; design create_app 7; tasks J5 |
| SF8 | `process_runner.dart` tetap milik J1; S2 Depends J1; tidak ada salinan kedua. | tasks S2, lanes, shared files |
| SF9 | D1: `AppTextField` mendapat `label` opsional (dengan `semanticLabel` wajib), slot `leading` dan `trailing`; `SearchField` memakainya. | design Input; tasks D1, D2 |
| SF10 | `pending` dihapus dari Z2 (tidak pernah didefinisikan; flag `strict` sudah cukup). Inventaris memetakan `LoadingView` dan `SkeletonBlock` ke `loading_view_test.dart` dan golden yang sama, primitif ke `test/core/theme/*_stress_test.dart`. | tasks A3, Z2 |
| SF11 | Dipertahankan sesuai keputusan konduktor. `LanguageSwitch` (fitur home, `AppSegmented<AppLocale>`), kunci `locale*` dan tes persistensi tetap; H5 menulis ulang finder tes. Req 13.4, 13.5, 13.10 disesuaikan. Tidak menambah widget core ke-26. | requirements Pengantar, 13.4, 13.5, 13.10; design Home; tasks H4, H5, H6 |
| SF12 | H6 memiliki `arb_test.dart` dan `env_test.dart`; kasus `checkConnection` diganti `themeDark` dan `tryAgain`. | tasks H6; design Home |
| SF13 | A1 menulis `test/helpers/fonts.dart` (`loadInterFont`), dipanggil `stressTest` dan dipakai ulang A2. Req 11.2 dikoreksi: `ThemeData.platform` dan `debugDefaultTargetPlatformOverride`. | requirements 9.7, 11.2; design Stress 7, Golden; tasks A1, A2 |
| SF14 | (a) `dart run tool/generate_tokens.dart` sebelum `git diff`; (b) `spike-pages.yml` dibandingkan dengan SHA-256 tetap `ca14a184...d46d5` (dihitung sekarang, commit terakhir `ec47d7e`); (c) jalur `skeleton/.fvmrc`. | requirements 18.2; design CI; tasks K1 |
| N3 | Req 5.3 menjadi 38 (44 mobile). Catatan G1 (drag kustom vs "MVP drag-to-dismiss" di brief) tidak diubah: sudah ada di design dan tidak bertentangan dengan AC. | requirements 5.3 |
| N7 | Req 9.8 mengizinkan jalur fallback A7 bila spike gagal, dengan catatan README. | requirements 9.8 |
| N8 | `shortcut:` `sync_core` tidak memperbarui inventaris target; dicatat di design, S2, dan Z1. | design sync_core; tasks S2, Z1 |
| N1 | Salah ketik `hue.s3` diperbaiki menjadi `context.hue(role).s3` (E4, design). | design Content; tasks E4 |
| N2, N4, N5, N6, N9 | Tidak perlu perubahan (verifikasi positif atau risiko yang sudah dicatat). | n/a |
| Saran R4 no. 4 | Task baru A8 "Compile check of the public API": stub tanda tangan diganti ke file scratch, `flutter analyze`, perbaiki design, hapus scratch, laporan `S5-A8.md`. Semua task B-G Depends A8. | tasks A8, lanes; design "API compile check" |
| Aturan append ARB (R4 butir 2 "Urutan dan berkas bersama") | Aturan "append key" dihapus; lane lain melapor ke lane P. Regenerasi `injection.config.dart` oleh F4, H2, H3, H5 digabung satu per satu. | tasks shared files; design |

## Hitung ulang

- Task: 61 (sebelumnya 60). Terdiri dari 57 `[kode]`/`[dok]` dan 4 `[manual]` (M1-M4). Tambahan satu: A8. Tidak ada task "A5b" karena BL3 memakai opsi (b) dan BL4 tidak menyentuh `Pressable`. Hitung `grep -c "^- \[ \]" tasks.md` = 61, manual = 4.
- Acceptance criteria: 153 (tidak berubah; perubahan dilipat ke AC yang ada, tidak ada AC baru). Requirement: 19.

## Keterlacakan 153 AC ke task (diperiksa ulang)

Diperiksa dengan skrip kecil `/tmp/trace.py` yang membaca `_Requirements:_` setiap task dan menghitung AC dari `requirements.md`.
Hasil: 153 AC, 0 tanpa task, 0 rujukan ke AC yang tidak ada. Tiga AC yang sebelumnya hanya tersirat sekarang dirujuk eksplisit:
1.1 dan 1.2 (A3, inventaris dan lokasi 25 widget) dan 2.3 (A4, aturan bobot huruf yang sudah ada di tes arsitektur). Untuk rentang (mis. 9.1–9.7) tiap AC dihitung tercakup oleh task yang menyebut rentang itu.
Catatan: ini keterlacakan formal (task menyebut AC). Kesesuaian isi acceptance tiap task dengan AC sudah ditinjau untuk butir yang disentuh R4, bukan ulang untuk seluruh 153.

| Requirement | AC | Task utama |
|---|---|---|
| 1 | 1.1-1.6 | A3, Z1, Z2, tiap widget |
| 2 | 2.1-2.10 | A4, A5, template W, B1-G2 |
| 3 | 3.1-3.9 | B2, B3, B4, C4 |
| 4 | 4.1-4.8 | D1-D4 |
| 5 | 5.1-5.7 | E1-E4 |
| 6 | 6.1-6.7 | F1-F4, B4 |
| 7 | 7.1-7.7 | G1, G2, A4 |
| 8 | 8.1-8.8 | C1-C5, H5 |
| 9 | 9.1-9.10 | A1, A7 |
| 10 | 10.1-10.3 | A6 |
| 11 | 11.1-11.8 | A2, H5, Z1 |
| 12 | 12.1-12.6 | B1-G2, A3, H7, M1, Z2 |
| 13 | 13.1-13.11 | H1-H6, Z2 |
| 14 | 14.1-14.7 | H1-H4, H7, Z1 |
| 15 | 15.1-15.8 | I1-I6, Z1 |
| 16 | 16.1-16.13 | J1-J5, M2, Z3 |
| 17 | 17.1-17.8 | S1, S2 |
| 18 | 18.1-18.10 | K1, K2, M4 |
| 19 | 19.1-19.7 | Z1-Z3, K1 |

## Celah tersisa

1. Butuh user: tidak ada. Semua pilihan produk terjawab oleh keputusan konduktor (BL3 b, SF11 pertahankan, SF6, BL2).
2. Penyimpangan kecil dari keputusan BL2: durasi (`d1000`, `d1500`, `d6000`) ditambah ke `motion.dart` tulis tangan, bukan generator, karena `motion.dart` memang tidak dihasilkan generator. Token ukuran dan `scrim` lewat generator sesuai keputusan. Konduktor perlu tahu bila ingin sebaliknya.
3. Pemilihan nama `AppOverlay` untuk kelas token baru adalah keputusan saya; A8 akan menguji apakah nama itu bertabrakan.
4. Warna komposit primary gelap disabled (ink-4/ink-8 lalu 0.6) tidak diuji sebagai satu warna; hanya komponennya. Bila user menghendaki warna akhir persis ink-4/ink-8, butuh `disabledOpacity` di `Pressable` (kode foundation).
5. Tidak dijalankan: `flutter analyze`/tes (spec saja, tidak ada kode). Perilaku `IndexedStack` + `TickerMode`, nesting `flutter test`, dan `kiri_check` dengan `WidgetTester` tetap belum terbukti. A8 dan A7 yang membuktikan.
6. `LanguageSwitch` menambah satu widget fitur di home; di app `--clean` ia ikut terhapus dan tes persistensi harus mengandalkan cubit langsung (dicatat di J4).
7. Brief 04 baris 124 vs 266 tentang tinggi baris (36 vs 38) tidak saya ubah (docs/brief dilarang); spec mengikuti kode (38).
