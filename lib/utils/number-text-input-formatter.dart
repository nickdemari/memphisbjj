import 'package:flutter/services.dart';

class NumberTextInputFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'\d+');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Return early if the text hasn't changed
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    // Filter out non-digit characters
    final String filteredText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final int newTextLength = filteredText.length;
    int selectionIndex = filteredText.length;

    final StringBuffer newText = StringBuffer();
    int usedSubstringIndex = 0;

    // Format text as 123-456-...
    if (newTextLength >= 3) {
      newText.write('${filteredText.substring(0, usedSubstringIndex = 3)}-');
      selectionIndex += 1;
    }
    if (newTextLength >= 6) {
      newText.write('${filteredText.substring(3, usedSubstringIndex = 6)}-');
      selectionIndex += 1;
    }

    // Add the remaining digits without any additional formatting
    if (usedSubstringIndex < newTextLength) {
      newText.write(filteredText.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
