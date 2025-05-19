import 'package:bbc_client/color_palette.dart';
import 'package:flutter/material.dart';

final titleScreenButtonStyle = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: const BorderSide(width: 3, color: ColorPalette.dark),
    backgroundColor: ColorPalette.blue1,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    foregroundColor: Colors.black87,
    textStyle: TextStyle(fontSize: 30));

final titlePageTextFieldDecoration = InputDecoration(
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
            BorderSide(color: ColorPalette.yellow1.withOpacity(0.9), width: 2)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
            BorderSide(color: ColorPalette.yellow1.withOpacity(0.9), width: 2)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
            BorderSide(color: ColorPalette.yellow1.withOpacity(1.0), width: 2)),
    labelStyle: TextStyle(color: Colors.white),
    fillColor: Colors.black45,
    filled: true,
    contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16));
