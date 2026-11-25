import 'package:skeleton/core/error/exceptions.dart';
import 'package:skeleton/core/storage/key_value_store.dart';

/// In-memory [KeyValueStore] for tests.
class InMemoryKeyValueStore implements KeyValueStore {
  /// Creates a store, optionally seeded with [initial] values.
  InMemoryKeyValueStore([Map<String, String>? initial])
    : values = {...?initial};

  /// Backing map. Tests may read or seed it directly.
  final Map<String, String> values;

  /// When true, writes throw [CacheException].
  bool failWrites = false;

  @override
  String? getString(String key) => values[key];

  @override
  Future<void> setString(String key, String value) async {
    if (failWrites) {
      throw const CacheException('write failed');
    }
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    if (failWrites) {
      throw const CacheException('remove failed');
    }
    values.remove(key);
  }
}
