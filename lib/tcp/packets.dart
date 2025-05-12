import 'dart:convert';

typedef JsonObject = Map<String, dynamic>;

class PacketLayout {
  String packetName;
  JsonObject packetBody;

  PacketLayout(this.packetName, this.packetBody);

  List<int> createPacket() {
    JsonObject packet = {'type': packetName, 'body': packetBody};
    String encodedPacket = jsonEncode(packet);
    encodedPacket += "\x1e";
    return utf8.encode(encodedPacket);
  }
}

class StartGamePacket extends PacketLayout {
  String playerName;
  StartGamePacket(this.playerName)
      : super('start-game-session', {'playername': playerName});
}

class ConnectToGamePacket extends PacketLayout {
  String gameCode;
  String playerName;
  ConnectToGamePacket(this.gameCode, this.playerName)
      : super('connect-to-game-session',
            {'gamecode': gameCode, 'playername': playerName});
}

class StatusUpdatePacket extends PacketLayout {
  bool isReady;
  StatusUpdatePacket(this.isReady)
      : super('status-update', {'is-ready': isReady});
}

class PlayerClicksPacket extends PacketLayout {
  int clickCount;
  PlayerClicksPacket(this.clickCount)
      : super('player-clicks', {'count': clickCount});
}
