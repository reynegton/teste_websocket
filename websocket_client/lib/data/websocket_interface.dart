// lib/data/websocket_interface.dart

import 'dart:async';

/// Interface genérica para um cliente WebSocket.
/// O BLoC irá depender APENAS desta interface.
abstract class IWebSocketClient {
  /// O Stream de dados recebidos do WebSocket.
  Stream get stream;

  /// Retorna o estado atual da conexão.
  bool get isConnected;

  /// Conecta ao servidor WebSocket na URL fornecida.
  Future<void> connect(String url);

  /// Envia uma mensagem.
  void sendMessage(dynamic data);

  /// Desconecta a conexão WebSocket.
  void disconnect();
}