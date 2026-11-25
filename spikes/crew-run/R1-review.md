# R1: review hasil bagian 1, 2, 3.1-3.4, 5, 6.1-6.5, 7

Reviewer read-only. Tidak ada file selain laporan ini yang diubah. Tidak ada commit, push, build_runner, atau `flutter pub`.
Tidak ditinjau: `lib/core/theme/**` dan `lib/core/layout/window_class.dart` (milik W7).
Skrip bantu sementara hanya di `/tmp/r1x/`.

## Hasil perintah

- `flutter analyze` (seluruh skeleton): 1 issue, `info` di `lib/core/theme/tactile/shadows.dart:50:81` (`lines_longer_than_80_chars`). File itu untracked dan milik W7 (in progress). Di luar itu 0 issue.
- `flutter test test/app test/core/error test/core/network test/core/settings test/core/storage test/tool test/platform`: `+108: All tests passed!`
- Literal warna/ukuran/durasi di luar `core/theme/` (grep `Color(0x|Colors.|fontSize:|FontWeight.|Curves.|Duration(`):
  - `lib/core/utils/debouncer.dart:7` `const Duration(milliseconds: 400)`
  - `lib/main.dart:18` `Colors.deepPurple` (template, diganti di 6.7)
  - Tidak ada `kIsWeb` / `Platform.` di luar `core/layout` dan `app/bootstrap.dart`.
- Platform: `.fvmrc` = 3.44.8; `namespace`/`applicationId` = `dev.angga.skeleton`; iOS, macOS bundle id `dev.angga.skeleton`; INTERNET ada di manifest utama (`AndroidManifest.xml:2`); `network.client` true di kedua file entitlements; iOS `Info.plist` tanpa `NSAppTransportSecurity` (0). `injection.config.dart`, `tokens.g.dart`, output gen-l10n ter-track; 0 file `*.freezed.dart` ter-track. `git check-ignore` untuk 4 path yang harus tidak diabaikan: kosong (benar).

## Temuan

Urutan: severity, lokasi, bukti, saran satu baris.

### Blocker

Tidak ada untuk bagian yang sudah mendarat. S1 di bawah akan memerahkan 8.1 jika tidak ditangani.

### Should-fix

**S1. `Duration(` literal di luar `core/theme/` akan menggagalkan 8.1.**
`lib/core/utils/debouncer.dart:7` (`const Duration(milliseconds: 400)`). 8.1 melarang `Duration(` di luar `core/theme/`.
Saran: jadikan `duration` parameter wajib tanpa default, atau pindahkan default ke token `AppMotion`.

**S2. Redaksi `Authorization` membocorkan kredensial skema selain Bearer (melanggar Req 6.6).**
`lib/core/log/logger.dart:6-9`. Dijalankan terhadap `redact`:
`Authorization: Basic dXNlcjpwYXNz` menjadi `Authorization: *** dXNlcjpwYXNz` (kredensial utuh tetap tampil); `authorization: Digest username="bob", response="abc"` menjadi `authorization: *** username="bob", response="abc"`.
Regex hanya menutup satu token setelah titik dua.
Saran: tutup seluruh sisa baris/nilai header (`[^\r\n]+` atau sampai pemisah), dan tambah kasus Basic/Digest ke tabel `logger_test.dart`.
Catatan terkait (note, di luar spec): `api_key=`, `secret=`, `client_secret:`, `X-Api-Key:`, `Cookie:`, `{"apiKey":..}` tidak diredaksi (hanya nama berisi `password`/`token`).

**S3. Req 8.5 ("4xx dan 5xx dipetakan ke subtipe berbeda") tidak terpenuhi secara harfiah.**
`lib/core/network/dio_error_mapper.dart:70-75`: 400, 409, 429, 500, 503 semuanya `ServerFailure` (hanya `statusCode` berbeda). Ini sesuai desain (`design.md:906-911`, Property 6) dan tasks.md 5.7, jadi implementasi setia pada desain, tetapi desain dan requirements saling bertentangan. Tes `4xx and 5xx give different results` (`dio_error_mapper_test.dart`) hanya membandingkan 400 dengan 500 lewat equality, sehingga lolos tanpa membuktikan subtipe berbeda.
Saran: putuskan satu sisi. Paling murah: ubah kalimat Req 8.5 menjadi "subtipe tertentu untuk 401/403, 404, 422; lainnya `server(statusCode)`", dan ganti tes itu dengan assert tipe.

**S4. `tune_faint_text` kini juga menggeser hue-11, bertentangan dengan teks Req 13.7 / task 2.10 / 04 §4.6.**
W2 deviasi 1 (`tool/src/faint_text.dart:1-3`): hue-11 di-tune lightness-nya (blue/green/amber terang). Req 13.7: "adjust only the OKLCH lightness of ink-9 and ink-10". Efek lain: dengan `tune_faint_text: false`, default Radix (sand, blue/green/amber) gagal gate hue-11 (4.25/4.21/4.25 < 4.5, bukti di W2) sehingga generator keluar non-nol. Artinya knob itu tidak lagi hanya "faint text". Keputusan sudah dari konduktor dan dicatat di commit f61ccde, jadi diterima sebagai perilaku, tetapi dokumen belum disesuaikan.
Saran: ubah Req 13.7, task 2.10, dan 04 §4.6 agar menyebut hue-11, dan tambahkan satu kalimat di README (9.1) bahwa `false` mengharuskan hue yang lolos sendiri; atau pisahkan knob `tune_hue_text`.

**S5. Dio tanpa timeout, tombol "Check connection" bisa macet selamanya.**
`lib/app/di/register_module.dart:25` `Dio(BaseOptions(baseUrl: env.apiBaseUrl))` tanpa `connectTimeout`/`receiveTimeout` (grep `imeout` di `lib/` tidak menemukan konfigurasi). `ConnectionCheckCubit.check()` mengabaikan panggilan saat `loading` (`connection_check_cubit.dart:23`), sehingga server yang tidak menjawab membuat tombol (6.6, Req 21.9) disabled tanpa akhir, dan Failure `network` untuk timeout (Req 8.6) tidak pernah muncul. Desain (`design.md` register_module) juga tanpa timeout.
Saran: set `connectTimeout` dan `receiveTimeout` (mis. 15 s) di `BaseOptions`, sebagai konstanta di `app/` atau `Env`, dan tambah satu tes DI yang membacanya.

**S6. `ConnectionCheckCubit.check()` emit setelah `close()` melempar `StateError`.**
`connection_check_cubit.dart:27-35`: `await` lalu `emit` tanpa `if (isClosed) return;`. Cubit dibuat per `BlocProvider` (factory); jika halaman ditutup selama request, handler `PlatformDispatcher.onError` akan menerima error itu.
Saran: tambah `if (isClosed) return;` sesudah await dan satu tes close-during-check.

### Note

**N1. `AppSettingsCubit.load()` belum dipanggil siapa pun.** `app_settings_cubit.dart:18`. Req 10.6 (restart survival) bergantung pada 6.7; design memakai `getIt<AppSettingsCubit>()..load()` di `BlocProvider.create` (`design.md:796`). Cubit di-registrasi `factory` (`injection.config.dart:48`), jadi 6.6 dan 6.7 harus berbagi satu instance lewat `BlocProvider`/`.value`, bukan memanggil `getIt` dua kali. Pastikan tes 6.7 "restart survival" menutup ini.

**N2. Persistensi gagal ditelan tanpa log.** `app_settings_cubit.dart:48-52`. Sesuai Req 10.8 (tidak crash), tetapi tidak ada jejak. Saran: bila `Logger` ditambahkan ke constructor di 6.7, panggil `logError`; jika tidak, biarkan.

**N3. Deviasi W3, semuanya diterima:**
- `Logger()` tanpa `Env` (design `Logger({Env? env})`): field `_env` di desain tidak dipakai, jadi menghapusnya lebih bersih. Tidak melanggar Req 6. Catat di README (9.1) sebagai deviasi.
- `KeyValueStore` tanpa `getBool/setBool`: tidak ada requirement dan tasks.md 5.4 hanya meminta `getString/setString/remove`; `grep getBool` di tasks.md tidak menemukan pemakai. Aman. Catat di README.
- `mapStatus` publik `@visibleForTesting` (bukan `_mapStatus`): perlu untuk tes dan sudah diberi anotasi. Property 6 di design menyebut `_mapStatus`; sinkronkan nama di design/tasks agar 8.1 dan 9.1 tidak merujuk nama lama.
- `transformTimeout` → `unexpected`: Req 8.6 hanya menyebut timeout atau tanpa koneksi; `transformTimeout` adalah timeout parsing lokal, bukan konektivitas. Diterima. Property 7 hanya mensyaratkan empat tipe konektivitas.
- Tes `LinkLauncher` lewat method channel, bukan `UrlLauncherPlatform`: diterima (alasan lint `depend_on_referenced_packages` valid).
- `LinkLauncher`/`ClipboardService` berupa kelas konkret, bukan antarmuka (Req 9.3, 9.4 berkata "interface"). Aman selama tes memakai mock channel; jika fitur butuh fake, jadikan `abstract interface class` + impl.

**N4. W5.** `bootstrap()` penuh (dengan `runApp`) tidak dites, hanya handler. Wajar sampai 6.7. Dua `Logger` (satu manual, satu DI) bersifat stateless dan ditandai `shortcut`. Handler dipasang sebelum `configureDependencies()`, jadi error saat DI tetap tercatat (baik). Urutan Req 6.2 ("configureDependencies, set Bloc.observer, install handlers sebelum run app") terpenuhi dalam arti "semua sebelum runApp".

**N5. W2 (2.9/2.10).** Gate: `ink-10` memakai 3:1 saat tanpa tuning dan 4.5:1 saat tuning (`generate_tokens.dart:56`), sesuai 04 §4.6 baris "only if used for meta". Tes exit-code/checksum untuk gate-gagal ada di commit 2.10 bukan 2.9 (W2 deviasi 2): acceptance 2.9 tetap terpenuhi di HEAD. Hue-11 tuning dan `overrides` hanya dicetak (deviasi 6) diterima. Keterbatasan: blur belum dibandingkan dengan browser, ditunda ke 10.8 (Req 14.8), bukan celah.

**N6. W4 (3.1-3.4).** Di luar cakupan review file (milik W7). Dari catatan: breakpoint sementara private sudah diganti `AppLayout` oleh commit e70eda4; sisa catatan W4 "display 24/32 dan meta 11 varian tidak diimplementasikan" perlu dicek W7/8.x terhadap Req 17.1.

**N7. W6 (7.x).** `web/og.png` disalin dari `assets/branding/og.png` (resolusi `og:image` relatif; absolut perlu saat deploy, sudah dicatat W6). Perubahan generator pada `project.pbxproj`/`Info.plist` dikembalikan; `web/manifest.json` berubah warna latar `#3B4A5C` oleh generator. Konsistensi dengan Req 4.5 (name/short_name "Skeleton") terpenuhi. Build web/apk tidak diuji; tertutup di 10.x.

**N8. Kebersihan tasks.md.** Semua kotak bagian 2, 3.1-3.4, 5, 6.1-6.5, 7 masih `[ ]` meski commit ada (W2, W3, W5 menyebut tidak mencentang karena file bersama). Saran: konduktor mencentang setelah review ini.

**N9. Working tree.** Untracked: `spikes/crew-run/W3.md`, `W5.md`, `W6.md` (belum di-commit); `lib/core/theme/tactile/shadows.dart`, `test/core/theme/shadows_test.dart` (W7). `lib/core/theme/tactile/surface.dart` modified (W7).

## Cakupan requirement

| Req | Status |
|---|---|
| 1 | 1.1-1.4, 1.6, 1.7 terbukti (lihat bukti platform). 1.5 menunggu 9.1. |
| 2 | 2.1-2.4, 2.6 oleh W1 (versi di W1.md). 2.5 menunggu README (9.1). `cupertino_icons`, `flutter_lints` dihapus (wajar). |
| 3 | 3.1-3.4 terbukti dan dites (`test/platform/platform_setup_test.dart`). 3.5 menunggu 6.6/6.7 dan 10.x. |
| 4 | 4.1-4.3, 4.5 dites. 4.4 (splash web tampil sampai frame pertama) manual, 10.x. |
| 5 | Terpenuhi (`env.dart`, `env/example.json` sama dengan key `Env`). |
| 6 | 6.1 menunggu 6.7. 6.2-6.5 dites. 6.6 gagal sebagian (S2). |
| 7 | 7.1-7.5 terpenuhi; 7.2 "data source dan repository" belum ada instansnya (belum ada fitur), wajar. |
| 8 | 8.1-8.4, 8.7 terpenuhi. 8.5 lihat S3. 8.6 terpenuhi di mapper, tetapi tidak tercapai di runtime tanpa timeout (S5). |
| 9 | 9.1, 9.2 terpenuhi. 9.3, 9.4 kelas konkret (N3). |
| 10 | 10.1, 10.2, 10.5, 10.7-10.9 terpenuhi (property 1-3). 10.3, 10.4, 10.6 menunggu 6.7 (N1). |
| 11 | 11.1-11.5 oleh W3 (tidak saya uji ulang selain test hijau; `debouncer` lihat S1). |
| 12 | 12.1-12.3, 12.5, 12.6 oleh `arb_test`; 12.4 menunggu 6.7. |
| 13, 14 | Terpenuhi dengan catatan S4; 14.8 menunggu 10.8. |
| 21 (sebagian) | 21.1-21.4, 21.10 terpenuhi (6.1, 6.4). 21.5-21.9 menunggu 6.6, 6.7. |
| 24 | Seluruhnya bergantung 6.6, 6.7, dan section 10; belum dinilai. |

Tidak ada requirement 1-12 yang terlewat diam-diam oleh task yang sudah mendarat, selain S2 (6.6), S3 (8.5), S5 (8.6 efektif), S4 (13.7).

## Risiko untuk task berikutnya

- **8.1 architecture test:**
  - `Duration(` di `debouncer.dart` dan `Colors.` di `main.dart` (S1; `main.dart` diganti 6.7).
  - "Satu kelas publik per file" akan gagal di: `core/error/exceptions.dart` (7, keluarga sealed), `core/settings/app_settings.dart` (2 enum + kelas), `core/storage/key_value_store.dart` (antarmuka + impl), `core/usecase/usecase.dart` (`UseCase` + `NoParams`), `core/layout/window_class.dart` (2 enum + extension), `core/utils/extensions.dart` (2 extension). Tasks 5.1/5.2/5.4/5.8 sendiri meminta tata letak ini. Saran: 8.1 mengecualikan keluarga sealed, enum pendamping, dan extension, atau menghitung hanya `class` non-subtipe; jangan memecah file-file ini.
  - Aturan "nama file = snake_case kelas": `usecase.dart` untuk `UseCase` dan `app_settings.dart` baik; `injection.dart` tanpa kelas (variabel `getIt`) perlu pengecualian.
  - `lib/core/l10n/app_localizations*.dart` dan `*.freezed.dart` (tidak ter-track tetapi ada di working tree setelah build_runner) harus dikecualikan dari scan.
  - Aturan `Platform\.`: `PlatformDispatcher.instance` di `bootstrap.dart` aman (regex `Platform\.` tidak cocok dan file di-exempt).
- **6.6:** `Pressable` dan `TactileSurface` (3.7-3.9) belum ada; 6.6 bergantung pada mereka dan pada `AppSettingsCubit` bersama (N1). `app_en.arb` sudah punya kunci label; pastikan tidak ada `Material` button (diuji string).
- **6.7:** pastikan satu instance `AppSettingsCubit` ber-`load()` sebelum `MaterialApp.router`; `main.dart` harus sekadar `bootstrap(() => const App())` (satu pernyataan); hapus template (menghilangkan `Colors.`).
- **9.1:** daftar deviasi README harus memuat: Logger tanpa Env, KeyValueStore tanpa getBool, `mapStatus` publik, `transformTimeout` ke unexpected, hue-11 tuning, LinkLauncher/ClipboardService konkret, `blur_conversion.dart`, `tool/src/`, `app/placeholder/`, `web/og.png`, penghapusan `cupertino_icons`/`flutter_lints`.
- **8.2 `tool/check.dart`:** `dart format --set-exit-if-changed .` akan memformat juga file W7 yang in-progress; jalankan setelah W7 selesai. Satu info lint saat ini (shadows.dart:50) akan menggagalkan gate "0 issue".
- **Pembersihan:** tes `tool/*` memanggil `dart format`/`dart analyze` lewat proses sehingga membutuhkan `dart` di PATH (catatan W2); di CI pastikan tersedia.

Tidak dicek: build nyata, `flutter test` penuh (hanya set yang diminta), `test/core/theme`, `test/core/layout`, `test/core/utils`, `test/core/services`, `test/core/l10n`, `test/core/log`, `test/core/usecase` (di luar daftar perintah; hanya dibaca lewat kode). Risiko: kesimpulan N3 untuk formatters/l10n didasarkan pada laporan W3, bukan pembacaan kode.
