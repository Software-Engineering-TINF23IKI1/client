import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:bbc_client/shop_entry.dart';
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
  List<JsonObject> topPlayers = List.empty();
  final List<ShopEntry> _shopEntries = [];
  List<ShopEntry> get shopEntries => List.unmodifiable(_shopEntries);
  // shop
  final _packetController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get packetStream => _packetController.stream;
  // pending shop purchases
  final Set<String> _pendingUpgrades = {};
  bool _isPurchasePending(String name, int tier) =>
      _pendingUpgrades.contains('$name#$tier');
  bool isPurchasePending(String name, int tier) {
    return _isPurchasePending(name, tier);
  }

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

      case ShopBroadcastPacket():
        _shopEntries.clear();
        _shopEntries.addAll(parseShopEntries(packet.shopEntries));
        break;

      case GameUpdatePacket():
        currency = packet.currency;
        score = packet.score;
        topPlayers = packet.topPlayers;
        break;

      case ShopPurchaseConfirmationPacket():
        final key = '${packet.getName()}#${packet.getTier()}';
        _pendingUpgrades.remove(key);

        // find the entry
        final entry =
            _shopEntries.firstWhere((e) => e.name == packet.getName());

        switch (entry) {
          case SingleEntry e:
            e.bought = true;
            break;
          case TieredEntry e:
            e.currentLevel = packet.getTier() + 1; // server tier is 0-based
            break;
        }
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

  void togglePlayStatus() {
    updatePlayStatus(!isReady);
  }

  void updatePlayStatus(bool isReady) async {
    var packet = StatusUpdatePacket(isReady);
    socket?.add(packet.createPacket());
    print("Updated play status to: $isReady");
    print("Updating play status to: $isReady");
    notifyListeners();
  }

  Future<void> buyShopEntry(ShopEntry entry) async {
    final (name, tier) = switch (entry) {
      SingleEntry e => (e.name, 0),
      TieredEntry e when !e.maxed => (e.name, e.currentLevel),
      _ => throw StateError('Nothing to buy'),
    };

    // make sure the entry is not already pending
    if (_isPurchasePending(name, tier)) return;
    _pendingUpgrades.add('$name#$tier');
    notifyListeners(); // disables the button

    // 3. Emit the packet
    final pkt = ShopPurchaseRequestPacket(name, tier);
    socket?.add(pkt.createPacket());

    unawaited(_timeoutPending(name, tier));
  }

  Future<void> _timeoutPending(String name, int tier) async {
    await Future<void>.delayed(const Duration(seconds: 5));
    _pendingUpgrades.remove('$name#$tier');
    notifyListeners();
  }

  @override
  void dispose() {
    socket?.close();
    _packetController.close();
    super.dispose();
  }
}
