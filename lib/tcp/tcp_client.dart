import 'dart:async';
import 'dart:io';
import 'dart:convert';
import "package:bbc_client/tcp/packets.dart";
import 'package:flutter/material.dart';

class TCPClient extends ChangeNotifier {
  String? ipAddress;
  int? port;
  Socket? socket;

  final _packetController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get packetStream => _packetController.stream;

  Future<void> createConnection([String? ipAddress, int? port]) async {
    this.ipAddress = ipAddress;
    this.port = port;
    if (ipAddress == null || port == null) {
      throw Exception("IP address and port must be set before connecting.");
    }
    socket = await Socket.connect(this.ipAddress, port);

    socket?.listen(
      (List<int> data) {
        final packet = createPacketFromResponse(data);
        packet?.printPacket();
        _packetController.add(packet);
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

    String response = utf8.decode(data).split('\x1e').first;
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

  void startGame({String playerName = "michi"}) async {
    var packet = StartGamePacket(playerName);
    socket?.add(packet.createPacket());
    print("Starting game with name: $playerName");
  }

  void connectToGame(String gameCode, playerName) async {
    var packet = ConnectToGamePacket(gameCode, playerName);
    socket?.add(packet.createPacket());
    print("Joining game with code: $gameCode");
  }

  void updatePlayStatus(bool isReady) async {
    var packet = StatusUpdatePacket(isReady);
    socket?.add(packet.createPacket());
    print("Updated play status to: $isReady");
    print("Updating play status to: $isReady");
  }

  @override
  void dispose() {
    socket?.close();
    _packetController.close();
    super.dispose();
  }
}
