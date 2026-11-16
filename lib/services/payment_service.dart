import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../models/payment_transaction.dart';

/// Dịch vụ tích hợp API thanh toán trực tuyến cho DormHub.
/// Hỗ trợ:
/// 1. VietQR (Quét mã Napas 247 chuyển khoản ngân hàng tự động).
/// 2. Cổng VNPay v2.1.0 Sandbox với chữ ký bảo mật HMAC-SHA512.
/// 3. Ví điện tử MoMo.
class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  // Cấu hình tài khoản thụ hưởng VietQR ký túc xá
  static const String vietQrBankId = 'MB'; // MB Bank
  static const String vietQrBankName = 'MB Bank (Ngân hàng Quân Đội)';
  static const String vietQrAccountNo = '0389999888';
  static const String vietQrAccountName = 'KY TUC XA DORMHUB';

  // Cấu hình VNPay Gateway Sandbox v2.1.0
  // Chỉ được cấu hình trên máy chủ tin cậy khi tích hợp VNPay thật.
  static const String vnpTmnCode = '';
  static const String vnpHashSecret = '';
  static const String vnpUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String vnpReturnUrl = 'https://dormhub.university.edu.vn/payment/vnpay_return';

  // Danh sách các giao dịch thanh toán
  final List<PaymentTransaction> _transactions = [];

  List<PaymentTransaction> get transactions => List.unmodifiable(_transactions);

  List<PaymentTransaction> getTransactionsForEmail(String email) {
    return _transactions
        .where((t) => t.payerEmail.toLowerCase() == email.toLowerCase())
        .toList();
  }

  /// Sinh mã nội dung chuyển khoản chuẩn hóa (VD: DORMHUB HD1026015 SV2026001)
  String generateTransferContent(String billId, String? studentCode) {
    final cleanBillId = billId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final cleanCode = (studentCode ?? '').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return 'DORMHUB $cleanBillId $cleanCode'.trim();
  }

  /// Sinh URL ảnh mã VietQR Napas 247 động
  String generateVietQrUrl({
    required double amount,
    required String transferContent,
  }) {
    final encodedContent = Uri.encodeComponent(transferContent);
    final encodedName = Uri.encodeComponent(vietQrAccountName);
    final cleanAmount = amount.toInt();
    return 'https://img.vietqr.io/image/$vietQrBankId-$vietQrAccountNo-compact2.png?amount=$cleanAmount&addInfo=$encodedContent&accountName=$encodedName';
  }

  /// Khởi tạo URL thanh toán VNPay v2.1.0 với chữ ký mã hóa HMAC-SHA512
  String generateVNPayUrl({
    required String txnRef,
    required double amount,
    required String orderInfo,
    String? bankCode,
    String? ipAddress,
  }) {
    if (vnpTmnCode.isEmpty || vnpHashSecret.isEmpty) {
      throw StateError('VNPay chưa được cấu hình trên máy chủ.');
    }
    final now = DateTime.now();
    final createDate = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    final vnpAmount = (amount * 100).toInt().toString();

    final params = <String, String>{
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': vnpTmnCode,
      'vnp_Amount': vnpAmount,
      'vnp_CreateDate': createDate,
      'vnp_CurrCode': 'VND',
      'vnp_IpAddr': ipAddress ?? '127.0.0.1',
      'vnp_Locale': 'vn',
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'billpayment',
      'vnp_ReturnUrl': vnpReturnUrl,
      'vnp_TxnRef': txnRef,
    };

    if (bankCode != null && bankCode.isNotEmpty) {
      params['vnp_BankCode'] = bankCode;
    }

    // Sắp xếp các tham số theo thứ tự alphabet theo chuẩn VNPay
    final sortedKeys = params.keys.toList()..sort();
    final queryBuffer = StringBuffer();
    final hashBuffer = StringBuffer();

    for (var i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final value = params[key]!;
      final encodedKey = Uri.encodeQueryComponent(key);
      final encodedValue = Uri.encodeQueryComponent(value);

      if (i > 0) {
        queryBuffer.write('&');
        hashBuffer.write('&');
      }
      queryBuffer.write('$encodedKey=$encodedValue');
      hashBuffer.write('$key=$value');
    }

    // Tính mã băm HMAC-SHA512
    final key = utf8.encode(vnpHashSecret);
    final bytes = utf8.encode(hashBuffer.toString());
    final hmac = Hmac(sha512, key);
    final secureHash = hmac.convert(bytes).toString();

    return '$vnpUrl?${queryBuffer.toString()}&vnp_SecureHash=$secureHash';
  }

  /// Khởi tạo giao dịch thanh toán trực tuyến
  PaymentTransaction createTransaction({
    required String billId,
    required String title,
    required double amount,
    required String payerEmail,
    required String payerName,
    required PaymentMethod method,
    String? studentCode,
  }) {
    final txnId = 'DH-TXN-${DateTime.now().millisecondsSinceEpoch % 100000000}';
    final transferContent = generateTransferContent(billId, studentCode);

    String? qrUrl;
    String? payUrl;

    if (method == PaymentMethod.vietQR) {
      qrUrl = generateVietQrUrl(amount: amount, transferContent: transferContent);
    } else if (method == PaymentMethod.vnpay) {
      payUrl = generateVNPayUrl(
        txnRef: txnId,
        amount: amount,
        orderInfo: 'Thanh toan hoa don $billId - $title',
      );
    } else if (method == PaymentMethod.momo) {
      qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=2|99|0912345678|KY%20TUC%20XA%20DORMHUB||0|0|${amount.toInt()}|$transferContent|transfer_myqr';
      payUrl = 'momo://app?action=payWithApp&isScan=1';
    }

    final transaction = PaymentTransaction(
      id: txnId,
      billId: billId,
      title: title,
      amount: amount,
      payerEmail: payerEmail,
      payerName: payerName,
      method: method,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
      qrCodeUrl: qrUrl,
      paymentUrl: payUrl,
      bankAccount: vietQrAccountNo,
      bankName: vietQrBankName,
      transferContent: transferContent,
    );

    _transactions.insert(0, transaction);
    return transaction;
  }

  /// Xác thực thanh toán thành công (Mô phỏng kiểm tra Webhook / IPN API)
  Future<bool> verifyAndCompletePayment(String transactionId) async {
    // Chỉ backend xử lý webhook/IPN đã xác minh chữ ký mới được ghi nhận thanh toán.
    return false;
  }
}

