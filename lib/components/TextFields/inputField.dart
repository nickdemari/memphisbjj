import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  IconData icon;
  String hintText;
  TextInputType textInputType;
  Color textFieldColor, iconColor;
  bool obscureText;
  double bottomMargin;
  TextStyle textStyle, hintStyle;
  var validateFunction;
  var onSaved;
  Key key;
  String fromProfile;
  List<TextInputFormatter> formatters;
  int maxLength;

  //passing props in the Constructor.
  InputField(
      {
        this.key,
        this.hintText,
        this.obscureText,
        this.textInputType,
        this.textFieldColor,
        this.icon,
        this.iconColor,
        this.bottomMargin,
        this.textStyle,
        this.validateFunction,
        this.onSaved,
        this.hintStyle,
        this.fromProfile,
        this.formatters,
        this.maxLength
      });

  @override
  Widget build(BuildContext context) {
    return (new Container(
        margin: new EdgeInsets.only(bottom: bottomMargin),
        child: new DecoratedBox(
          decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
              color: textFieldColor),
          child: new TextFormField(
            textCapitalization: TextCapitalization.words,
            style: textStyle,
            enableInteractiveSelection: true,
            initialValue: fromProfile == null ? "" : fromProfile,
            key: key,
            obscureText: obscureText,
            keyboardType: textInputType,
            validator: validateFunction,
            onSaved: onSaved,
            inputFormatters: formatters,
            maxLength: maxLength,
            decoration: new InputDecoration(
              hintText: hintText,
              hintStyle: hintStyle,
              icon: new Icon(
                icon,
                color: iconColor,
              ),
            ),
          ),
        )));
  }
}
