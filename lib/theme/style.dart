import 'package:flutter/material.dart';

TextStyle textStyle = const TextStyle(
  color: Color(0XFFFFFFFF),
  fontSize: 32.0,
  fontWeight: FontWeight.normal,
);

Color textFieldColor = const Color.fromRGBO(255, 255, 255, 0.1);

Color primaryColor = const Color(0xFF00c497);

TextStyle buttonTextStyle = const TextStyle(
  color: Color.fromRGBO(255, 255, 255, 0.8),
  fontSize: 14.0,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.bold,
);

BoxDecoration buildBoxDecoration(Color color, String imageString) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: const <BoxShadow>[
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10.0,
        offset: Offset(0.0, 10.0),
      ),
    ],
    image: DecorationImage(
      image: AssetImage(imageString),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5),
        BlendMode.dstATop,
      ),
    ),
  );
}

class LoginColors {
  const LoginColors();

  static const Color loginGradientStart = Color(0xFF1a256f);
  static const Color loginGradientEnd = Color(0xFF1a256f);

  static const primaryGradient = LinearGradient(
    colors: [loginGradientStart, loginGradientEnd],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
