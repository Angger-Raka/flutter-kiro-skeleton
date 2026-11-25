# P1-prep: persiapan Phase 1

Tanggal: 2026-11-24. Tidak ada push.

## 1. Toolchain

`flutter --version`: Flutter 3.44.8, stable, revisi framework 058e0af2c2 (2026-07-23), Dart 3.12.2, DevTools 2.57.0. SDK di `/Users/angga/fvm/versions/stable`. Host macOS 15.7.7 (darwin-x64).

`flutter doctor -v`:

| Area | Status | Catatan |
|---|---|---|
| Flutter | OK | web, macOS desktop, Android, iOS aktif |
| Android toolchain | **Peringatan** | SDK 36 dan build-tools 36.0.0 ada, JDK Temurin 17. **Lisensi Android berstatus unknown** (`flutter doctor --android-licenses` belum dijalankan) |
| Xcode | OK | Xcode 26.0 (17A324), CocoaPods 1.17.0 |
| Chrome (web) | OK | Chrome 157 |
| Perangkat | 3 | Infinix X6855 (Android 16), macOS, Chrome |
| Jaringan | OK | |

Simulator iOS: runtime iOS 26.0 terpasang (`xcrun simctl list runtimes`). Doctor tidak memakai Android Studio, tidak ada isu lain. Tidak ada perbaikan yang saya jalankan.

## 2. Font

Sudah ada: `skeleton/assets/fonts/Inter-Medium.ttf` dan `OFL.txt` (Inter 4.1, tercatat di THIRD_PARTY_NOTICES.md).

Ditambah (commit 3584214, terpisah dari push):
- `SpaceGrotesk-Medium.ttf` dari rilis resmi 2.0.0 (floriankarsten/space-grotesk, `ttf/static`), lisensi `OFL-SpaceGrotesk.txt`.
- `PlusJakartaSans-Medium.ttf` dari rilis resmi 2.7.1 (tokotype/PlusJakartaSans, `ttf`), lisensi `OFL-PlusJakartaSans.txt`.
- Kedua OFL.txt diperiksa: tertulis SIL Open Font License 1.1, hak cipta 2020 masing-masing Project Authors.
- THIRD_PARTY_NOTICES.md: hanya menambah dua bagian (12 baris).

Penyimpangan kecil: `OFL.txt` yang ada milik Inter, jadi lisensi dua font baru disimpan dengan nama `OFL-<Font>.txt` agar tidak menimpa. Brief hanya menyebut satu `OFL.txt`. Runbook 5.1 menyatakan Space Grotesk dan Plus Jakarta Sans "datang kemudian bersama S21", tetapi 11-roadmap.md Phase 0 mencantumkannya sekarang, jadi saya mengikuti tugas ini.

Belum dilakukan: uji kecocokan tipografi S21 (x-height, tabular figures); bobot Medium dipilih sesuai brief 08 dan 09.

## 3. Pin versi Flutter

- Tidak ada `.fvmrc` di repo. `03-architecture.md` baris 14 dan 15: versi dipin di Phase 1 dan dicatat di `skeleton/README.md`; "FVM optional (`.fvmrc` included)". Runbook 7.5: catat output `flutter --version` di jurnal.
- Brief menyebut "3.50 at the time of writing", sedangkan terpasang 3.44.8. Itu perbedaan nyata.
- Tidak membuat file apa pun, sebab `skeleton/README.md` dan `.fvmrc` belum ada (dibuat `flutter create` di Phase 1).
- Versi yang dipakai: **3.44.8 / Dart 3.12.2**.

## 4. Ikon

`lucide_icons_flutter` 4.0.3 sudah diputuskan (S23/C7), fallback `material_symbols_icons` 4.2960.0. Keduanya tercatat di THIRD_PARTY_NOTICES.md. Tidak ada yang di-vendor.

## Perlu keputusan Anda

1. Lisensi Android: jalankan `flutter doctor --android-licenses` sendiri (menyentuh luar repo, jadi tidak saya lakukan). Perlu bila Phase 1 membangun APK.
2. Pin 3.44.8 (terpasang) atau 3.50 (angka di brief)? Rekomendasi: 3.44.8, karena itu yang ada dan teruji, lalu brief 03 diperbarui oleh Anda.
3. Nama file lisensi: `OFL-<Font>.txt` (dipakai sekarang) atau satu OFL.txt gabungan.
4. Ubah baris sisa di runbook yang bilang font datang bersama S21? Saya tidak menyentuh dokumen brief.
