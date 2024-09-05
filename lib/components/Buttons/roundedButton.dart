import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback onTap;
  final double height;
  final double width;
  final double bottomMargin;
  final double borderWidth;
  final Color buttonColor;

  final TextStyle textStyle;

  const RoundedButton({
    Key? key,
    required this.buttonName,
    required this.onTap,
    this.height = 50.0,
    this.width = 200.0,
    this.bottomMargin = 10.0,
    this.borderWidth = 0.0,
    this.buttonColor = Colors.blue,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.only(bottom: bottomMargin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(30.0),
          border: borderWidth > 0
              ? Border.all(
                  color: const Color.fromRGBO(221, 221, 221, 1.0),
                  width: borderWidth,
                )
              : null,
        ),
        child: Text(
          buttonName,
          style: textStyle,
        ),
      ),
    );
  }
}
