# R4: review independen spec `core-widgets-and-templates`

Tanggal: 2026-11-26. Reviewer read-only. Yang ditinjau: `.kiro/specs/core-widgets-and-templates/{requirements,design,tasks}.md`
dan `spikes/crew-run/S4-spec-check.md`, terhadap `docs/brief/` (02, 03 §5-§7, 04 §7/§11/§12, 10) dan kode nyata di `skeleton/`
(HEAD `7649eb0`). Tidak ada spec, kode, atau commit yang diubah. Satu-satunya perintah yang mengeksekusi sesuatu:
`flutter test --exclude-tags golden,e2e test/core/utils/debouncer_test.dart` (lulus, bukti sintaks tag di bawah).

Rujukan baris `tasks.md:N` adalah baris judul task. `design.md:N` adalah baris isi.

## Ringkasan

| Kategori | Jumlah |
|---|---|
| Blocker | 10 |
| Should-fix | 14 |
| Note | 9 |

S4 menyatakan "0 pemblokir". Itu tidak benar: S4 sendiri mencatat "tanda tangan API belum dicompile dan token baru A5 belum
diverifikasi terhadap generator" (S4, bagian "Yang tidak diperiksa"), dan di sinilah blocker 1, 2, 3, 4 dan 6 ditemukan.
Hitungan dasar S4 benar: 60 task (8 P/A, 23 widget, 29 sisanya) dan 153 AC (dihitung ulang per requirement).

---

## Blocker

### BL1. A5 salah soal tempat token; tes yang ada akan merah (`tasks.md:134`, `design.md:45`)

`AppLayout` tidak dibangkitkan dari `design/tokens.yaml`. Nilainya adalah konstanta Dart di `skeleton/tool/src/ladders.dart:55`
(`layoutTokens`). `tokens.yaml` hanya punya kunci tetap (`version, language, neutral, surface_top, hues, primary, typography,
radius_control, contrast, overrides`) dan `knobs.dart` melempar `KnobsException` untuk kunci tak dikenal. Selain itu
`test/tool/generate_tokens_ladders_test.dart:22` ("AppLayout matches requirement 20.4 exactly") menegaskan daftar tepat
`[768, 1200, 800, 1200, 440, 256, 72, 52, 56, 8]`. Menambah 11 token ke `layoutTokens` membuat tes itu gagal, padahal A5 menulis
"Existing tests stay green".
Perbaikan: ubah A5 menjadi "tambah peta baru (mis. `overlayTokens`) di `tool/src/ladders.dart`, render `AppLayout`/kelas baru, dan
perbarui `generate_tokens_ladders_test.dart` secara eksplisit". Hapus `design/tokens.yaml` dari Owns A5 dan dari D13/File map.
`sheetHandleHit (88 × 44)` adalah dua nilai: pecah jadi `sheetHandleHitWidth` dan `sheetHandleHitHeight`, karena generator hanya
mengeluarkan `double`.

### BL2. A5 tidak memuat token yang dibutuhkan widget; arsitektur 22.4 memblokir B4, F4, G2 (`tasks.md:134`, `183`, `290`, `303`)

Aturan arsitektur `_noRawTokensOutsideTheme` (`architecture_test.dart`, `_tokenLiterals`) melarang `Duration(`, `Colors.`, `Color(0x`,
`Color.fromARGB(`, `Curves.`, `Interval(`, `Cubic(` di luar `core/theme`. Daftar A5 hanya menambah `d0`, `d400`, `d1200`
(`motion.dart` sekarang berhenti di `d320`). Yang kurang:
- 1,5 s dan 1,0 s tick `AppPill.copy` (B4), 6 s dismiss toast (F4): perlu `d1000`, `d1500`, `d6000` (atau nama setara).
- Backdrop dialog hitam 30 % terang / 90 % gelap (G2, Req 7.2): tidak ada token warna scrim di `AppPalette`
  (`tokens.g.dart:9-67`: tidak ada `scrim`/`backdrop`). Widget tidak boleh menulis `Color(0x...)` atau `Colors.black`.
- `barrierColor: transparent` di `design.md:331` memakai `Colors.transparent` (dilarang). Cukup tidak mengisi `barrierColor`.
- Aturan "lane minta ke lane P lewat laporan" (`tasks.md:54-57`) membuat lane B/F/G berhenti menunggu A5 ulang.
Perbaikan: perluas A5 dengan `AppMotion.d1000/d1500/d6000` dan token scrim per tema (perlu perubahan generator palet dan tes palet,
jadi bukan sekadar baris di `ladders.dart`). Atau putuskan eksplisit bahwa `Color.from(alpha:...)` boleh (tidak ada di
`_tokenLiterals`), tetapi token lebih sesuai D13.

### BL3. `TactileSurface` tidak bisa memberi fill/shadow per peran; D3 dan Req 2.10 bertentangan dengan B2, E4, D3, B4 (`design.md:35`, `160`)

API nyata: `TactileSurface({required kind, required child, radius, padding})` (`surface.dart:175-196`). Fill hanya dari `SurfaceKind`
dan shadow hanya `SurfaceShadows.drop(inner)` per kind (`raised` selalu shadow `card`, `surface.dart` + `shadows.dart:96-100`).
Padahal design meminta:
- Primary: `palette.primaryBg` + `surface.primary()`; destructiveConfirm: `danger.s9` (B2).
- Secondary: `surface.button()`; toggle pill `surface.toggle()` (D3); badge `hue.s3` + `surface.badge(hue)` (E4).
- Skeleton alpha a3/a4 (F3), track segmented (D3).
Tidak satu pun bisa lewat `TactileSurface` tanpa mengubahnya, sedangkan A3 hanya boleh mengubah "doc comment" `surface.dart`.
`design.md:160` menulis "`TactileSurface`-like fill", yang berarti widget menggambar sendiri dan melanggar D3 ("No widget paints its own ... surface") serta
Req 2.10. Hover `Pressable` juga memakai `scope.hoverFill` (ink), bukan `palette.primaryHover`.
Perbaikan (pilih satu, putuskan sebelum task B):
(a) Tambah task lane P "A5b": `TactileSurface` mendapat parameter opsional `fill`, `shadows`, `border`, dan `Pressable` mendapat
    `hoverFill` opsional, dengan tes dan tanpa mengubah perilaku default (preserve behaviour). Update Owns A3/B1.
(b) Ubah D3 dan Req 2.10: widget boleh memakai `DecoratedBox` dengan fill dari `context.surface`/`palette` dan shadow dari
    `surface.button()/primary()/toggle()/badge()`, selama press/hover/focus tetap lewat `Pressable`.
Rekomendasi: (b), karena (a) menyentuh kode foundation yang sudah ditinjau (R3), lebih kecil risikonya, dan arsitektur tes tetap lolos.

### BL4. `AppButton` loading "tanpa redup" mustahil dengan `Pressable` yang ada (`design.md:771`, `tasks.md:168`)

`Pressable` dengan `onPressed: null` selalu membungkus `Opacity(0.6)` (`pressable.dart`, `_disabledOpacity`) dan tidak punya parameter
untuk mematikan itu. Design: "ignored (`onPressed: null` to `Pressable` while keeping the loading look at full opacity)". Tidak
bisa. Selain itu dark primary disabled ("solid ink-4, teks ink-8", Req 3.3) ditumpuk dengan 60 % opacity `Pressable`: hasil warna
bukan ink-4/ink-8 murni, jadi AC B2 yang menguji warna akan gagal atau diuji pada warna yang salah.
Perbaikan: loading memakai `onPressed: () {}` no-op dengan `IgnorePointer`/guard `_loading` di handler (fill hover tetap ada, jadi
bungkus `ExcludeSemantics`/`IgnorePointer` di luar `Pressable`), atau tambah `disabledOpacity` opsional di `Pressable`. Tulis di
B2 bahwa dark primary disabled tidak dipengaruhi opacity (`Pressable(disabledOpacity: 1)` atau warna dikoreksi agar hasil akhir ink-4/ink-8).

### BL5. A4 menolak `Scaffold` di `lib/app` sehingga tes arsitektur merah sampai H5 (`tasks.md:125`)

A4: "`Scaffold` allowed only in `adaptive_scaffold.dart`" dan aturan Material diperluas dari `app` ke `core/widgets`, `core/layout`,
`features`. `lib/app/router/app_shell.dart:16` hari ini adalah `Scaffold(body: SafeArea(...))` dan baru diganti di H5, jauh
setelah A4. Acceptance A4 ("passes on the current tree") tidak terpenuhi. Selain itu, `architecture_test.dart:637` punya tes
`'Material buttons and reserved names'` yang memanggil `_noReservedDeclarations`; A4 harus menulis ulang tes itu juga (tidak disebut).
Perbaikan: A4 melarang `Scaffold` hanya di `core/widgets`, `core/layout`, `features`, dan `app` kecuali `app/router/app_shell.dart`
dengan alasan "diganti H5". H5 menghapus pengecualian itu (H5 Owns mencakup `test/architecture`? Tidak: tambahkan, atau
biarkan A4 menaruh pengecualian bertanggal dan H1 yang menghapusnya sebab H1 sudah memiliki berkas itu).

### BL6. P1 mengulang kunci ARB yang sudah ada (`tasks.md:84`, `design.md` bagian Strings)

`lib/core/l10n/app_en.arb` sudah memuat `themeSystem`, `themeLight`, `themeDark`, dan seluruh pasangan `failure<Name>Title/Body`
untuk ketujuh subtype (`Network, Unauthorized, NotFound, Validation, Server, Cache, Unexpected`). P1 menyuruh menambahkan
`themeSystem/Light/Dark` dan pasangan "for each Failure subtype that has none yet", dan menyebut `Unauthorized, NotFound, ...`
sebagai yang belum ada. Kunci ganda membuat `flutter gen-l10n` gagal (duplicate key) atau menimpa teks.
Perbaikan: P1 hanya menambah `clear`, `close`, `dismiss`, `themeModeLabel`, `copied`, `tryAgain`. Koreksi juga design Strings dan Req 6.2.
Catatan terkait: `arb_test.dart` mewajibkan kunci berakhiran `Loading` atau berawalan `loading` berakhir "…"; pakai nama
kunci yang tidak memicu aturan itu untuk label non-loading.

### BL7. `toast_controller.dart` memuat dua tipe publik; pemindai katalog menolak tipe pembantu (`design.md:305-310`, `tasks.md:114`, `290`)

`design.md` mendeklarasikan `ToastController` dan `ToastRequest? get current`. Aturan arsitektur 22.3 ("one public type per file", `_typeFileRules`)
gagal bila `ToastRequest` publik berada di berkas yang sama. F4 Owns tidak mencantumkan `toast_request.dart`. Hal yang sama
berlaku untuk pemindai A3: ia mensyaratkan satu blok `{@catalog}` "untuk setiap kelas publik" di `core/widgets` dan `core/layout`,
tetapi D1 sengaja menambah tipe pembantu publik (`AppButtonSize`, `ActionGroupGap`, `AppSegment`, `AdaptiveDestination`,
`ToastController`, `ToastRequest`) yang bukan widget dan tidak ada di inventaris 25 nama. Pemindai akan merah pada tree nyata
begitu tipe-tipe itu ada, atau memaksa blok katalog palsu.
Perbaikan: tambah `lib/core/widgets/toast_request.dart` di Owns F4. Definisikan lingkup pemindai di A3: hanya kelas inventaris
(atau subclass `Widget`/`State`), dan beri pengecualian eksplisit untuk enum dan kelas data pembantu.
Juga: `pressable.dart` memuat `MinHitArea` publik (pengecualian di `_typeExceptions`); A3 harus menyebut bahwa `MinHitArea` dan `PressFill` tidak butuh blok.

### BL8. Brick `__brick__/*.dart` merusak `dart format .` dan `flutter analyze`; tidak ada task yang mengurus (`tasks.md:366`, `design.md` bagian Bricks)

`tool/check.dart` menjalankan `dart format --set-exit-if-changed .` dan `flutter analyze` dari akar `skeleton/`. Berkas template
Mason berekstensi `.dart` berisi `{{name.snakeCase()}}`, bukan Dart valid: `dart format` keluar dengan kode 65 dan analyzer melaporkan
error sintaks. `analysis_options.yaml` (exclude hanya `*.g.dart`, `*.freezed.dart`, `injection.config.dart`, `app_localizations*`)
tidak dimiliki task mana pun; I1 tidak memilikinya, dan gerbang G ("format, analyze zero issue") jadi merah mulai I1.
Perbaikan: I1 Owns tambah `analysis_options.yaml` (`exclude: bricks/**`) dan `tool/check.dart` (ubah langkah format menjadi
`dart format --set-exit-if-changed lib test tool`), atau simpan template dengan ekstensi `.dart.mustache`-aman (mason mendukung nama
bebas, tetapi isi tetap harus diberi ekstensi bukan `.dart`). Perlu juga untuk `create_app`: salinan `bricks/` ikut terkena.

### BL9. A2 membuat `app_root_test.dart` yang mencari `AdaptiveScaffold` sebelum widget itu ada (`tasks.md:103`, `design.md` bagian Golden setup)

A2 (urutan ke-3) memiliki `test/app/app_root_test.dart` yang "finds the page" dan design menulis `find.byType(AdaptiveScaffold)`.
`AdaptiveScaffold` baru ada di C5 dan dipakai di H5, jadi tes tidak bisa dikompilasi atau lulus di A2. Selain itu
`test/app/app_test.dart` sudah memompa `App()` dengan router nyata (`_pumpApp`), jadi Req 11.6 secara substansi sudah terpenuhi;
H5 juga memiliki `test/app/**`, sehingga dua task memiliki folder yang sama (celah #13 di S4 mengakuinya sebagai "risiko kecil").
Perbaikan: hapus `app_root_test.dart` dari A2. Penuhi Req 11.6 dengan tes root yang sudah ada (`app_test.dart`) dan, di H5,
tambahkan satu kasus yang menegaskan `AdaptiveScaffold` pada `App()` di 390×844. Catat di Req 11.6 bahwa `app_test.dart` adalah buktinya sampai H5.

### BL10. Dependensi task tidak lengkap: urutan ini membuat kompilasi gagal (`tasks.md:229`, `303`, `335`)

Tiap Depends dicek terhadap API yang dipakai design:
- H4 memakai `PageColumn.data` (C2) dan `AppBadge` di `HomeSummaryTile` (E4), tetapi Depends H4 hanya `H3, B2, C4, C5, D4, E2, E3, F1, F2, F3`.
- D2 `SearchField` memakai `AppIconButton` untuk tombol clear (`design.md` bagian Input) tetapi Depends hanya D1 (B3 tidak ada).
- G2 `AppDialog` memakai `AppIconButton` untuk "×" (B3) dan butuh field untuk "first field focused" (D1); Depends hanya `G1, B2, C4`.
- F4 aksi toast kemungkinan `AppButton` (B2); Depends hanya A6.
Perbaikan: tambah C2, E4 ke H4; B3 ke D2 dan G2; D1 ke G2; B2 ke F4 (atau nyatakan aksi toast memakai `Pressable`).
Perbarui diagram "Dependency order" (`tasks.md:67`) yang juga tidak menggambar `B3→D2/G2`.

---

## Should-fix

### SF1. Generated app gagal tes: `web_index_test` dan `readme_test` (`tasks.md:411`, `469`; Req 16.11)

`test/platform/web_index_test.dart` menegaskan `<title>Skeleton</title>` dan `"name": "Skeleton"` di manifest. J2 mengganti
display name di `index.html` dan `manifest.json`, jadi tes yang tersalin ke app baru gagal pada `flutter test --exclude-tags golden`.
Z1 menambah aturan "Every path named in the README exists" ke `readme_test`, tetapi README akan menyebut `tool/create_app.dart` dan
`tool/sync_core.dart` yang berada di akar repo (bukan `skeleton/`), sehingga tes itu gagal di app hasil `create_app` dan dari cwd `skeleton/`.
Perbaikan: J2 harus menulis ulang tes yang bergantung nama (atau mengubah tes agar membaca nilai dari `pubspec`/`--display-name`),
`create_app` mengecualikan `test/docs/readme_test.dart` atau tes membatasi pengecekan path ke dalam `skeleton/`. Masukkan dua tes ini
ke acceptance J2 dan J5. Brick `brick.yaml` juga harus mengganti `package: skeleton` (design hanya menulisnya di prosa, tidak di J2).

### SF2. `--clean` memutus tes yang menyebut `home` (`tasks.md:425`, `478`, `design.md` bagian create_app langkah 6)

Setelah H1 dan Z2, `architecture_test.dart` menegaskan `lib/features/home` punya `data, domain, presentation`. App `--clean`
tidak punya folder itu, jadi tes arsitektur gagal. Tes lain yang menyebut home dan tidak ada di daftar hapus J4: `test/app/router/routes_test.dart`,
`test/app/app_test.dart`, `test/app/shell_golden_test.dart`, `test/features/home/home_route_test.dart`, dan kunci `home*`
yang dipakai label destinasi shell. J4 juga membuat `lib/app/home_placeholder_page.dart` dengan `EmptyState` yang butuh string
(kunci `home*` dihapus; teks dari caller harus tetap ada di ARB en dan id).
Perbaikan: Z2 membuat aturan "home punya tiga lapis" kondisional (`if (Directory('lib/features/home').existsSync())`) atau
J4 menulis ulang tes itu; daftar berkas yang disentuh `--clean` ditulis eksplisit di J4 dengan satu tes per berkas.

### SF3. Kontrak `AppToast` kurang: dari mana host mendapat controller (`design.md:305-318`, `tasks.md:290`, `344`)

`AppToast({required Widget child})` tidak menerima controller. `core/` tidak boleh mengimpor `app/di`, `provider` bukan dependensi langsung,
dan `flutter_bloc` tidak mengekspor `ChangeNotifierProvider`. Fitur juga butuh cara memanggil `show` (via `getIt<ToastController>()`
atau `context`). Selain itu host berada di `MaterialApp.router(builder:)`, di atas `Navigator`, jadi tidak ada `Overlay` di atasnya:
`Tooltip` (dipakai `AppIconButton`) di dalam toast akan melempar "No Overlay widget found".
Perbaikan: `AppToast({required ToastController controller, required Widget child})`, `App` meneruskan `getIt<ToastController>()`
(H5). Larang `AppIconButton`/`Tooltip` di dalam toast; aksi toast memakai `Pressable`. Tambahkan `test/app/di/injection_test.dart` ke Owns F4 (AC F4 menyebut tes DI tetapi berkas itu tidak dimiliki F4).

### SF4. `feedbackCell` memakai `IndexedStack`, ticker `SkeletonBlock` tetap jalan di anak tersembunyi (`design.md` D14, `tasks.md:284`, `335`)

`IndexedStack` menata dan membangun semua anak, tetapi tidak mematikan `TickerMode` anak yang tidak aktif. `LoadingView` berisi
`SkeletonBlock` dengan animasi berulang tak berujung, sehingga di `HomeView` setiap state selain loading tetap menjadwalkan frame,
dan `pumpAndSettle` di tes H4/H7 akan timeout. Design sudah menyebut risiko `pumpAndSettle` hanya untuk tes F3.
Perbaikan: `feedbackCell` membungkus tiap anak dengan `TickerMode(enabled: i == index, ...)` dan F3 menambah tes "state tidak aktif tidak menjadwalkan frame".
Catat juga bahwa sel dibesarkan oleh daftar terpanjang (Req 6.5) sehingga `EmptyState` tampil di panel setinggi daftar; itu perilaku yang diminta, tetapi layak di README.

### SF5. Jumlah kasus `full` tidak konsisten, jadi tes A1 "documented count" tidak dapat ditulis (`design.md:434-445`, `tasks.md:93`)

Design menulis "about 1 000 cases per widget" dan "about 120 tests per widget". Hitung sesuai teksnya: kombinasi (ukuran, input) yang sah
= 320t, 375t, 768t, 768p, 1024t, 1024p, 1200p, 1600p = 8; × 3 skala × 2 tema = 48 grup, × 8 fixture = 384 label (bukan 1000, dan 48 grup, bukan 120).
Kalimat "touch only below 1024" juga bertentangan dengan "the overlap 768 and 1024 runs both". A1 mensyaratkan tes yang memeriksa
angka itu. Perbaikan: tetapkan tabel kombinasi dan angka (48 grup, 384 label) di design dan A1; tulis bahwa grup menampilkan ulang `SizedBox.shrink`
di antara fixture agar state tidak bocor antar fixture dalam satu `testWidgets`.

### SF6. Tes yang memanggil proses panjang kena batas waktu 30 detik, dan gerbang bergantung jaringan (`tasks.md:366`, `411-432`, `439`)

`bricks_test` menjalankan `flutter pub get`, `mason make`, `build_runner`, `flutter analyze`, dan `flutter test` (design sendiri menaksir 30-60 s hanya
untuk `pub get`). `create_app_e2e` dan tes `sync_core` serupa. Batas default `flutter test` adalah 30 s per tes; tidak ada task yang menyebut `Timeout`.
`bricks_test` ada di gerbang default ("not tagged e2e"), jadi `dart run tool/check.dart` butuh jaringan dan `mason`; kegagalan `pub get` offline akan
merah, bukan skip ("skip only when mason is not on PATH"). Menjalankan `flutter` bersarang di dalam `flutter test` juga mengandalkan kunci cache Flutter.
Perbaikan: `@Timeout(Duration(minutes: 10))` di berkas bricks/e2e; pertimbangkan tag `slow` untuk bricks dan tetap masukkan ke CI; skip dengan pesan bila
`pub get` gagal karena jaringan; catat di README.

### SF7. `create_app` `git init` + commit gagal tanpa identitas git (`tasks.md:432`, `441` K1)

`git commit` di folder baru (mis. `/tmp/ci_app` di Template_Job, runner hosted tanpa `user.name/user.email`) gagal. Perbaikan: J5 memakai
`git -c user.name=... -c user.email=... commit` (nilai tetap dari `create_app`) atau menganggap commit sebagai upaya terbaik dan melapor. Di Mac ini identitas ada,
jadi K2 lokal tidak akan menangkapnya; tulis kasus itu sebagai tes unit dengan runner palsu.

### SF8. `process_runner.dart` dimiliki J1 tetapi dipakai S (`tasks.md:41`, `439`)

Lane S "needs `process_runner.dart` from J1, or its own copy if J1 is not merged". Dua salinan berarti dua berkas atau konflik. Perbaikan: pindahkan `process_runner.dart`
ke lane P (dibuat di awal) atau jadikan J1 prasyarat S2.

### SF9. API `SearchField` bergantung pada internal `AppTextField` yang tidak ada (`design.md` bagian Input, `tasks.md:229`)

`AppTextField` hanya punya `label` wajib, tanpa slot `prefix/suffix`. `SearchField` "wraps AppTextField-like internals" dengan ikon dan tombol clear, tanpa label. Dua pilihan
yang tidak dipilih design: menggandakan kode `EditableText`, atau menambah `leading`/`trailing`/`label` opsional di `AppTextField` (D1). Perbaikan: pilih yang kedua dan tulis di D1 dan D2.

### SF10. Pengecekan katalog dan inventaris: F3 satu galeri untuk dua widget, daftar `pending` tak terdefinisi (`tasks.md:114`, `284`, `478`)

A3 menjelaskan flag `strict`, sementara Z2 berkata "delete the `pending` list" yang tidak pernah didefinisikan. Template W menetapkan satu `<snake>_test.dart` dan
satu `<snake>_golden_test.dart` per widget, tetapi F3 membuat satu galeri untuk `LoadingView` dan `SkeletonBlock`; inventaris (jalur per widget)
harus memetakan dua widget ke berkas yang sama, dan F3 Owns tidak menyebut nama berkas tes. Primitif di B1 memakai nama `tactile_surface_stress_test.dart`/`pressable_stress_test.dart`
di `test/core/theme/` (bukan cermin jalur seperti Req 12.1). Perbaikan: definisikan `pending` atau hapus; tulis nama berkas tes F3 dan primitif di inventaris.

### SF11. Fungsi locale hilang tanpa keputusan (`tasks.md:344`, `353`, Req 13.10)

`PlaceholderPage` punya grup bahasa (System/English/Indonesia, kunci `localeTitle`, `localeSystem`, `localeEnglish`, `localeIndonesian`) yang ditandai
`SEAM ... replace with ThemeModeSwitch`. Home hanya menampilkan `ThemeModeSwitch`, jadi `AppSettingsCubit.setLocale` tidak punya UI, kunci `locale*` yatim,
dan `test/app/app_test.dart` ("a saved Dark and Indonesia survive a restart" yang mengetuk `localeIndonesian` harus diubah atau dibuang. Req 13.10 hanya menghapus "Check connection".
Perbaikan: putuskan salah satu: (a) Home juga menampilkan pemilih bahasa (butuh widget baru, di luar daftar 25), atau (b) pemilih bahasa dilepas dan README mencatat
pelepasan itu serta tes diubah. Ini keputusan produk untuk user; rekomendasi (b) dengan catatan, karena brief 03 §7 hanya menyebut `ThemeModeSwitch`.

### SF12. H6 tidak memiliki berkas yang harus diubah agar acceptance-nya lulus (`tasks.md:353`)

Acceptance H6 meminta `grep -rniE "PlaceholderPage|ConnectionCheck|checkConnection|connectionCheckUrl|SEAM(core-widgets" lib test` kosong. `test/core/l10n/arb_test.dart`
(`'Check connection'`, `'Periksa koneksi'`, `context.l10n.checkConnection`) dan `test/app/env_test.dart` (baris `connectionCheckUrl`) harus diubah, tetapi Owns H6 hanya
"deletion ...". `arb_test.dart` juga memverifikasi terjemahan `id`; ganti dengan kunci lain (`themeDark`/`tryAgain`). Tambahkan berkas itu ke Owns H6.

### SF13. Font di tes stres vs golden: metrik Ahem atau Inter belum ditentukan (`design.md` bagian Stress harness dan Golden setup)

`FontLoader('Inter')` hanya ada di `golden.dart`. `stressTest` memakai `buildTheme` (fontFamily Inter) tanpa memuat font; di `flutter test` teks jatuh ke Ahem
bila font tidak dimuat (satu em per karakter), sehingga tes stres jauh lebih ketat atau tidak merepresentasikan metrik Inter. Dua dampak: overflow palsu pada widget yang
sebenarnya aman, atau sebaliknya. Perbaikan: A1 memuat Inter di `setUpAll` helper stres (atau memutuskan "Ahem sengaja, lebih ketat" di design dan memberi tahu pengembang).
Juga: Req 11.2 menulis `ThemeData.platform` macOS, tetapi `context.inputMode` membaca `defaultTargetPlatform`, bukan `Theme.platform` (`window_class.dart`), dan default
`flutter test` adalah Android. Design benar memakai `debugDefaultTargetPlatformOverride`; koreksi Req 11.2 atau tambahkan catatan.

### SF14. Pemeriksaan CI yang lemah (`tasks.md:453`, `design.md` bagian CI)

(a) `*.freezed.dart` di-gitignore (`skeleton/.gitignore:5`), jadi `git diff --exit-code` setelah `build_runner` hanya melindungi `injection.config.dart`. `tokens.g.dart`
tidak dibangkitkan oleh `build_runner`, jadi basi-nya tidak terdeteksi CI (hanya tes determinisme lokal yang menjaganya). Tambahkan `dart run tool/generate_tokens.dart` sebelum `git diff`.
(b) Tes `ci_workflow_test` membandingkan `spike-pages.yml` dengan `git show HEAD:...`; setelah commit yang mengubahnya, HEAD ikut berubah dan tes tidak pernah gagal. Pakai hash tetap
atau bandingkan dengan `origin/main` (dalam clone dangkal CI `origin/main` mungkin tidak tersedia).
(c) K1 menulis "version from `.fvmrc`" tanpa jalur; ada di `skeleton/.fvmrc` (bukan akar repo, yang tidak punya `.fvmrc`).

---

## Note

N1. Verifikasi positif untuk risiko (1): tanda tangan nyata cocok dengan design: `Pressable(onPressed, child, pressedScale, semanticLabel?, borderRadius, enableFocusRing)`,
`MinHitArea`, `SurfaceScope.ink/line/hoverFill/button()/primary()/toggle()/badge(hue)`, `HueRole` (di `tokens.g.dart:272`), `context.hue(role)`, `AppMotion.d150/d200/d240/d320`,
`AppSprings.toggle`, `AppRadius.sheet = 14`, `AppLayout.colReading/colData/colForm/railExpanded/railCollapsed/topStrip/mobileTopBar/panelFloat`, `AppSizeSet.row/badge/pill/toggleTrack`,
`AppTypography.field/section/body/meta/label/title/badge`, `Debouncer(Duration).run/dispose`, `UseCase<T,P>` + `NoParams`, `guardRepository<T>` di `dio_error_mapper.dart:12`,
`AppSettingsCubit.setThemeMode`. `design.md` menulis `hue.s3` pada `HueRole`; perlu `context.hue(role).s3` (salah ketik di prosa saja).

N2. `flutter test --exclude-tags golden,e2e` diterima (dijalankan: 3 tes lulus). Tag yang belum dideklarasikan di `dart_test.yaml` tidak memicu error. Bentuk koma aman; tidak perlu `"golden || e2e"`.

N3. Req 5.3 menulis tinggi minimum baris 36; `AppSizeSet.pointer.row` = 38 dan brief 04 tabel ukuran juga 38 (brief 04 baris 124 vs baris 266 tidak konsisten). Design/E2 memakai 38 (benar terhadap kode).
Selaraskan teks Req 5.3 saat revisi. Brief 04 §7 menyebut "MVP uses Flutter's drag-to-dismiss" untuk sheet; G1 menulis `GestureDetector` drag kustom dengan ambang 1/3 dan fling, lebih dari MVP brief.

N4. Angka S4 benar: 60 task, 153 AC. Namun S4 mencatat `.fvmrc` di `skeleton/` dan membenarkan `jq`; K1 tidak menyebut jalur lengkap (lihat SF14c).

N5. Kesesuaian dengan jawaban user: Q5 B (tanpa `integration_test`): `pubspec.yaml` tidak memuat dependensi `integration_test`, H6 memeriksa folder tidak ada, Z1 mendokumentasikannya: sesuai.
Q6 A (hapus Check connection): D9, H6, Req 13.10 sesuai, dengan efek samping locale (SF11) dan `arb_test` (SF12). CI diverifikasi lokal dan run hosted manual: D11, K2, M4, Req 18.9/18.10 sesuai;
gerbang kode tidak menunggu hosted run. Satu catatan: M3 (push) depends Z3 dan M1; K1 menyatakan "The user pushes" dan agen tidak push: sesuai.

N6. Risiko golden di Mac Intel: tidak ada bukti stabilitas dua kali jalan; A2 menyimpan hash dan melaporkan beda tanpa toleransi (benar menurut brief S9). `Inter-Medium.ttf` (bobot 500) satu-satunya font terdaftar;
aturan 2.3 (satu bobot) konsisten. Render shadow blur tidak diuji lintas mesin; goldens hanya berlaku untuk Mac ini.

N7. Spike `kiri_check` + `WidgetTester` (A7): premis design benar (`kiri_check` bergantung pada `package:test`). Fallback bertingkat dan tidak memblokir lane lain; cukup. A7 diposisikan sebagai opsional di rantai P tetapi AC Req 9.8 tetap wajib; bila jalur ketiga (Random bersemai) dipakai, Req 9.8 "use kiri_check" tidak terpenuhi dan harus diubah di requirements, bukan hanya di README.

N8. `sync_core` menyalin widget dan tesnya, tetapi tidak memperbarui `test/helpers/core_widget_inventory.dart` di target; tes cakupan (UI005 stand-in) tidak mencakup widget hasil sinkron. Cukup dicatat sebagai batas yang diketahui (`shortcut:`) di S1/S2 atau README.
`create_app` juga menyalin `.flutter-plugins-dependencies` dan `.metadata` (dibangkitkan ulang oleh `pub get`); tidak berbahaya.

N9. Mason: `brick.yaml` default `package: skeleton`, `{{` pada kode Dart jarang bentrok dengan mustache, tetapi `}}` dalam kode tidak masalah dan `{{` dalam literal set bersarang bisa (hindari di template). `mason_cli` 0.1.4 dipasang di mesin ini;
CI memasangnya dengan versi pin: K1 menjaga dua sumber (README dan CI) lewat satu konstanta (I6), baik.

---

## Cek per butir permintaan

| Butir | Hasil |
|---|---|
| (1) Premis salah / API tak bisa dikompilasi | BL1, BL2, BL3, BL4, BL6, BL7, SF3, SF9 |
| (2) Urutan dan berkas bersama | BL5, BL9, BL10, SF8, SF14; "Shared files" dan "Parallel lanes" konsisten kecuali aturan `append key ARB` (tasks.md:54-57) yang bertentangan dengan "must not edit a file owned by another task" (tasks.md:17); `injection.config.dart` dibangkitkan ulang oleh F4, H2, H3, H5 dan akan konflik saat merge |
| (3) AC tak teruji / task tanpa tes | Semua task `[kode]` punya tes. AC sulit diuji otomatis: "tampak benar di 2×" (M1, memang manual), kesamaan piksel dua kali jalan (A2/H7, bisa gagal), jumlah `full` (SF5), "70 karakter" (aproksimasi, sudah dicatat S4), warna dark primary disabled (BL4) |
| (4) Golden, kiri_check, Mason, create_app, sync_core | SF13, N6, N7, BL8, SF1, SF2, SF6, SF7 |
| (5) Tes arsitektur memblokir task | BL2 (`Duration(`, `Colors.`), BL5 (`Scaffold`), BL7 (satu tipe per berkas), BL8 (bricks vs format) |
| (6) Jawaban user | N5, SF11, SF12 |

## Usulan urutan perbaikan

1. Putuskan BL3 (pilihan a atau b) dan BL4 sebelum menyentuh task B. Putuskan SF11 (pemilih bahasa) dengan user.
2. Tulis ulang A5 (BL1, BL2), P1 (BL6), A4 (BL5), A2 (BL9), A3 (BL7), I1 (BL8), lalu perbaiki Depends (BL10).
3. Perbaiki design (AppToast, feedbackCell, tabel `full`, SF3, SF4, SF5) dan Req (5.3, 11.2).
4. Jalankan ulang pemeriksaan keterlacakan S4 setelah perubahan; tambahkan satu pemeriksaan kompilasi API (stub `flutter analyze` pada tanda tangan di design) sebelum task B dimulai.

Tidak diperiksa: tidak ada kode atau spec yang dikompilasi di luar satu tes `debouncer`; perilaku `IndexedStack` terhadap ticker (SF4), pemuatan font otomatis `flutter test` (SF13), dan nesting `flutter test` di dalam `flutter test` (SF6) dinilai dari pengetahuan framework, bukan dijalankan. Risiko: tingkat keyakinan paling rendah pada SF4 dan SF13.
