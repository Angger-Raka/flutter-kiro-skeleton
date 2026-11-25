import 'dart:async';

/// Collapses rapid calls into one. Used for search and query input
/// (the design system uses 400 ms; the caller passes it).
class Debouncer {
  /// Creates a debouncer that waits [duration] after the last call.
  Debouncer(this.duration);

  /// Quiet time before the last [run] action executes.
  final Duration duration;

  Timer? _timer;

  /// Schedules [action], replacing any action still waiting.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancels the pending action. Call it when the owner is closed.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
