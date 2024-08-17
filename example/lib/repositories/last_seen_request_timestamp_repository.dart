import 'package:shared_preferences/shared_preferences.dart';

abstract class LastSeenRequestTimestampRepository {
  Future<int?> getLastSeenRequestTimestamp();

  Future<void> updateLastSeenRequestTimestamp(int timestamp);
}

class SharedPreferencesLastSeenRequestTimestampRepository
    implements LastSeenRequestTimestampRepository {
  SharedPreferencesLastSeenRequestTimestampRepository(
      {required sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  static const String _lastSeenRequestTimestampKey =
      'last_seen_request_timestamp';
  final SharedPreferences _sharedPreferences;

  @override
  Future<int?> getLastSeenRequestTimestamp() async {
    return _sharedPreferences.getInt(_lastSeenRequestTimestampKey);
  }

  @override
  Future<void> updateLastSeenRequestTimestamp(int timestamp) async {
    await _sharedPreferences.setInt(_lastSeenRequestTimestampKey, timestamp);
  }
}
