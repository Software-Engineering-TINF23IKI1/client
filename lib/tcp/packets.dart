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

class PackageParsingExceptionPacket extends ExceptionPacket {
  String stage;
  String rawMsg;
  PackageParsingExceptionPacket(this.stage, this.rawMsg)
      : super('PackageParsingException', {'stage': stage, 'raw_msg': rawMsg});

  String getStage() {
    return stage;
  }

  String getRawMsg() {
    return rawMsg;
  }
}

class InvalidGameCodeExceptionPacket extends ExceptionPacket {
  String code;
  InvalidGameCodeExceptionPacket(this.code)
      : super('InvalidGameCodeExceptionPackage', {'code': code});

  String getCode() {
    return code;
  }
}

class InvalidShopTransactionPacket extends ExceptionPacket {
  String stage;
  String upgradeName;
  String upgradeTier;
  InvalidShopTransactionPacket(this.stage, this.upgradeName, this.upgradeTier)
      : super('PackageParsingException', {
          'stage': stage,
          'upgrade_name': upgradeName,
          'upgrade_tier': upgradeTier
        });

  String getStage() {
    return stage;
  }

  String getUpgradeName() {
    return upgradeName;
  }

  String getUpgradeTier() {
    return upgradeTier;
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
  double clickModifier;
  double passiveGain;
  List<JsonObject> topPlayers;
  GameUpdatePacket(this.currency, this.score, this.clickModifier,
      this.passiveGain, this.topPlayers)
      : super('game-update', {
          'currency': currency,
          'score': score,
          'click-modifier': clickModifier,
          'passive-gain': passiveGain,
          'top-players': topPlayers
        });
  double getCurrency() {
    return currency;
  }

  double getScore() {
    return score;
  }

  double getClickModifier() {
    return clickModifier;
  }

  double getPassiveGain() {
    return passiveGain;
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

class ShopPurchaseRequestPacket extends PacketLayout {
  String upgradeName;
  int tier;
  ShopPurchaseRequestPacket(this.upgradeName, this.tier)
      : super('shop-purchase-request',
            {'upgrade-name': upgradeName, 'tier': tier});
  String getUpgradeName() {
    return upgradeName;
  }

  int getTier() {
    return tier;
  }
}

class ShopBroadcastPacket extends PacketLayout {
  List<JsonObject> shopEntries;
  ShopBroadcastPacket(this.shopEntries)
      : super('shop-broadcast', {'shop_entries': shopEntries});

  List<JsonObject> getShopEntries() {
    return shopEntries;
  }
}

class ShopPurchaseConfirmationPacket extends PacketLayout {
  String name;
  int tier;
  ShopPurchaseConfirmationPacket(this.name, this.tier)
      : super('shop-purchase-confirmation', {'name': name, 'tier': tier});
  String getName() {
    return name;
  }

  int getTier() {
    return tier;
  }
}
