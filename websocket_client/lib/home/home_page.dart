// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:websocket_client/bloc/channel_bloc.dart';
import 'package:websocket_client/bloc/channel_event.dart';
import 'package:websocket_client/home/channel_card.dart';


class WebSocketClientScreen extends StatefulWidget {
  const WebSocketClientScreen({super.key});

  @override
  State<WebSocketClientScreen> createState() => _WebSocketClientScreenState();
}

class _WebSocketClientScreenState extends State<WebSocketClientScreen> {
  static const String baseURL = 'ws://127.0.0.1:8080/ws/';
  
  // Lista para armazenar as instâncias dos BLoCs
  late final List<ChannelBloc> _channelBlocs;

  @override
  void initState() {
    super.initState();
    // 1. Cria as 3 instâncias de BLoC e inicializa a URL
    // O BLoC agora cria o seu próprio cliente internamente
    _channelBlocs = [
      ChannelBloc('Canal 1')..add(UrlUpdated('${baseURL}canal1')),
      ChannelBloc('Canal 2')..add(UrlUpdated('${baseURL}canal2')),
      ChannelBloc('Canal 3')..add(UrlUpdated('${baseURL}canal3')),
    ];
  }

  @override
  void dispose() {
    // 2. Garante que todos os BLoCs são fechados
    for (var bloc in _channelBlocs) {
      bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3. Usa MultiBlocProvider para fornecer TODOS os BLoCs
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _channelBlocs[0]),
        BlocProvider.value(value: _channelBlocs[1]),
        BlocProvider.value(value: _channelBlocs[2]),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cliente WebSocket Flutter'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 4. Cria o Card e passa a instância correta do BLoC
                ChannelCard(bloc: _channelBlocs[0]),
                ChannelCard(bloc: _channelBlocs[1]),
                ChannelCard(bloc: _channelBlocs[2]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}