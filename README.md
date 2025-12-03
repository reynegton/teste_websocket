🚀 Web Socket Test Application
Este projeto é uma aplicação de teste simples, mas eficaz, projetada para demonstrar e validar a comunicação via Web Sockets. A arquitetura é dividida em dois componentes principais: um servidor Dart que atua como emissor contínuo de mensagens, e um cliente Flutter que recebe e exibe essas mensagens.

🌟 Visão Geral
O objetivo principal desta aplicação é fornecer um ambiente de teste funcional para Web Sockets.

Servidor: Implementado em Dart, ele mantém uma conexão Web Socket aberta e envia mensagens continuamente para todos os clientes conectados.

Cliente: Desenvolvido com Flutter, o projeto foi pensado originalmente para ser executado em Desktop (Windows, macOS, Linux), mas é totalmente compatível com Web ou Mobile (Android/iOS). Ele estabelece a conexão com o servidor, escuta as mensagens recebidas e as exibe em tempo real na tela.

🛠️ Configuração e Execução
Para que a aplicação funcione corretamente, é necessário configurar e executar tanto o servidor quanto o cliente.

1. O Servidor (Dart)
O servidor é a fonte dos dados.

Tecnologia: Dart.

Função: Disparar mensagens contínuas no Web Socket.

Execução:

Navegue até o diretório do servidor.

Execute o servidor utilizando o ambiente Dart.
Utilize o comando dart run

2. O Cliente (Flutter)
O cliente é a interface que recebe e exibe os dados.

Tecnologia: Flutter.

Função: Conectar-se ao servidor e exibir as mensagens.

Ajuste de Endereço: Esta é a etapa crucial. O cliente precisa saber onde o servidor está rodando.

Localização: Verifique o arquivo de configuração do cliente.

Alteração: Se você estiver executando o cliente em um dispositivo diferente (ex: o servidor está na sua máquina local e o cliente está no seu celular, ou o servidor em um container/VM e o cliente no seu desktop), você deve ajustar o endereço do Web Socket.

Exemplo Local: Se rodando na mesma máquina, use ws://localhost:PORTA ou ws://127.0.0.1:PORTA.

Exemplo em Rede: Se rodando em máquinas diferentes, use ws://IP_DO_SERVIDOR:PORTA.

Execução:

Navegue até o diretório do cliente Flutter.

Execute o cliente no ambiente de sua preferência (Desktop ou Mobile).

🤝 Contribuições
Sinta-se à vontade para contribuir, abrir issues ou sugerir melhorias.
