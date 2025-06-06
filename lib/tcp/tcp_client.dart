import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:bbc_client/constants.dart';
import "package:bbc_client/tcp/packets.dart";
import 'package:flutter/material.dart';

class TCPClient extends ChangeNotifier {
  String? ipAddress;
  int? port;
  Socket? socket;

  String? playerName;
  bool isReady = false;
  String gamecode = "";
  List<JsonObject> players = List.empty();

  // in game
  double currency = 0.0;

  double score = 0.0;
  double clickModifier = 1.0;
  List<JsonObject> topPlayers = List.empty();

  final _packetController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get packetStream => _packetController.stream;

  int _clickBuffer = 0;

  Timer? _clickBufferTimer;

  DateTime _lastCurrencySync = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> createConnection([String? ipAddress, int? port]) async {
    this.ipAddress = ipAddress;
    this.port = port;
    if (ipAddress == null || port == null) {
      throw Exception("IP address and port must be set before connecting.");
    }
    socket = await Socket.connect(this.ipAddress, port);

    if (_clickBufferTimer == null || !_clickBufferTimer!.isActive) {
      print("Creating Timer");
      _clickBufferTimer =
          Timer.periodic(playerClickPackageInterval, (_) => _sendClicks());
    }

    socket?.listen(
      (List<int> data) {
        final packet = createPacketFromResponse(data);
        //packet?.printPacket();
        if (packet != null) {
          handlePacket(packet);
          _packetController.add(packet);
        }
      },
      onDone: () {
        closeConnection();
      },
      onError: (error) {
        closeConnection();
      },
    );
  }

  Future<void> closeConnection() async {
    _clickBufferTimer?.cancel();
    if (socket == null) return;
    socket?.destroy();
    await socket?.close();
    socket = null;
  }

  void handlePacket(PacketLayout packet) {
    switch (packet) {
      case LobbyStatusPacket():
        gamecode = packet.gamecode;
        players = packet.players;

        // update own ready status
        for (JsonObject player in players) {
          if (player['playername'] == playerName) {
            isReady = player['is-ready'];
          }
        }
        break;

      case GameUpdatePacket():
        var now = DateTime.now();
        if (now.difference(_lastCurrencySync) >= currencySyncInterval) {
          print("syncing server");
          currency = packet.currency;
          _lastCurrencySync = now;
        }
        score = packet.score;
        topPlayers = packet.topPlayers;
        clickModifier = packet.clickModifier;
        break;
    }
    notifyListeners();
  }

  PacketLayout? createPacketFromResponse(List<int> data) {
    String response = utf8.decode(data).split('\x1e').first;
    var jsonResponse = jsonDecode(response);
    var jsonBody = jsonResponse['body'];

    switch (jsonResponse['type']) {
      case "exception":
        // maybe add the specific exceptions
        return ExceptionPacket(jsonBody['name'], jsonBody['details']);
      case "lobby-status":
        return LobbyStatusPacket(jsonBody['gamecode'], jsonBody['players']);
      case "game-start":
        return GameStartPacket();
      case "game-update":
        return GameUpdatePacket(
            jsonBody['currency'].toDouble(),
            jsonBody['score'].toDouble(),
            jsonBody['click-modifier'].toDouble(),
            jsonBody['passive-gain'].toDouble(),
            jsonBody['top-players']);
      case "end-routine":
        return EndRoutinePacket(
            jsonBody['score'], jsonBody['is-winner'], jsonBody['scoreboard']);
      case "shop-broadcast":
        return ShopBroadcastPacket(jsonBody['shop_entries']);
      case "shop-purchase-confirmation":
        return ShopPurchaseConfirmationPacket(
            jsonBody['name'], jsonBody['tier']);
    }
    return null;
  }

  void startGame({String playerName = "michi"}) async {
    var packet = StartGamePacket(playerName);
    socket?.add(packet.createPacket());
    this.playerName = playerName;
    print("Starting game with name: $playerName");
  }

  void connectToGame(String gameCode, playerName) async {
    var packet = ConnectToGamePacket(gameCode, playerName);
    socket?.add(packet.createPacket());
    this.playerName = playerName;
    print("Joining game with code: $gameCode");
  }

  void increaseClickBuffer(int numClicks) {
    _clickBuffer += numClicks;
    currency += numClicks * clickModifier;
  }

  void _sendClicks() async {
    if (_clickBuffer > 0) {
      int clicksSent = _clickBuffer;
      _clickBuffer -= clicksSent;
      var packet = PlayerClicksPacket(clicksSent);
      socket?.add(packet.createPacket());
      notifyListeners();
    }
  }

  void togglePlayStatus() {
    updatePlayStatus(!isReady);
  }

  void updatePlayStatus(bool isReady) async {
    var packet = StatusUpdatePacket(isReady);
    socket?.add(packet.createPacket());
    print("Updated play status to: $isReady");
    print("Updating play status to: $isReady");
  }

  @override
  void dispose() {
    _clickBufferTimer?.cancel();
    closeConnection();
    _packetController.close();
    super.dispose();
  }
}
