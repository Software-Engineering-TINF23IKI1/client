import 'dart:convert';

//typedef JsonObject = Map<String, dynamic>;
typedef JsonObject = dynamic;

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

  void printPacket() {
    print(packetName);
    print(packetBody);
  }
}

class StartGamePacket extends PacketLayout {
  String playerName;
  StartGamePacket(this.playerName)
      : super('start-game-session', {'playername': playerName});
  String getPlayerName() {
    return playerName;
  }
}

class ConnectToGamePacket extends PacketLayout {
  String gameCode;
  String playerName;
  ConnectToGamePacket(this.gameCode, this.playerName)
      : super('connect-to-game-session',
            {'gamecode': gameCode, 'playername': playerName});
  String getGameCode() {
    return gameCode;
  }

  String getPlayerName() {
    return playerName;
  }
}

class StatusUpdatePacket extends PacketLayout {
  bool isReady;
  StatusUpdatePacket(this.isReady)
      : super('status-update', {'is-ready': isReady});
  bool getIsReady() {
    return isReady;
  }
}

class PlayerClicksPacket extends PacketLayout {
  int clickCount;
  PlayerClicksPacket(this.clickCount)
      : super('player-clicks', {'count': clickCount});
  int getClickCount() {
    return clickCount;
  }
}

class ExceptionPacket extends PacketLayout {
  String name;
  JsonObject details;
  ExceptionPacket(this.name, this.details)
      : super('exception', {'name': name, 'details': details});
  String getName() {
    return name;
  }

  JsonObject getDetails() {
    return details;
  }
}

class LobbyStatusPacket extends PacketLayout {
  String gamecode;
  List<JsonObject> players;
  LobbyStatusPacket(this.gamecode, this.players)
      : super('lobby-status', {'gamecode': gamecode, 'players': players});
  String getGamecode() {
    return gamecode;
  }

  List<JsonObject> getPlayers() {
    return players;
  }
}

class GameStartPacket extends PacketLayout {
  GameStartPacket() : super('game-start', {});
}

class GameUpdatePacket extends PacketLayout {
  double currency;
  double score;
  List<JsonObject> topPlayers;
  GameUpdatePacket(this.currency, this.score, this.topPlayers)
      : super('game-update',
            {'currency': currency, 'score': score, 'top-players': topPlayers});
  double getCurrency() {
    return currency;
  }

  double getScore() {
    return score;
  }

  List<JsonObject> getTopPlayers() {
    return topPlayers;
  }
}

class EndRoutinePacket extends PacketLayout {
  double score;
  bool isWinner;
  List<JsonObject> scoreboard;
  EndRoutinePacket(this.score, this.isWinner, this.scoreboard)
      : super('end-routine',
            {'score': score, 'is-winner': isWinner, 'scoreboard': scoreboard});
  double getScore() {
    return score;
  }

  bool getIsWinner() {
    return isWinner;
  }

  List<JsonObject> getScoreboard() {
    return scoreboard;
  }
}
