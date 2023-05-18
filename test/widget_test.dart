// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  test('socket', () {
    final wsUrl = Uri(
      host: '127.0.0.1',
      scheme: 'http',
      port: 8185,
      queryParameters: {
        'influencer_id': '7391605',
      },
      path: '/profile',
    );
    IO.Socket socket = IO.io(
        wsUrl.toString(),
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableReconnection() // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());
    socket.onConnect((_) {
      print('connect');
      // socket.emit('msg', 'test');
    });
    socket.onDisconnect((data) {
      print(data);
    });
    socket.on('notification', (data) {
      print(data);
    });
    socket.connect();
  });
}

sortLocalConfigJson(Map<String, String> params) {
  List<String> result = [];
  List<String> list = params.keys.toList();
  list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  list.forEach((element) {
    result.add("\"$element\": \"${params[element]}\"");
  });
  print("{" + result.join(",") + "}");
}
