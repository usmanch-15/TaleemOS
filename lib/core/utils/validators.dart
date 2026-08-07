class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email required hai';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Valid email darj karein';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password required hai';
    if (value.length < 8) return 'Password kam az kam 8 characters ka ho';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Password match nahi ho raha';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Naam required hai';
    if (value.trim().length < 3) return 'Naam kam az kam 3 characters ka ho';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number required hai';
    final regex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!regex.hasMatch(value.trim())) return 'Valid phone number darj karein';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP required hai';
    if (value.trim().length != 6) return 'OTP 6 digits ka hona chahiye';
    return null;
  }

  static String? schoolCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'School code required hai';
    return null;
  }
}