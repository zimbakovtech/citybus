/// Build-time configuration.
///
/// Pass the backend origin with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
/// (10.0.2.2 reaches the host machine from the Android emulator; iOS
/// simulators can use http://localhost:8000.)
abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// ws:// twin of [apiBaseUrl], for the realtime WebSocket.
  static String get wsBaseUrl =>
      apiBaseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
}
