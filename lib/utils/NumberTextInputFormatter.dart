import 'package:flutter/services.dart';

class NumberTextInputFormatter extends TextInputFormatter {
  WhitelistingTextInputFormatter formatter = WhitelistingTextInputFormatter(new RegExp(r'\d+'));
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    TextEditingValue formattedValue = formatter.formatEditUpdate(oldValue, newValue);
    if(oldValue.text == newValue.text){
      return newValue;
    }
    final int newTextLength = formattedValue.text.length;
    int selectionIndex = formattedValue.selection.end;

    int usedSubstringIndex = 0;
    final StringBuffer newText = new StringBuffer();
    if (newTextLength >= 3) {
      newText.write(formattedValue.text.substring(0, usedSubstringIndex = 3) + '-');
      selectionIndex += 1;
    }
    if (newTextLength >= 6) {
      newText.write(formattedValue.text.substring(3, usedSubstringIndex = 6) + '-');
      selectionIndex += 1;
    }

    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(formattedValue.text.substring(usedSubstringIndex));

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}