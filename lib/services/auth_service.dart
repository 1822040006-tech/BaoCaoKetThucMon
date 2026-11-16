import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/account_policy.dart';

class AuthUserAccount {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'student' | 'manager' | 'technician' | 'admin'
  final String roleDisplay; // 'Sinh viên' | 'Quản lý KTX' | 'Kỹ thuật viên' | 'Quản trị viên'
  final String status; // 'active' | 'disabled'
  final String? studentCode;
  final String? phoneNumber;
  final bool isDemo;

  const AuthUserAccount({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.roleDisplay,
    required this.status,
    this.studentCode,
    this.phoneNumber,
    this.isDemo = false,
  });

  bool get isActive => status == 'active';
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String normalizeRole(String? rawRole) {
    if (rawRole == null) throw const FormatException('Hồ sơ thiếu vai trò.');
    final lower = rawRole.trim().toLowerCase();
    if (lower == 'admin' || lower == 'quản trị viên' || lower == 'quan tri vien') {
      return 'admin';
    }
    if (lower == 'manager' || lower == 'quản lý ktx' || lower == 'quan ly ktx' || lower == 'quản lý') {
      return 'manager';
    }
    if (lower == 'technician' || lower == 'kỹ thuật viên' || lower == 'ky thuat vien') {
      return 'technician';
    }
    if (lower == 'student' || lower == 'sinh viên' || lower == 'sinh vien') {
      return 'student';
    }
    throw const FormatException('Vai trò trong hồ sơ không hợp lệ.');
  }

  static String roleToDisplay(String roleCode) {
    switch (roleCode) {
      case 'admin':
        return 'Quản trị viên';
      case 'manager':
        return 'Quản lý KTX';
      case 'technician':
        return 'Kỹ thuật viên';
      case 'student':
      default:
        return 'Sinh viên';
    }
  }

  static String normalizeStatus(String? rawStatus) {
    if (rawStatus == null) throw const FormatException('Hồ sơ thiếu trạng thái.');
    final lower = rawStatus.trim().toLowerCase();
    if (lower == 'disabled' || lower == 'đã khóa' || lower == 'khoa' || lower == 'inactive') {
      return 'disabled';
    }
    if (lower == 'active' || lower == 'đang hoạt động') return 'active';
    throw const FormatException('Trạng thái trong hồ sơ không hợp lệ.');
  }

  /// Đăng nhập bằng Firebase Authentication và lấy hồ sơ Firestore.
  Future<AuthUserAccount> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Không tìm thấy thông tin xác thực người dùng.');
      }

      // Đọc hồ sơ từ Firestore users/{uid}
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));
      if (!doc.exists) {
        throw const FormatException('Tài khoản chưa có hồ sơ users/{uid} trong Firestore.');
      }

      final data = doc.data()!;
      final roleCode = normalizeRole(data['role'] as String?);
      final statusCode = normalizeStatus(data['status'] as String?);

      if (statusCode != 'active') {
        throw Exception('Tài khoản này đã bị khóa. Vui lòng liên hệ Quản trị viên.');
      }

      return AuthUserAccount(
        uid: user.uid,
        email: user.email ?? email.trim(),
        displayName: (data['displayName'] as String?) ?? user.displayName ?? email.split('@')[0],
        role: roleCode,
        roleDisplay: roleToDisplay(roleCode),
        status: statusCode,
        studentCode: data['studentCode'] as String?,
        phoneNumber: data['phoneNumber'] as String?,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_translateAuthError(e));
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  /// Đăng ký công khai: chỉ được gán vai trò Sinh viên ('student').
  Future<AuthUserAccount> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required String studentCode,
    required String phoneNumber,
  }) async {
    final normalizedEmail = AccountPolicy.studentEmail(studentCode);
    if (email.trim().toLowerCase() != normalizedEmail) {
      throw const FormatException('Email sinh viên phải khớp mã số sinh viên.');
    }
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Đăng ký không thành công.');
      }

      await user.updateDisplayName(fullName);

      // Lưu document vào users/{uid} KHÔNG lưu mật khẩu
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': fullName,
        'email': normalizedEmail,
        'role': 'student',
        'status': 'active',
        'studentCode': studentCode.trim(),
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _auth.signOut();

      return AuthUserAccount(
        uid: user.uid,
        email: normalizedEmail,
        displayName: fullName,
        role: 'student',
        roleDisplay: 'Sinh viên',
        status: 'active',
        studentCode: studentCode.trim(),
        phoneNumber: phoneNumber,
      );
    } on FirebaseAuthException catch (e) {
      if (_auth.currentUser != null) await _auth.signOut();
      throw Exception(_translateAuthError(e));
    } on FirebaseException {
      await _auth.signOut();
      rethrow;
    }
  }

  /// Gửi email khôi phục mật khẩu qua Firebase Authentication.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw Exception(_translateAuthError(e));
    }
  }

  /// Đăng xuất khỏi Firebase Auth
  Future<void> signOut() => _auth.signOut();

  String _translateAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng bởi một tài khoản khác.';
      case 'invalid-email':
        return 'Địa chỉ email không đúng định dạng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'user-disabled':
        return 'Tài khoản người dùng này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Bạn đã thử đăng nhập sai quá nhiều lần. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Không có kết nối mạng. Vui lòng kiểm tra lại đường truyền.';
      default:
        return e.message ?? 'Đã xảy ra lỗi xác thực (${e.code}).';
    }
  }
}
