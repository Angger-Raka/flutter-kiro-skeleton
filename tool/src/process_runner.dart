import 'dart:io';

/// Runs [executable] with [arguments] and returns its exit code.
///
/// Scripts take a [ProcessRunner] as a parameter so tests can inject a fake
/// that records the calls instead of starting a process.
typedef ProcessRunner =
    Future<int> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

/// The real runner. Output goes straight to this process's stdout and stderr.
Future<int> runProcess(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}
