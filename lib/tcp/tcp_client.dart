import 'dart:io';
import 'dart:convert';
import "package:bbc_client/tcp/packets.dart";

class TCPClient {
  String ipAddress;
  int port;
  Socket? socket;

  TCPClient(this.ipAddress, this.port);

  Future<void> createConnection() async {
    socket = await Socket.connect(ipAddress, port);

    socket?.listen(
      (List<int> data) {
        createPacketFromResponse(data).printPacket();
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

  dynamic createPacketFromResponse(List<int> data) {
    String response = utf8.decode(data).replaceAll('\x1e', '');
    var jsonResponse = jsonDecode(response);
    var jsonBody = jsonResponse['body'];

    switch (jsonResponse['type']) {
      case "exception":
        return ExceptionPacket(jsonBody['name'], jsonBody['details']);
      case "lobby-status":
        return LobbyStatusPacket(jsonBody['gamecode'], jsonBody['players']);
      case "game-start":
        return GameStartPacket();
      case "game-update":
        return GameUpdatePacket(
            jsonBody['currency'], jsonBody['score'], jsonBody['top-players']);
      case "end-routine":
        return EndRoutinePacket(
            jsonBody['score'], jsonBody['is-winner'], jsonBody['scoreboard']);
    }
  }

  void startGame() async {
    var packet = StartGamePacket('michi');
    socket?.add(packet.createPacket());
    print("Game started!");
    print(packet.getPlayerName());
  }
}
