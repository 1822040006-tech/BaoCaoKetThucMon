/// Quy ước email cho tài khoản mới của DormHub.
class AccountPolicy {
  AccountPolicy._();

  static const domain = 'university.com';
  static const staffEmails = {
    'admin@university.com',
    'manager@university.com',
    'technician@university.com',
  };
  static final RegExp _studentCode = RegExp(r'^[0-9]{6}$');
  static final RegExp _studentEmail = RegExp(r'^[0-9]{6}@university\.com$');

  static bool isStudentCode(String code) => _studentCode.hasMatch(code.trim());

  static String studentEmail(String code) {
    final normalized = code.trim();
    if (!isStudentCode(normalized)) {
      throw const FormatException('Mã sinh viên phải gồm đúng 6 chữ số.');
    }
    return '$normalized@$domain';
  }

  static bool isStudentEmail(String email) =>
      _studentEmail.hasMatch(email.trim().toLowerCase());

  static bool isStaffEmail(String email) =>
      staffEmails.contains(email.trim().toLowerCase());
}
