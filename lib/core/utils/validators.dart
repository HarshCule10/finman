class Validators {
  Validators._();

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter an amount';
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
    if (parsed > 10000000) return 'Amount too large';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your name';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }
}
