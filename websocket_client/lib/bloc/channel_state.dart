// lib/bloc/channel_state.dart

import 'package:equatable/equatable.dart';

enum EStatusConnect {
  desconectado,
  conectado,
  conectando,
}

class ChannelState extends Equatable {
  final String channelName;
  final String url;
  final EStatusConnect statusConnect;
  final List<String> messages;

  const ChannelState({
    required this.channelName,
    this.url = '',
    this.statusConnect = EStatusConnect.desconectado,
    this.messages = const [],
  });

  ChannelState copyWith({
    String? url,
    EStatusConnect? statusConnect,
    List<String>? messages,
  }) {
    return ChannelState(
      channelName: channelName,
      url: url ?? this.url,
      statusConnect: statusConnect ?? this.statusConnect,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [channelName, url, statusConnect, messages];
}
