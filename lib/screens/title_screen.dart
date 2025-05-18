import 'package:bbc_client/color_palette.dart';
import 'package:bbc_client/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

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
