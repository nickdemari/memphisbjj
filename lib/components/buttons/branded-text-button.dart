import 'package:flutter/material.dart';

class BrandedTextButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback onPressed;
  final TextStyle textStyle;

  const BrandedTextButton({
    Key? key,
    required this.buttonName,
    required this.onPressed,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        buttonName,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}
