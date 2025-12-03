// lib/data/websocket_client.dart

import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:websocket_client/data/websocket_interface.dart';
//Timeout para inatividade do servidor.
const Duration _watchdogTimeout = Duration(hours: 4);

class WebSocketClient implements IWebSocketClient {
  WebSocketChannel? _channel;
  StreamController? _streamController;
  bool _isConnected = false;
  Timer? _watchdog;
  DateTime _lastMessageAt = DateTime.now();
  
  final Duration _watchdogTick = const Duration(seconds: 2);

  @override
  Stream get stream => _streamController?.stream ?? const Stream.empty();

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect(String url) async {
    if (_isConnected) return;

    try {
      final ws = await WebSocket.connect(url).timeout(const Duration(seconds: 5));
      _channel = IOWebSocketChannel(ws);
      
      _isConnected = true;
      _streamController = StreamController.broadcast();
      _lastMessageAt = DateTime.now();
      _startWatchdog();

      _channel!.stream.listen(
        (data) {
          _lastMessageAt = DateTime.now();
          _streamController?.add(data);
        },
        onError: (error) {
          _streamController?.addError(error);          
        },
        onDone: () {
          _streamController?.addError(StateError('Conexão encerrada pelo servidor'));          
        },
      );
    } catch (e) {
      _isConnected = false;
      _channel = null;
      rethrow;
    }
  }

  @override
  void sendMessage(dynamic data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(data);
    }
  }

  @override
  // lib/data/websocket_client.dart (Método disconnect CORRIGIDO)
  @override
  void disconnect() {
    if (!_isConnected) return;

    // 1. Usa o código de status 1000 (Normal Closure) e uma razão
    // Isso força o envio imediato da frame de fechamento.
    _channel?.sink.close(1000, 'Fechamento solicitado pelo cliente');

    _isConnected = false;
    _channel = null;
    _watchdog?.cancel();
    _watchdog = null;
    // Fecha o stream desta conexão para acionar onDone no BLoC
    if (_streamController != null && !_streamController!.isClosed) {
      _streamController!.close();
    }
    _streamController = null;
    // O StreamController não precisa de ser fechado explicitamente
    // porque criamos um novo cliente no BLoC.
  }
}

extension on WebSocketClient {
  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer.periodic(_watchdogTick, (t) {
      if (!_isConnected) return;
      final elapsed = DateTime.now().difference(_lastMessageAt);
      if (elapsed >= _watchdogTimeout) {
        _streamController?.addError(StateError('Inatividade detectada'));
        _streamController?.add('Conexão encerrada.');
        disconnect();
      }
    });
  }
}
