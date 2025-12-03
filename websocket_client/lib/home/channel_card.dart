// lib/channel_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:websocket_client/bloc/channel_bloc.dart';
import 'package:websocket_client/bloc/channel_event.dart';
import 'package:websocket_client/bloc/channel_state.dart';

class ChannelCard extends StatelessWidget {
  final ChannelBloc bloc;

  // Usamos um controlador interno para gerenciar o TextField
  final TextEditingController _urlController;

  ChannelCard({required this.bloc, super.key})
    : _urlController = TextEditingController(
        text: bloc.state.url,
      ); // Inicializa com o valor do BLoC

  // Função para alternar a conexão (Start/Stop)
  void _toggleConnection() {
    bloc.add(const ConnectToggled());
  }

  @override
  Widget build(BuildContext context) {
    // O BlocBuilder escuta APENAS a instância do BLoC que lhe foi passada
    return BlocBuilder<ChannelBloc, ChannelState>(
      bloc: bloc,
      builder: (context, state) {
        // Se o URL no BLoC for diferente do controlador, atualiza o controlador.
        // Isto é importante se a URL for alterada por um evento externo.
        if (_urlController.text != state.url) {
          _urlController.text = state.url;
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título e Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.channelName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: state.statusConnect == EStatusConnect.conectado ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        state.statusConnect == EStatusConnect.conectado ? 'CONECTADO' : 'DESCONECTADO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Campo de Endereço (URL)
                TextField(
                  controller: _urlController,
                  enabled: state.statusConnect == EStatusConnect.desconectado,
                  decoration: const InputDecoration(
                    labelText: 'Endereço WebSocket (ws://...)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => bloc.add(UrlUpdated(value)),
                ),

                const SizedBox(height: 10),

                // Botão Start/Stop
                ElevatedButton(
                  onPressed:  state.statusConnect == EStatusConnect.conectando ? null : _toggleConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.statusConnect == EStatusConnect.conectado
                        ? Colors.red
                        : Colors.green,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: state.statusConnect == EStatusConnect.conectando
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Conectando...'
                            ),
                          ],
                        )
                      : Text(
                          state.statusConnect == EStatusConnect.conectado
                              ? '🛑 Parar Conexão'
                              : '▶️ Iniciar Conexão',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),

                const SizedBox(height: 15),
                const Text(
                  'Últimas Mensagens Recebidas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Área de Exibição das Mensagens (Lista)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade50,
                  ),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          message,
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(ClearMessages());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: Text(
                    ' 🗑️ Limpar',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
