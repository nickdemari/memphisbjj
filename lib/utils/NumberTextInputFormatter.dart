import 'package:flutter/services.dart';

class NumberTextInputFormatter extends TextInputFormatter {
  WhitelistingTextInputFormatter formatter = WhitelistingTextInputFormatter(new RegExp(r'\d+'));
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    TextEditingValue formattedValue = formatter.formatEditUpdate(oldValue, newValue);
    if(oldValue.text == newValue.text){
      return newValue;
    }
    final int newTextLength = formattedValue.text.length;

    int selectionIndex = formattedValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = new StringBuffer();
    if (newTextLength >= 4) {
      newText.write(formattedValue.text.substring(0, usedSubstringIndex = 3) + '-');
      if (formattedValue.selection.end >= 3) selectionIndex += 2;
    }
    if (newTextLength >= 7) {
      newText.write(formattedValue.text.substring(3, usedSubstringIndex = 6) + '-');
      if (formattedValue.selection.end >= 6) selectionIndex++;
    }
    if (newTextLength >= 11) {
      newText.write(formattedValue.text.substring(6, usedSubstringIndex = 10) + '');
      if (formattedValue.selection.end >= 10) selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(formattedValue.text.substring(usedSubstringIndex));

    if(oldValue != null && oldValue.text != null && oldValue.text.length > newText.toString().length){
      //selectionIndex++;
    }

    if(oldValue.text == newText.toString()){
      return oldValue;
    }
    return new TextEditingValue(
      text: newText.toString(),
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}