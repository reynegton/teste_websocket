// lib/bloc/channel_event.dart

import 'package:equatable/equatable.dart';

abstract class ChannelEvent extends Equatable {
  const ChannelEvent();
  @override
  List<Object> get props => [];
}

class UrlUpdated extends ChannelEvent {
  final String url;
  const UrlUpdated(this.url);
  @override
  List<Object> get props => [url];
}

class ConnectToggled extends ChannelEvent {
  const ConnectToggled();
}

class MessageReceived extends ChannelEvent {
  final String message;
  const MessageReceived(this.message);
  @override
  List<Object> get props => [message];
}

class ClearMessages extends ChannelEvent {
  const ClearMessages();
}

class ConnectionClosed extends ChannelEvent {
  final String reason;
  const ConnectionClosed(this.reason);
  @override
  List<Object> get props => [reason];
}