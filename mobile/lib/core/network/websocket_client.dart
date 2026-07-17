import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/env.dart';

/// Thin wrapper over the realtime WebSocket: connects to /ws/realtime and
/// exposes decoded JSON messages as a stream.
class RealtimeSocket {
  RealtimeSocket({String? url})
      : _channel = WebSocketChannel.connect(
          Uri.parse(url ?? '${Env.wsBaseUrl}/ws/realtime'),
        );

  final WebSocketChannel _channel;

  Stream<Map<String, dynamic>> get messages => _channel.stream
      .map((raw) => jsonDecode(raw as String))
      .where((decoded) => decoded is Map<String, dynamic>)
      .cast<Map<String, dynamic>>();

  Future<void> close() async => _channel.sink.close();
}
