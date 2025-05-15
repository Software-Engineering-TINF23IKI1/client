import 'package:bbc_client/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TitleScreen extends StatelessWidget {
  TitleScreen({super.key});

  static final textFieldDecoration = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorPalette.yellow1, width: 2)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorPalette.yellow1, width: 2)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorPalette.yellow1, width: 2)),
      labelStyle: TextStyle(color: Colors.white),
      fillColor: Colors.black45,
      filled: true,
      contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16));

  static final buttonStyle = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: const BorderSide(width: 3, color: ColorPalette.dark),
    backgroundColor: ColorPalette.blue1,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
  );

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
                            decoration: textFieldDecoration.copyWith(
                                labelText: "Enter Player Name"),
                            style: TextStyle(color: Colors.white, fontSize: 20),
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
                                  decoration: textFieldDecoration.copyWith(
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
                                      labelStyle: textFieldDecoration.labelStyle
                                          ?.copyWith(fontSize: 18),
                                      hintStyle:
                                          TextStyle(color: Colors.white70)),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {}, // later: mark ready
                                style: buttonStyle,
                                child: const Text(
                                  'Join Game',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.black87),
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
                            onPressed: () {}, // later: mark ready
                            style: buttonStyle,
                            child: const Text(
                              'Create Game',
                              style: TextStyle(
                                  fontSize: 30, color: Colors.black87),
                            ),
                          ),
                        ),
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
}
