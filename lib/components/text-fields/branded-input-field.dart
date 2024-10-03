import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrandedInputField extends StatelessWidget {
  final IconData? icon;
  final String hintText;
  final TextInputType textInputType;
  final Color textFieldColor;
  final Color? iconColor;
  final bool obscureText;
  final double bottomMargin;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final String? Function(String?)? validateFunction;
  final void Function(String?)? onSaved;
  final Key? fieldKey;
  final String? initialValue;
  final List<TextInputFormatter>? formatters;
  final int? maxLength;
  final String? fromProfile;

  //passing props in the Constructor.
  const BrandedInputField({
    super.key,
    this.fieldKey,
    required this.hintText,
    this.obscureText = false,
    this.textInputType = TextInputType.text,
    this.textFieldColor = Colors.white,
    this.icon,
    this.iconColor,
    this.bottomMargin = 8.0,
    required this.textStyle,
    required this.hintStyle,
    this.validateFunction,
    this.onSaved,
    this.initialValue,
    this.formatters,
    this.maxLength,
    this.fromProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(30.0)),
          color: textFieldColor,
        ),
        child: TextFormField(
          key: fieldKey,
          style: textStyle,
          obscureText: obscureText,
          keyboardType: textInputType,
          validator: validateFunction,
          onSaved: onSaved,
          initialValue: initialValue,
          inputFormatters: formatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle,
            icon: icon != null ? Icon(icon, color: iconColor) : null,
            counterText: '', // Hides the character counter
          ),
        ),
      ),
    );
  }
}
