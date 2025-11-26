class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    final re = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (!re.hasMatch(value)) {
      return 'Invalid email format';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    return null;
  }
}

bool isValidEmail(String email) => Validators.email(email) == null;
bool isStrongPassword(String pw) => Validators.password(pw) == null;
