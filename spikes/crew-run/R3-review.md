# R3: review akhir skeleton-foundation (bagian 1-9)

Reviewer independen, read-only. Tidak ada kode diubah, tidak commit, tidak push. Bagian 10 (perangkat) tidak diperiksa.
Skrip bantu hanya di `/tmp/r3y/` (salinan `lib/` dengan pelanggaran sengaja, dipakai lewat `ARCH_LIB_DIR`).

## Hasil `dart run tool/check.dart` (di `skeleton/`)

LOLOS, exit 0, "All quality gates passed."
- format: 105 file, 0 berubah.
- build_runner: tanpa error. Peringatan: flag `-d` (`--delete-conflicting-outputs`) sudah dihapus dan diabaikan oleh build_runner 2.15.1; skrip dan README masih menyebutnya.
- analyze: `No issues found!`
- test: `+322: All tests passed!`
- `git status` sesudahnya bersih (generator tidak mengubah file ter-track).

## Ringkasan

| Kategori | Jumlah |
|---|---|
| blocker | 0 |
| should-fix | 5 |
| note | 8 |

## Blocker

Tidak ada.

## Should-fix

**SF1. Fill hover/tekan `Pressable` tidak terlihat pada semua kontrol placeholder (Req 16.2).**
`lib/app/placeholder/placeholder_page.dart:193` (`_ChoiceButton`) membungkus `TactileSurface` di dalam `Pressable`. Fill hover digambar `AnimatedContainer` di `lib/core/theme/tactile/pressable.dart:97` sebagai induk dari child, sedangkan `TactileSurface` (`surface.dart`, `DecoratedBox(color: inner.fill)`) melukis fill buram di atasnya. Akibatnya hover dan fill saat ditekan (touch) tertutup; hanya skala tekan yang tampak. Tes tidak menangkapnya: `test/app/placeholder/placeholder_page_test.dart` tidak memuat kata hover/fill, dan tes `pressable_test.dart` memakai child tanpa surface.
Saran: letakkan fill di atas konten (foreground, `IgnorePointer`) atau tampilkan hover lewat `TactileSurface`; tambah tes yang menahan pointer di atas `_ChoiceButton` dan memeriksa warna terlukis.

**SF2. Tes arsitektur: pemotong komentar merusak deteksi pada baris yang berisi string `//` atau `/*`.**
`test/architecture/architecture_test.dart:129-131`. `//[^\n]*` menghapus sisa baris mulai dari `//` di dalam string (mis. `'https://x.dev'`), dan `/\*[\s\S]*?\*/` memakan kode di antara string `'/*'` dan `'*/'`. Dibuktikan dengan salinan di `/tmp/r3y/lib`: `final a = ['https://x.dev', const Duration(seconds: 1)];` di `app/v1.dart` dan `const d = Duration(seconds: 3);` di antara string `'/*'` dan `'*/'` di `core/v2.dart` TIDAK dilaporkan. Pelanggaran 22.4/20.5/17.9/18.7 yang berada di sisa baris itu lolos.
Saran: pemotong sadar string (tokenisasi sederhana) atau pakai `analyzer` untuk token.

**SF3. Tes arsitektur: `domain/` dengan import relatif tidak diperiksa (Req 22.2, 8.7).**
`architecture_test.dart:201-218`, komentar `shortcut` di baris 214. `import '../data/impl.dart';` di `features/a/domain/bad.dart` tidak dilaporkan (hanya import `package:skeleton/core/network/api_client.dart` pada file yang sama yang tertangkap). Begitu fitur pertama ada, domain bisa mengimpor data lewat `../`. Saran: resolve path relatif terhadap folder file dan tolak yang keluar dari `domain/`, atau larang `..` yang mengarah ke `data/`/`presentation/`.

**SF4. Tes arsitektur: daftar literal token terlalu sempit (Req 22.4) dan daftar widget Material terlalu sempit (21.7).**
`architecture_test.dart:253-260`, `:286-293`. Tidak tertangkap di luar `core/theme/` (dibuktikan di `/tmp/r3y/lib/app/v1.dart`): `Color.fromARGB(...)`, `Color.fromRGBO`, `Cubic(...)`, `Duration.zero` (aman), `FilledButton`, `IconButton`, `InkWell`, `GestureDetector`+warna. Yang tertangkap hanya `Color(0x`, `Colors.`, `fontSize:`, `FontWeight.`, `Curves.`, `Duration(`, dan empat tombol Material. Saran: tambah `Color.from`, `Cubic(`, `Interval(`, `FilledButton`, `IconButton`, `InkWell`, `Switch`, dan larang `Material` ripple lain, atau ganti ke aturan "hanya `Pressable`/`TactileSurface` untuk interaksi di `lib/app`".

**SF5. Requirement 13.7 belum menyatakan akibat `tune_faint_text: false` yang diklaim README.**
`.kiro/specs/skeleton-foundation/requirements.md:243` sudah menyebut hue-11, tetapi tidak menyebut bahwa dengan `false` default Radix gagal gate dan generator keluar non-nol. README (`skeleton/README.md`, bagian "Hue-11 tuning") berkata "Req 13.7 states this". Klaim itu tidak akurat. Saran: tambah satu kalimat di 13.7 atau ubah kalimat README.

## Note

**N1. Dependency terdaftar tetapi tidak dipakai kode.** `bloc_concurrency` (`pubspec.yaml:11`) dan `lucide_icons_flutter` (`pubspec.yaml:24`): nol impor di `lib/`, `test/`, `tool/`. Diwajibkan Req 2.1 jadi bukan pelanggaran, tetapi README tidak mengatakan bahwa keduanya belum dipakai. Saran: satu kalimat di README. Yang lain terpakai (`bloc_test`, `mocktail`, `kiri_check`, `yaml` dipakai di test/tool).

**N2. `-d` pada `build_runner build -d`** sudah tidak berlaku (peringatan di keluaran gate). `tool/check.dart:12` dan README. Aman, hanya bising.

**N3. `bootstrap` memasang handler sebelum `configureDependencies()` (`bootstrap.dart:38`), tetapi kegagalan DI (mis. `SharedPreferences` preResolve) hanya dicatat dan layar kosong.** Tidak ada UI error. Di luar spec; catat untuk fase berikut.

**N4. `FlutterError.onError = logger.logFlutterError` (`bootstrap.dart:13`)** menggantikan `presentError` bawaan, jadi di debug tidak ada dump Flutter di konsol selain `debugPrint` terredaksi. Sesuai Req 6.3; hanya informasi.

**N5. Allowlist tes arsitektur untuk `core/theme/tactile/{surface,shadows,typography,motion}.dart`** mengecualikan seluruh tipe publik, sehingga aturan satu-tipe-per-file pada keempat file itu kosong. Dibenarkan alasan task, dan README mencatat prinsipnya; hanya lemah sebagai pagar.

**N6. `AppTypography` tidak punya `==`/`hashCode` (F3 R2).** Tertutup di sisi pemanggil: `app.dart:33-37` men-cache `ThemeData` per (brightness, windowClass, inputMode). Aman selama `buildTheme` tidak dipanggil dari tempat lain.

**N7. Req 14.8 (blur vs browser) dan Req 3.5, 4.4, 24** belum terbukti; milik bagian 10. README menyebutnya (bagian "Not covered here").

**N8. `InputModeX.of(BuildContext)` tidak memakai `context`** (`window_class.dart`); komentar ganda F14 sudah hilang. Tidak berbahaya.

## Cek 1-6 yang diminta

### (2) Cakupan requirement (sampling, implementasi + tes)
- Req 8: 8.1/8.2 `core/error/failure.dart`, `core/usecase/usecase.dart` + `failure_test`, `usecase_test`. 8.3 `api_client.dart`, `auth_interceptor.dart` + `api_client_test`. 8.4 `guardRepository` + property 5 (`dio_error_mapper_test.dart:28`). 8.5 `mapStatus` (`dio_error_mapper.dart`) + property 6; teks Req 8.5 sekarang sama dengan perilaku (S3 tertutup). 8.6 property 7. 8.7 `architecture_test` (lihat SF3).
- Req 13: 13.1 `design/tokens.yaml` + `tokens_yaml_test`; 13.2 `radix_scales_test`; 13.3-13.5 `generate_tokens_palette/ladders/shadows/determinism_test`; 13.6 `generate_tokens_validation_test`; 13.7 `faint_text_tuning_test`; 13.9/13.10 terpenuhi dari struktur. Lihat SF5.
- Req 15: 15.1-15.9 `surface_scope_test`, `tactile_surface_test`, `shadows_test`, `theme_invariants_test`. Hover tidak terlihat dalam pemakaian nyata: SF1.
- Req 20: 20.1-20.4 `window_class_test` (batas 767/768/1199/1200, touch di web, property 17/18); 20.5 tes arsitektur (SF2); 20.6 `_noReservedDeclarations`.
- Req 1-7, 9-12, 14, 16-19, 21-23: ada implementasi dan tes (`platform_setup_test`, `env_test`, `bootstrap_test`, `injection_test`, `services_test`, `app_settings*_test`, `formatters_test`, `arb_test`, `blur_conversion_test`, `pressable_test`, `typography_test`, `motion_test`, `app_theme_test`, `routes_test`, `app_test`, `readme_test`). Tidak ada requirement tanpa implementasi/tes pada bagian 1-9. 23.6 terpenuhi (tidak ada golden/harness).

### (3) Temuan R1 dan R2
- S1 tertutup: `Debouncer(this.duration)` wajib (`debouncer.dart`).
- S2 tertutup: `logger.dart` menutup seluruh nilai `Authorization`/`Cookie`/`Set-Cookie`; tes Basic/Digest/JSON di `logger_test.dart:16-19`.
- S3 tertutup: teks Req 8.5 diselaraskan, README mencatat.
- S4 sebagian: README mendokumentasikan; Req 13.7 belum lengkap (SF5).
- S5 tertutup: `register_module.dart` 15 s + tes (`injection_test.dart:38-39`), pengecualian literal `Duration(` dicatat di allowlist.
- S6 tertutup: `if (isClosed) return;` di `connection_check_cubit.dart` + tes close (`connection_check_cubit_test.dart:116`).
- F1 tertutup (`pressable.dart:97` pakai `withAlpha(0)`), F2 tertutup (`animation.drive(CurveTween)` di `page_transition.dart`), F3 tertutup lewat cache (N6), F4 tertutup (`excludeSemantics`), F5 tertutup (`didUpdateWidget`), F10 tertutup (`overlayColor` transparan per tema tombol), F14 tertutup.

### (4) tasks.md dan README
- Kotak bagian 1-9 semuanya `[x]`; bagian 10 `[ ]`. Sesuai kenyataan (gate hijau, file ada).
- README akurat untuk: Flutter 3.44.8 (`.fvmrc`), Dart 3.12.2 (`dart --version`), minSdk 24 (`FlutterExtension.kt`), iOS 13.0 (`project.pbxproj`), versi paket cocok dengan `pubspec.yaml`, kebijakan file generated (`*.freezed.dart` tidak ter-track, 5 file generated lain ter-track), deviasi. Cacat: klaim "Req 13.7 states this" (SF5), tidak menyebut dua dependency belum dipakai (N1).

### (5) Bug nyata
Hanya SF1. Race: `ConnectionCheckCubit` aman (guard `loading`, `isClosed`). Dispose: `App` menutup router dan cubit; `Pressable` tidak punya controller. Literal warna/durasi di luar theme: tidak ada kecuali `Duration` timeout Dio yang diizinkan. Kebocoran kredensial di log: tidak ditemukan (semua jalur `debugPrint` lewat `redact`; `ConnectionCheckCubit` mencatat `Failure` lewat `logInfo` yang redaksi).

### (6) Apakah tes arsitektur menangkap pelanggaran
Sebagian. Dengan `ARCH_LIB_DIR=/tmp/r3y/lib` tes gagal dengan benar untuk: import `features/` dari `core/`, import paket terlarang di `domain/`, `FontWeight.`, dan keberadaan `lib/features`. Tidak tertangkap: `Duration(` di sisa baris setelah string `//` atau di antara string `/*` `*/` (SF2), import relatif di `domain/` (SF3), `Color.fromARGB`, `Cubic(`, `FilledButton`, `IconButton`, `InkWell` (SF4). Tes "checks detect violations" memakai potongan kode pendek sehingga tidak menangkap SF2.

## Tidak diperiksa
Bagian 10; render visual; perilaku pada perangkat; `flutter build`. Bukti SF1 dari pembacaan kode (urutan lukis), bukan dari run widget test.
