import 'package:flutter_test/flutter_test.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

main() {
  // final wsUrl = Uri(
  //   host: '127.0.0.1',
  //   scheme: 'http',
  //   port: 8185,
  //   path: '/profile',
  // );
  test('socket2', () {
    final wsUrl = Uri(
      host: 'io.socialbook.io',
      scheme: 'https',
      port: 443,
      // queryParameters: {
      //   'influencer_id': '$coreUserId',
      // },
      path: '/profile',
    );
    IO.Socket socket = IO.io(
        wsUrl.toString(),
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableReconnection() // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .setQuery({
              'influencer_id': '7391605',
            })
            .enableForceNewConnection()
            .build());
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });
    socket.on('get_profile', (data) => print("get_profile ${data}"));
    socket.onDisconnect((data) => print("onDisconnect ${data}"));
    socket.connect();
  });
}
