enum PasswordStrength {
  Weak,
  Medium,
  Strong,
}

/**
 * 使用方法
 * String password = 'MySecurePassword123!';
 * PasswordStrength strength = PasswordUtil.checkPasswordStrength(password);
 */
class PasswordUtil {
  // 密码强度检测方法，接受一个密码字符串作为输入，返回密码强度的枚举值
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 8) {
      return PasswordStrength.Weak; // 如果密码长度小于8，则认为是弱密码
    } else if (password.length < 12) {
      // 如果密码长度在8到11之间
      if (RegExp(r'[A-Z]').hasMatch(password) && // 包含大写字母
          RegExp(r'[a-z]').hasMatch(password) && // 包含小写字母
          RegExp(r'[0-9]').hasMatch(password)) {
        // 包含数字
        return PasswordStrength.Medium; // 认为是中等强度密码
      } else {
        return PasswordStrength.Weak; // 不满足中等强度条件，认为是弱密码
      }
    } else {
      // 如果密码长度大于等于12
      if (RegExp(r'[A-Z]').hasMatch(password) && // 包含大写字母
          RegExp(r'[a-z]').hasMatch(password) && // 包含小写字母
          RegExp(r'[0-9]').hasMatch(password) && // 包含数字
          RegExp(r'[!@#\$%^&*]').hasMatch(password)) {
        // 包含特殊字符
        return PasswordStrength.Strong; // 认为是强密码
      } else {
        return PasswordStrength.Medium; // 不满足强密码条件，认为是中等强度密码
      }
    }
  }
}
