import 'dart:io';
import 'dart:convert';
import "package:bbc_client/tcp/packets.dart";

Socket? socket;

// socket.listen freezes && make this class based

Future<void> createConnection() async {
  socket = await Socket.connect('127.0.0.1', 65432);

  socket?.listen(
    (List<int> data) {
      String response = utf8.decode(data);
      print(response);
    },
    onDone: () {
      print("Connection closed");
      socket?.close();
    },
    onError: (error) {
      socket?.close();
    },
  );
}

void startGame() async {
  var packet = StartGamePacket('michi');
  socket?.add(packet.createPacket());
  print("Game started!");
}
