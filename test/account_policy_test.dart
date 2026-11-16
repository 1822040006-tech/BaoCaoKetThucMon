import 'package:flutter_test/flutter_test.dart';
import 'package:dormhub_flutter/config/account_policy.dart';

void main() {
  test('mã sáu chữ số tạo đúng email sinh viên', () {
    expect(AccountPolicy.studentEmail('240001'), '240001@university.com');
    expect(AccountPolicy.isStudentEmail('240001@university.com'), isTrue);
    expect(AccountPolicy.isStudentEmail('MANAGER@UNIVERSITY.COM'), isFalse);
    expect(AccountPolicy.isStaffEmail('MANAGER@UNIVERSITY.COM'), isTrue);
    expect(AccountPolicy.isStaffEmail('240001@university.com'), isFalse);
  });

  test('từ chối mã không đúng sáu chữ số', () {
    for (final code in ['24001', '2400010', 'SV240001', '24A001']) {
      expect(AccountPolicy.isStudentCode(code), isFalse);
      expect(() => AccountPolicy.studentEmail(code), throwsFormatException);
    }
  });
}
