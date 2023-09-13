enum PasswordStrength {
  Weak,
  Medium,
  Strong,
  LengthError,
}

/**
 * 使用方法
 * String password = 'MySecurePassword123!';
 * PasswordStrength strength = PasswordUtil.checkPasswordStrength(password);
 */
class PasswordUtil {
  // 密码强度检测方法，接受一个密码字符串作为输入，返回密码强度的枚举值
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 6 || password.length > 16) {
      return PasswordStrength.LengthError;
    }
    int count = 0;
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      count++;
    }
    if (RegExp(r'[a-z]').hasMatch(password)) {
      count++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) {
      count++;
    }
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) {
      count++;
    }
    if (count < 2) {
      return PasswordStrength.Weak;
    }
    if (count == 2) {
      return PasswordStrength.Medium;
    }
    return PasswordStrength.Strong;
  }
}
