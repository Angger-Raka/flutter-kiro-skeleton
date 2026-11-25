import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton/core/error/exceptions.dart';

/// Persistent string storage. No storage-package type appears here, so tests
/// and platforms can swap the implementation.
abstract class KeyValueStore {
  /// Returns the stored string for [key], or null.
  String? getString(String key);

  /// Stores [value] under [key]. Throws [CacheException] if the write fails.
  Future<void> setString(String key, String value);

  /// Removes [key]. Throws [CacheException] if the removal fails.
  Future<void> remove(String key);
}

/// [KeyValueStore] backed by `shared_preferences`.
@LazySingleton(as: KeyValueStore)
class SharedPrefsKeyValueStore implements KeyValueStore {
  /// Creates the store over [_prefs].
  SharedPrefsKeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async {
    if (!await _prefs.setString(key, value)) {
      throw CacheException('Could not write $key');
    }
  }

  @override
  Future<void> remove(String key) async {
    if (!await _prefs.remove(key)) {
      throw CacheException('Could not remove $key');
    }
  }
}
