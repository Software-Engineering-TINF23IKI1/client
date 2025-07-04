import 'package:flutter_test/flutter_test.dart';
import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:bbc_client/tcp/packets.dart';
import 'dart:convert';

void main() async {
  group('TCPClient.parsePacket', () {
    TCPClient client = TCPClient();

    // Äquivalenzklasse Working Packets:

    test('parses valid GameStartPacket (working packets)', () {
      client.packet_ = null;
      dynamic json = """{"type": "game-start", "body": {}}\x1e""";
      client.parsePacket(utf8.encode(json));
      expect(client.packet_, isA<GameStartPacket>());
    });

    test('parses valid LobbyStatusPacket (working packets)', () {
      client = TCPClient();
      client.packet_ = null;
      dynamic json =
          """{"type": "lobby-status","body": {"gamecode": "A0313","players": [{"playername": "michi", "is-ready": "true"}]}}\x1e""";
      client.parsePacket(utf8.encode(json));

      expect(client.packet_, isA<LobbyStatusPacket>());
      expect(
          (client.packet_ as LobbyStatusPacket).getGamecode(), equals('A0313'));
      expect(
          (client.packet_ as LobbyStatusPacket).getPlayers(),
          equals([
            {"playername": "michi", "is-ready": "true"}
          ]));
    });

    // Äquivalenzklasse Missing Packet Information:

    test('throws on invalid LobbyStatusPacket (missing packet information)',
        () {
      client = TCPClient();
      client.packet_ = null;
      String json =
          """{"type": "lobby-status","body": {"gamecode": "A0313"}\x1e""";
      try {
        client.parsePacket(utf8.encode(json));
      } on Exception catch (_) {
        client.packet_ = null;
      }
      expect(client.packet_, null);
    });

    test('throws on unknown packet type (missing packet information)', () {
      client = TCPClient();
      client.packet_ = null;
      dynamic json = """{"type": "unknown-package", "body": {}}\x1e""";
      client.parsePacket(utf8.encode(json));
      expect(client.packet_, null);
    });

    // Äquivalenzklasse Invalid Packet String:

    test('throws on empty json (invalid packet string)', () {
      client = TCPClient();
      client.packet_ = null;
      dynamic json = "{}\x1e";
      client.parsePacket(utf8.encode(json));
      expect(client.packet_, null);
    });

    test('throws on invalid string (invalid packet string)', () {
      client = TCPClient();
      client.packet_ = null;
      dynamic json = "test";
      client.parsePacket(utf8.encode(json));
      expect(client.packet_, null);
    });

    // Äquivalenzklasse Multiple Packets:

    test('throws on missing delimiter (multiple packets)', () {
      client = TCPClient();
      client.packet_ = null;
      dynamic json =
          """{"type": "game-start", "body": {}}{"type": "game-start", "body": {}}""";
      client.parsePacket(utf8.encode(json));
      expect(client.packet_, null);
    });

    test('parses packages through multiple delimiters (multiple packets)', () {
      client = TCPClient();
      client.packet_ = null;
      dynamic json =
          """{"type": "game-start", "body": {}}\x1e{"type": \x1e"game-start", "body": {}}""";
      client.parsePacket(utf8.encode(json));
      expect(client.packet_, isA<GameStartPacket>());
    });
  });
}
