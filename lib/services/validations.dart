class Validations {
  String validateField(String value) {
    if (value.isEmpty) return 'This field is required.';
    final RegExp nameExp = new RegExp(r'^[A-za-z ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  String validateEmpty(String value) {
    if (value.isEmpty) return 'This field is required';
    return null;
  }

  String validateEmail(String value) {
    if (value.isEmpty) return 'Email is required.';
    final RegExp nameExp = new RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$');
    if (!nameExp.hasMatch(value)) return 'Invalid email address';
    return null;
  }

  String validatePassword(String value) {
    if (value.isEmpty) return 'Please choose a password.';
    return null;
  }

  String validatePhoneNumber(String value) {
    if (value.isEmpty) return 'Phone number is required';
    final RegExp phoneExp = RegExp(r'^\d\d\d\-\d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(value))
      return '(###) ###-#### - Enter a US phone number.';
    return null;
  }

  String validateZipCode(String value) {
    if (value.isEmpty) return 'Zip code is required';
    final RegExp zipCode = RegExp(r'(^\d{5}$)|(^\d{5}-\d{4}$)');
    if (!zipCode.hasMatch(value))
      return 'Enter valid zip code';
    return null;
  }
}
