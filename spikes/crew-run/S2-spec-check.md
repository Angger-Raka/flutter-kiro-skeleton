# S2: pemeriksaan spec `skeleton-foundation`

Tanggal: 2026-11-24. Berkas yang diperiksa: `.kiro/specs/skeleton-foundation/requirements.md` (24 requirement, 163 acceptance criteria),
`design.md` (20 properti), `tasks.md` (68 task daun dalam 10 bagian). Tabel di bawah dihasilkan oleh skrip yang membaca baris
`_Requirements:` dan `_Properties:` di `tasks.md`, bukan ditulis tangan.

## Ringkasan

- Setiap dari 163 acceptance criteria dirujuk oleh minimal satu task. Tidak ada rujukan ke nomor yang tidak ada.
- Setiap dari 20 properti punya task yang mengujinya (bagian "Properti").
- Task: 68 daun. 56 task kode dan dokumen (bagian 1 sampai 9) dan 12 task verifikasi manual (10.1 sampai 10.12; 10.1 butuh tindakan user). Commit: 58, yaitu satu per task kode atau dokumen ditambah 10.8 dan 10.12 (catatan hasil di README). Sepuluh task manual lain tidak punya commit.
- Perubahan pada keputusan user: Q1 A, Q2 A, Q4 A, Q13 B diterapkan di requirements 21 dan 23 serta 24.8; Q3, Q5 sampai Q12, Q14 sampai Q17, Q19, Q20 mengikuti rekomendasi S1; Q18 menjadi task 10.1 `[USER ACTION]`.
- Tanda "(see Q#)" di requirements: semua dihapus. Sisa rujukan Q# hanya di Pendahuluan sebagai asal keputusan. Tidak ada requirement yang bergantung pada item yang belum diputuskan.

## Celah yang ditemukan

Tidak ada celah yang memblokir. Lima celah dan risiko non-blokir:

| ID | Celah | Dampak | Penanganan |
|---|---|---|---|
| G1 | Generator ada di `tool/` dan butuh rumus blur, padahal design menaruh `cssBlurToFlutter` di `shadows.dart` yang mengimpor Flutter. | Dua salinan rumus akan menyimpang, atau generator tidak bisa mengimpor. | Task 2.3 menaruh rumus di `core/theme/tactile/blur_conversion.dart` (hanya `dart:math`); `shadows.dart` mengekspor ulang. Dicatat di Revision notes design. |
| G2 | "Check connection" di web gagal karena CORS: `https://example.com` tidak mengirim header CORS, sehingga Dio web mengembalikan `connectionError`. | Acceptance 24.1 tidak terganggu (hanya meminta halaman tampil), tetapi uji manual "sukses" di web akan tampak gagal. | Task 10.2 menyatakan hasil yang diharapkan di web adalah pesan `Failure` jaringan; untuk sukses pakai `--dart-define=HEALTH_URL=` ke URL ber-CORS. Requirement 3.5 dan 24.9 hanya Android, jadi tidak diubah. |
| G3 | Nilai resep bayangan (`04` §4.5), tabel remap surface (`04` §5), ukuran dan peran tipografi (`04` §6.1), dan daftar gate kontras (`04` §4.6) hanya ada di brief. Tasks merujuk bagian itu, tidak menyalin angkanya. | Implementer harus membaca `docs/brief/04-design-system.md`. | Sengaja, agar tidak ada dua sumber kebenaran. Task 2.7, 2.8, 2.9, 3.4, 3.5 menyebut bagian brief. |
| G4 | Belum diketahui apakah token default (sand, blue, green, red, amber) lolos semua gate kontras tanpa tuning, dan apakah `kiri_check` 1.4.0 cocok dengan Dart 3.12.2. | Task 2.9 bisa menemukan gate gagal. Task 1.4 bisa gagal resolve. | Task 1.4 dan 2.9 punya acceptance yang memeriksa keduanya. Bila 1.4 gagal, laporkan sebagai pertanyaan (versi `kiri_check` lain), jangan mengganti library diam-diam. |
| G5 | Beberapa aturan hanya bisa diperiksa mendekati: "satu kelas publik per berkas" (22.3), "tidak ada literal warna di widget" (22.4), dan properti 19 dan 20. `kit check` baru ada di Phase 2. | Tes arsitektur 8.1 memakai pemindaian teks, bisa meleset pada kasus tepi. | Task 8.1 memakai pemindaian teks dengan daftar pola tetap; Phase 2 menggantinya dengan `kit check`. |

Catatan lain, tanpa tindakan:

- Properti 4 dirujuk dua kali (5.8 untuk model, 6.7 untuk `App`), yang disengaja.
- Grup `Validates: R1..R6` di design memakai penomoran lama. Isinya tidak diubah; peta ke nomor final ada di tabel di bawah dan di Revision notes design.
- Req 17.4 menyebut "any role used for amounts" tanpa daftar peran. Task 3.4 hanya menguji `figure`; peran lain mengikuti `04` §6.1.
- Req 24.8 menyebut "device class"; uji manual 10.6 hanya di web dan macOS, sesuai kalimat requirement.
- `*.freezed.dart` tidak di-commit (Q10), jadi klon baru harus menjalankan build_runner. Task 9.1 mencatat ini di README dan 10.11 mengujinya pada klon bersih.

## Keterlacakan: requirement ke task

| Requirement | Criteria | Tasks |
|---|---|---|
| 1. Project scaffold and toolchain pin | 7 | 1.1, 1.2, 1.3, 2.1, 9.1, 10.10 |
| 2. Pinned dependencies and lints | 6 | 1.3, 1.4, 1.5, 9.1 |
| 3. Platform network setup | 5 | 1.6, 1.7, 6.5, 10.1, 10.5, 10.9 |
| 4. Branding, native splash, and web shell | 5 | 1.2, 7.1, 7.2, 7.3, 7.4, 10.2 |
| 5. Environment configuration | 4 | 6.1 |
| 6. Bootstrap, logging, and global error handling | 6 | 5.3, 6.3, 6.7 |
| 7. Dependency injection | 5 | 1.3, 6.2, 9.1, 10.11 |
| 8. Core error, usecase, and network | 7 | 5.1, 5.2, 5.6, 5.7 |
| 9. Storage and services | 4 | 5.4, 5.5 |
| 10. AppSettings and persistence | 9 | 5.8, 5.9, 6.7, 10.7 |
| 11. Formatting utilities | 5 | 5.10, 5.11 |
| 12. Localization | 6 | 5.12, 6.7 |
| 13. Design tokens and the token generator | 10 | 2.1, 2.2, 2.4, 2.5, 2.6, 2.7, 2.8, 2.10, 2.11 |
| 14. Blur conversion and contrast gates | 8 | 2.3, 2.4, 2.8, 2.9, 10.8 |
| 15. Tactile surfaces | 9 | 3.5, 3.6, 3.7, 4.3 |
| 16. Pressable primitive | 7 | 3.8, 3.9, 4.1 |
| 17. Typography | 9 | 3.4, 8.1 |
| 18. Motion | 7 | 3.2, 3.3, 8.1 |
| 19. Theme mapping | 6 | 4.1, 4.2, 4.3, 6.7, 10.6 |
| 20. Layout plumbing | 6 | 2.7, 3.1, 8.1 |
| 21. Router and shell | 10 | 6.1, 6.4, 6.5, 6.6, 6.7, 10.6 |
| 22. Architecture rules | 6 | 8.1, 9.1 |
| 23. Quality gates | 6 | 1.5, 8.2, 10.11 |
| 24. Phase 1 acceptance on the target platforms | 10 | 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.9, 10.10, 10.12 |

## Keterlacakan: acceptance criterion ke task

Setiap baris berikut adalah satu acceptance criterion `N.K` di requirements.

| Criterion | Task(s) |
|---|---|
| 1.1 | 1.1 |
| 1.2 | 1.1 |
| 1.3 | 1.2, 10.10 |
| 1.4 | 1.1 |
| 1.5 | 9.1 |
| 1.6 | 1.3 |
| 1.7 | 1.1, 2.1 |
| 2.1 | 1.4 |
| 2.2 | 1.4 |
| 2.3 | 1.4 |
| 2.4 | 1.5 |
| 2.5 | 1.4, 9.1 |
| 2.6 | 1.3, 1.4 |
| 3.1 | 1.6, 10.9 |
| 3.2 | 1.6 |
| 3.3 | 1.7, 10.5 |
| 3.4 | 1.7 |
| 3.5 | 6.5, 10.1, 10.9 |
| 4.1 | 7.1 |
| 4.2 | 7.2, 7.3 |
| 4.3 | 7.4 |
| 4.4 | 7.3, 10.2 |
| 4.5 | 1.2, 7.4 |
| 5.1 | 6.1 |
| 5.2 | 6.1 |
| 5.3 | 6.1 |
| 5.4 | 6.1 |
| 6.1 | 6.3, 6.7 |
| 6.2 | 6.3 |
| 6.3 | 6.3 |
| 6.4 | 6.3 |
| 6.5 | 6.3 |
| 6.6 | 5.3 |
| 7.1 | 6.2 |
| 7.2 | 6.2 |
| 7.3 | 6.2 |
| 7.4 | 6.2 |
| 7.5 | 1.3, 6.2, 9.1, 10.11 |
| 8.1 | 5.1 |
| 8.2 | 5.2 |
| 8.3 | 5.6 |
| 8.4 | 5.7 |
| 8.5 | 5.7 |
| 8.6 | 5.7 |
| 8.7 | 5.7 |
| 9.1 | 5.4 |
| 9.2 | 5.4 |
| 9.3 | 5.5 |
| 9.4 | 5.5 |
| 10.1 | 5.8 |
| 10.2 | 5.8 |
| 10.3 | 5.8, 6.7 |
| 10.4 | 6.7 |
| 10.5 | 5.9 |
| 10.6 | 5.9, 6.7, 10.7 |
| 10.7 | 5.9 |
| 10.8 | 5.9 |
| 10.9 | 5.9 |
| 11.1 | 5.10 |
| 11.2 | 5.10 |
| 11.3 | 5.10 |
| 11.4 | 5.10 |
| 11.5 | 5.11 |
| 12.1 | 5.12 |
| 12.2 | 5.12 |
| 12.3 | 5.12 |
| 12.4 | 6.7 |
| 12.5 | 5.12 |
| 12.6 | 5.12 |
| 13.1 | 2.2 |
| 13.2 | 2.1 |
| 13.3 | 2.6, 2.7, 2.8, 2.11 |
| 13.4 | 2.11 |
| 13.5 | 2.11 |
| 13.6 | 2.5 |
| 13.7 | 2.4, 2.10 |
| 13.8 | 2.10 |
| 13.9 | 2.10 |
| 13.10 | 2.11 |
| 14.1 | 2.3, 2.8 |
| 14.2 | 2.3 |
| 14.3 | 2.3 |
| 14.4 | 2.8 |
| 14.5 | 2.4, 2.9 |
| 14.6 | 2.9 |
| 14.7 | 2.9 |
| 14.8 | 10.8 |
| 15.1 | 3.5 |
| 15.2 | 3.7 |
| 15.3 | 3.5 |
| 15.4 | 3.5 |
| 15.5 | 3.5 |
| 15.6 | 3.5 |
| 15.7 | 4.3 |
| 15.8 | 3.6 |
| 15.9 | 3.5 |
| 16.1 | 3.8 |
| 16.2 | 3.8 |
| 16.3 | 3.9 |
| 16.4 | 3.9 |
| 16.5 | 3.8 |
| 16.6 | 3.9 |
| 16.7 | 4.1 |
| 17.1 | 3.4 |
| 17.2 | 3.4 |
| 17.3 | 3.4 |
| 17.4 | 3.4 |
| 17.5 | 3.4 |
| 17.6 | 3.4 |
| 17.7 | 3.4 |
| 17.8 | 3.4 |
| 17.9 | 8.1 |
| 18.1 | 3.2 |
| 18.2 | 3.2 |
| 18.3 | 3.2 |
| 18.4 | 3.3 |
| 18.5 | 3.2 |
| 18.6 | 3.3 |
| 18.7 | 8.1 |
| 19.1 | 4.1 |
| 19.2 | 4.1 |
| 19.3 | 4.2 |
| 19.4 | 4.3, 6.7, 10.6 |
| 19.5 | 4.3 |
| 19.6 | 4.1 |
| 20.1 | 3.1 |
| 20.2 | 3.1 |
| 20.3 | 3.1 |
| 20.4 | 2.7 |
| 20.5 | 3.1, 8.1 |
| 20.6 | 8.1 |
| 21.1 | 6.4 |
| 21.2 | 6.4 |
| 21.3 | 6.4, 6.6 |
| 21.4 | 6.4 |
| 21.5 | 6.7 |
| 21.6 | 6.4, 10.6 |
| 21.7 | 6.6 |
| 21.8 | 6.5, 6.6 |
| 21.9 | 6.5, 6.6 |
| 21.10 | 6.1 |
| 22.1 | 8.1 |
| 22.2 | 8.1 |
| 22.3 | 8.1 |
| 22.4 | 8.1 |
| 22.5 | 9.1 |
| 22.6 | 8.1 |
| 23.1 | 1.5, 8.2, 10.11 |
| 23.2 | 8.2, 10.11 |
| 23.3 | 8.2, 10.11 |
| 23.4 | 8.2 |
| 23.5 | 8.2 |
| 23.6 | 8.2 |
| 24.1 | 10.2, 10.12 |
| 24.2 | 10.3, 10.12 |
| 24.3 | 10.4, 10.12 |
| 24.4 | 10.5, 10.12 |
| 24.5 | 10.2, 10.3, 10.4, 10.5, 10.12 |
| 24.6 | 10.2, 10.3, 10.4, 10.5, 10.12 |
| 24.7 | 10.7, 10.12 |
| 24.8 | 10.6, 10.12 |
| 24.9 | 10.1, 10.9, 10.12 |
| 24.10 | 10.10, 10.12 |

## Properti design ke task

| Properti | Bentuk uji | Task |
|---|---|---|
| 1, 2, 3 | PBT `kiri_check` | 5.9 |
| 4 | PBT `kiri_check` | 5.8, 6.7 |
| 5, 6, 7 | PBT `kiri_check` | 5.7 |
| 8, 9, 10 | PBT `kiri_check` | 2.3 |
| 11, 12 | berbasis tabel (fixture lolos dan gagal) | 2.9 |
| 13 | berbasis tabel | 2.10 |
| 14 | berbasis tabel | 4.3 |
| 15, 16 | berbasis tabel | 3.5 |
| 17, 18 | PBT `kiri_check` | 3.1 |
| 19, 20 | pemindaian teks | 8.1 |

## Task yang butuh tindakan user

- 10.1: menerima lisensi Android SDK (`flutter doctor --android-licenses`). Memblokir 10.4 (Android debug) dan 10.9 (APK rilis ke jaringan), karena Gradle butuh lisensi untuk build apa pun.
