import 'package:bbc_client/color_palette.dart';
import 'package:bbc_client/constants.dart';
import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:bbc_client/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  final serverAdressController = TextEditingController();
  final playerNameController = TextEditingController();
  final gameCodeController = TextEditingController();

  (String, int) seperateIpAndPort(String ipAddress) {
    final parts = ipAddress.split(':');
    if (parts.length == 2) {
      return (parts[0], int.parse(parts[1]));
    } else {
      return (ipAddress, defaultPort);
    }
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
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24)),
                            style: TextStyle(color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          child: TextField(
                            decoration: titlePageTextFieldDecoration.copyWith(
                              labelText: "Enter Player Name",
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 20),
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
                                  decoration:
                                      titlePageTextFieldDecoration
                                          .copyWith(
                                              labelText: "Game Code",
                                              hintText: "XXXXXX",
                                              prefixIconConstraints:
                                                  BoxConstraints(minWidth: 10),
                                              prefixIcon: Text("   #  ",
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 20)),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              labelStyle:
                                                  titlePageTextFieldDecoration
                                                      .labelStyle
                                                      ?.copyWith(fontSize: 18),
                                              hintStyle: TextStyle(
                                                  color: Colors.white70)),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
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
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: titleScreenButtonStyle,
                            child: const Text(
                              'Create Game',
                            ),
                          ),
                        ),
                        Spacer()
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

    if (tcpClient.socket == null) {
      tcpClient.createConnection(ipAddress, port).then((_) {
        tcpClient.connectToGame(
            gameCodeController.text, playerNameController.text);
      }).onError(() => print("Error connecting to server: $ipAddress:$port"));
    } else if (tcpClient.ipAddress == null) {
      tcpClient.socket?.close();
      tcpClient.createConnection();
    }
    Provider.of<TCPClient>(context, listen: false)
        .connectToGame("XXXXXX", "PlayerName");
  }
}
