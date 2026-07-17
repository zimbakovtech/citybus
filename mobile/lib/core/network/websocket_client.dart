import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/env.dart';
import '../errors/failures.dart';

/// Thin wrapper over the realtime WebSocket: connects to /ws/realtime and
/// exposes decoded JSON messages as a stream.
class RealtimeSocket {
  RealtimeSocket({String? url})
    : _channel = WebSocketChannel.connect(
        Uri.parse(url ?? '${Env.wsBaseUrl}/ws/realtime'),
      );

  final WebSocketChannel _channel;

  /// Decoded messages. Awaits the connection first so a refused/failed
  /// connect becomes a typed [NetworkFailure] on this stream (handled by the
  /// UI) instead of an unhandled async exception from the unawaited
  /// [WebSocketChannel.ready] future.
  Stream<Map<String, dynamic>> get messages async* {
    try {
      await _channel.ready;
    } on Exception {
      throw const NetworkFailure();
    }
    yield* _channel.stream
        .map((raw) => jsonDecode(raw as String))
        .where((decoded) => decoded is Map<String, dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Fire-and-forget: on a channel that never connected, awaiting
  /// sink.close() would hang and its future may error — ignore() both.
  void close() {
    _channel.sink.close().ignore();
  }
}
