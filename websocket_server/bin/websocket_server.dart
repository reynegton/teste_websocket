import 'dart:io';
import 'dart:async'; 

// 🌐 Configurações do Servidor
const int port = 8080;
const String host = '127.0.0.1'; // Use '0.0.0.0' para aceitar conexões externas
final String serverAddress = 'ws://$host:$port/ws/';

// Uma lista de rotas de canais que o servidor suporta
const List<String> channels = ['canal1', 'canal2', 'canal3'];

void main() async {
  try {
    // 1. Cria o servidor HTTP
    final server = await HttpServer.bind(host, port);
    print('✅ Servidor WebSocket iniciado em http://$host:$port');
    print('🔗 Endereços dos Canais (para configurar no Flutter App):');
    for (var channel in channels) {
      print('- Canal "$channel": $serverAddress$channel');
    }

    // 2. Escuta por requisições
    await for (HttpRequest request in server) {
      
      // Verificação de Upgrade via Cabeçalho (a forma moderna para Dart 3.x)
      final isUpgrade = request.headers.value('Upgrade')?.toLowerCase() == 'websocket';

      if (isUpgrade) {
        
        // Encontra o nome do canal na URL (e.g., '/ws/canal1' -> 'canal1')
        final String path = request.uri.path;
        final List<String> segments = path.split('/');
        final String channelName = segments.isNotEmpty ? segments.last : '';
        
        // Verifica se a rota é válida e é uma rota de WebSocket esperada
        if (path.startsWith('/ws/') && channels.contains(channelName)) {
          // 3. Faz o upgrade para WebSocket
          final WebSocket socket = await WebSocketTransformer.upgrade(request);
          print('🟢 Cliente conectado ao Canal "$channelName"');
          
          // 4. Inicia o envio de dados fictícios
          startDataStream(socket, channelName);
          
          // 5. Escuta por fechamento da conexão
          socket.done.then((_) {
            print('🔴 Cliente desconectado do Canal "$channelName"');
          });
        } else {
          // Rota WebSocket inválida
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('Rota WebSocket inválida: $path')
            ..close();
        }
      } else {
        // Resposta para requisições HTTP normais
        request.response
          ..statusCode = HttpStatus.ok
          ..write('Servidor Dart WebSocket funcionando.')
          ..close();
      }
    }
  } catch (e) {
    print('❌ Erro ao iniciar o servidor: $e');
  }
}

// Função que inicia o envio periódico de dados para um socket específico
void startDataStream(WebSocket socket, String channelName) {
  // Intervalo de 1ms para envio
  const Duration interval = Duration(milliseconds: 1);
  
  // Cria um Timer periódico
  Timer? timer = Timer.periodic(interval, (timer) {
    // Verifica se o socket ainda está aberto
    if (socket.readyState == WebSocket.open) {
      // 📝 Cria a mensagem fictícia com timestamp
      final DateTime now = DateTime.now();
      
      final String hora = now.hour.toString().padLeft(2, '0');
      final String minuto = now.minute.toString().padLeft(2, '0');
      final String segundo = now.second.toString().padLeft(2, '0');
      final String milissegundo = now.millisecond.toString().padLeft(3, '0');
      final String microsegundo = now.microsecond.toString().padLeft(3, '0');
      
      final String timestamp = '$hora:$minuto:$segundo.$milissegundo.$microsegundo';
      
      final String message = 'Servidor Canal $channelName: Mensagem em ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} às $timestamp';
      
      // Envia a mensagem
      socket.add(message);
    } else {
      // Se o socket estiver fechado, cancela o timer
      print('Timer do Canal "$channelName" cancelado.');
      timer.cancel();
    }
  });

  // Garante que o timer será cancelado quando o socket for fechado
  socket.done.then((_) {
    if (timer.isActive) {
      timer.cancel();
    }
  });
}