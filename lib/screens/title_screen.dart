import 'dart:async';

import 'package:bbc_client/color_palette.dart';
import 'package:bbc_client/constants.dart';
import 'package:bbc_client/screens/lobby_screen.dart';
import 'package:bbc_client/tcp/packets.dart';
import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:bbc_client/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbc_client/screens/route_observer.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> with RouteAware {
  final serverAdressController = TextEditingController();
  final playerNameController = TextEditingController();
  final gameCodeController = TextEditingController();

  late StreamSubscription _packetSubscription;

  (String, int) seperateIpAndPort(String ipAddress) {
    final parts = ipAddress.split(':');
    if (parts.length == 2) {
      return (parts[0], int.parse(parts[1]));
    } else {
      return (ipAddress, defaultPort);
    }
  }

  @override
  void initState() {
    super.initState();
    attachPacketListener();
  }

  @override
  void didPopNext() {
    attachPacketListener();
  }

  void attachPacketListener() {
    final client = context.read<TCPClient>();
    _packetSubscription = client.packetStream.listen((packet) {
      if (packet is LobbyStatusPacket) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LobbyScreen(),
          ),
        );
        _packetSubscription.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        SizedBox.expand(
            child: Image.asset('assets/title_screen/background.png',
                fit: BoxFit.cover)),
        SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // --- Left Side ---
              Expanded(
                  child: AspectRatio(
                aspectRatio: 1,
                child: Column(
                  children: [
                    Expanded(
                        child:
                            Image.asset('assets/title_screen/title_text.png')),
                    Expanded(
                      child: FractionallySizedBox(
                          heightFactor: 0.5,
                          widthFactor: 0.5,
                          alignment: Alignment.topCenter,
                          child: Image.asset('assets/title_screen/banana.png')),
                    ),
                  ],
                ),
              )),

              // --- Right Side ---
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: TextField(
                            controller: serverAdressController,
                            decoration: titlePageTextFieldDecoration.copyWith(
                                labelText: "Server Address",
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: ColorPalette.yellow1
                                            .withOpacity(0.6),
                                        width: 2)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: ColorPalette.yellow1
                                            .withOpacity(0.6),
                                        width: 2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: ColorPalette.yellow1
                                            .withOpacity(1.0),
                                        width: 2)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24)),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          child: TextField(
                            controller: playerNameController,
                            decoration: titlePageTextFieldDecoration.copyWith(
                              labelText: "Enter Player Name",
                            ),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 70),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 170,
                                child: TextField(
                                  controller: gameCodeController,
                                  decoration: titlePageTextFieldDecoration
                                      .copyWith(
                                          labelText: "Game Code",
                                          hintText: "XXXXXX",
                                          prefixIconConstraints:
                                              const BoxConstraints(
                                                  minWidth: 10),
                                          prefixIcon: const Text(
                                              "   #  ",
                                              style:
                                                  TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 20)),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          labelStyle:
                                              titlePageTextFieldDecoration
                                                  .labelStyle
                                                  ?.copyWith(fontSize: 18),
                                          hintStyle: const TextStyle(
                                              color: Colors.white70)),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => handleJoinGameButton(context),
                                style: titleScreenButtonStyle,
                                child: const Text(
                                  'Join Game',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: ColorPalette.yellow1.withAlpha(200),
                                  thickness: 1.5,
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                height: 35,
                                child: Text(
                                  "or",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: ColorPalette.yellow1.withAlpha(200),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: ColorPalette.yellow1.withAlpha(200),
                                  thickness: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => handleCreateGameButton(context),
                            style: titleScreenButtonStyle,
                            child: const Text(
                              'Create Game',
                            ),
                          ),
                        ),
                        const Spacer()
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ))
      ],
    ));
  }

  void handleJoinGameButton(BuildContext context) {
    final TCPClient tcpClient = Provider.of<TCPClient>(context, listen: false);
    var (ipAddress, port) = seperateIpAndPort(serverAdressController.text);

    print("Connecting to server: $ipAddress:$port");

    tcpClient.closeConnection().then((_) {
      tcpClient.createConnection(ipAddress, port).then((_) {
        tcpClient.connectToGame(
            gameCodeController.text, playerNameController.text);
      }).onError((Object error, StackTrace stackTrace) {
        print("$error\n <Error connecting to server: $ipAddress:$port");
        return null;
      });
    });
  }

  void handleCreateGameButton(BuildContext context) {
    final TCPClient tcpClient = Provider.of<TCPClient>(context, listen: false);
    var (ipAddress, port) = seperateIpAndPort(serverAdressController.text);

    print("Connecting to server: $ipAddress:$port");

    tcpClient.closeConnection().then((_) {
      print("creating new connection in handle button");
      tcpClient.createConnection(ipAddress, port).then((_) {
        tcpClient.startGame(playerName: playerNameController.text);
      }).onError((Object error, StackTrace stackTrace) {
        print("$error\n <Error connecting to server: $ipAddress:$port");
        return null;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(AssetImage('assets/title_screen/background.png'), context);

    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    serverAdressController.dispose();
    playerNameController.dispose();
    gameCodeController.dispose();
    _packetSubscription.cancel();
    super.dispose();
  }
}
