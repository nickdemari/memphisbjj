import 'package:flutter/material.dart';

TextStyle textStyle = const TextStyle(
    color: const Color(0XFFFFFFFF),
    fontSize: 32.0,
    fontWeight: FontWeight.normal);

Color textFieldColor = const Color.fromRGBO(255, 255, 255, 0.1);

Color primaryColor = const Color(0xFF00c497);

TextStyle buttonTextStyle = const TextStyle(
    color: const Color.fromRGBO(255, 255, 255, 0.8),
    fontSize: 14.0,
    fontFamily: "Roboto",
    fontWeight: FontWeight.bold);

BoxDecoration buildBoxDecoration(Color color, String imageString) {
  return BoxDecoration(
      color: color,
      borderRadius:  BorderRadius.circular(8.0),
      boxShadow: <BoxShadow> [
        BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0)
        )
      ],
    image: DecorationImage(
        image: AssetImage(imageString),
        fit: BoxFit.cover,
      colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop)
    )
  );
}

class LoginColors {

  const LoginColors();

  static const Color loginGradientStart = const Color(0xFF6A8D92);
  static const Color loginGradientEnd = const Color(0xFF1a256f);

  static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}