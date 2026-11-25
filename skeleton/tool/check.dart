// Quality gates in one command (Req 23.1 to 23.3):
//
//   dart run tool/check.dart
//
// Runs, in order, from the skeleton root, and stops at the first failure:
//   1. dart format --set-exit-if-changed .
//   2. dart run build_runner build -d
//   3. flutter analyze
//   4. flutter test
//
// `dart` and `flutter` must be on PATH (with FVM: `fvm dart run tool/check.dart`).
import 'dart:io';

const _steps = <(String, String, List<String>)>[
  ('format', 'dart', ['format', '--set-exit-if-changed', '.']),
  ('build_runner', 'dart', ['run', 'build_runner', 'build', '-d']),
  ('analyze', 'flutter', ['analyze']),
  ('test', 'flutter', ['test']),
];

Future<void> main() async {
  // Run from the skeleton root whatever the caller's working directory is.
  Directory.current = File.fromUri(Platform.script).parent.parent;

  for (final (name, command, args) in _steps) {
    stdout.writeln('\n==> $name: $command ${args.join(' ')}');
    final Process process;
    try {
      process = await Process.start(
        command,
        args,
        mode: ProcessStartMode.inheritStdio,
      );
    } on ProcessException catch (e) {
      stderr.writeln('FAILED: $name could not start: ${e.message}');
      exit(127);
    }
    final code = await process.exitCode;
    if (code != 0) {
      stderr.writeln('\nFAILED: $name exited with $code');
      exit(code);
    }
  }
  stdout.writeln('\nAll quality gates passed.');
}
