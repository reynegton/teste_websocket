// lib/bloc/channel_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:websocket_client/bloc/channel_event.dart';
import 'package:websocket_client/bloc/channel_state.dart';
import 'package:websocket_client/data/websocket_interface.dart';
import 'package:websocket_client/data/websocket_client.dart';

class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  late IWebSocketClient _client;
  StreamSubscription? _messageSubscription;

  ChannelBloc(String channelName)
    : _client = WebSocketClient(),
      super(ChannelState(channelName: channelName)) {
    on<UrlUpdated>(_onUrlUpdated);
    on<ConnectToggled>(_onConnectToggled);
    on<MessageReceived>(_onMessageReceived);
    on<ClearMessages>(_clearMessage);
    on<ConnectionClosed>(_onConnectionClosed);
  }

  void _onUrlUpdated(UrlUpdated event, Emitter<ChannelState> emit) {
    emit(state.copyWith(url: event.url));
  }

  void _onConnectToggled(
    ConnectToggled event,
    Emitter<ChannelState> emit,
  ) async {
    if (state.statusConnect == EStatusConnect.conectado) {
      // 1. Desconectar e Limpar
      _client.disconnect();
      _messageSubscription?.cancel();
      _messageSubscription = null;

      // 2. Cria uma NOVA instância de cliente para a próxima conexão (evita cache)
      _client = WebSocketClient();

      emit(state.copyWith(statusConnect: EStatusConnect.desconectado));
    } else {
      // 3. Conectar
      if (state.url.isEmpty) return;

      try {
        emit(state.copyWith(statusConnect: EStatusConnect.conectando));
        await _client.connect(state.url);
        _messageSubscription = _client.stream.listen(
          (message) {
            final text = message.toString();
            add(MessageReceived(text));
          },
          onError: (error) {
            add(MessageReceived('Conexão perdida: ${error.toString()}'));
            add(ConnectionClosed('Conexão perdida: ${error.toString()}'));
          },
          onDone: () {
            add(const MessageReceived('Conexão encerrada pelo servidor.'));
            add(const ConnectionClosed('Conexão encerrada pelo servidor.'));
          },
        );

        emit(state.copyWith(statusConnect: EStatusConnect.conectado));
      } catch (e) {
        add(MessageReceived('Erro ao conectar: ${e.toString()}'));
        emit(state.copyWith(statusConnect: EStatusConnect.desconectado));
      }
    }
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChannelState> emit) {
    final newMessages = List<String>.from(state.messages);
    newMessages.insert(0, event.message);

    if (newMessages.length > 50) {
      newMessages.removeLast();
    }

    emit(state.copyWith(messages: newMessages));
  }

  void _clearMessage(ClearMessages event, Emitter<ChannelState> emit) {
    emit(state.copyWith(messages: []));
  }

  void _onConnectionClosed(ConnectionClosed event, Emitter<ChannelState> emit) {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _client.disconnect();
    _client = WebSocketClient();
    final newMessages = List<String>.from(state.messages);
    newMessages.insert(0, 'Conexão encerrada.');
    if (newMessages.length > 50) {
      newMessages.removeLast();
    }
    emit(state.copyWith(statusConnect: EStatusConnect.desconectado, messages:newMessages ));
  }

  @override
  Future<void> close() {
    _client.disconnect();
    _messageSubscription?.cancel();
    return super.close();
  }
}
