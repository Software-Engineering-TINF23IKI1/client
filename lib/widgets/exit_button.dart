/* lib/widgets/comic_button.dart */
import 'package:bbc_client/color_palette.dart';
import 'package:flutter/material.dart';

class ComicButton extends StatelessWidget {
  const ComicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = ColorPalette.red1,
    this.outlineColor = ColorPalette.red3,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color outlineColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, // text colour
        backgroundColor: color,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: outlineColor, width: 4),
        ),
        elevation: 6,
        shadowColor: outlineColor.withOpacity(.6),
        textStyle: textStyle ??
            const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
      child: Text(label),
    );
  }
}
