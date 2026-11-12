import 'package:flutter/material.dart';

enum PaymentMethod {
  vietQR,
  vnpay,
  momo,
  bankTransfer;

  String get displayName {
    switch (this) {
      case PaymentMethod.vietQR:
        return 'VietQR (Quét mã Napas 247)';
      case PaymentMethod.vnpay:
        return 'Cổng thanh toán VNPay';
      case PaymentMethod.momo:
        return 'Ví điện tử MoMo';
      case PaymentMethod.bankTransfer:
        return 'Chuyển khoản trực tiếp';
    }
  }

  String get shortName {
    switch (this) {
      case PaymentMethod.vietQR:
        return 'VietQR';
      case PaymentMethod.vnpay:
        return 'VNPay';
      case PaymentMethod.momo:
        return 'MoMo';
      case PaymentMethod.bankTransfer:
        return 'Ngân hàng';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.vietQR:
        return Icons.qr_code_scanner_rounded;
      case PaymentMethod.vnpay:
        return Icons.account_balance_rounded;
      case PaymentMethod.momo:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.bankTransfer:
        return Icons.swap_horiz_rounded;
    }
  }
}

enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Chờ thanh toán';
      case PaymentStatus.processing:
        return 'Đang xử lý';
      case PaymentStatus.success:
        return 'Thành công';
      case PaymentStatus.failed:
        return 'Thất bại';
      case PaymentStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

class PaymentTransaction {
  final String id;
  final String billId;
  final String title;
  final double amount;
  final String payerEmail;
  final String payerName;
  final PaymentMethod method;
  PaymentStatus status;
  final DateTime createdAt;
  DateTime? paidAt;
  final String? transactionReference;
  final String? qrCodeUrl;
  final String? paymentUrl;
  final String? bankAccount;
  final String? bankName;
  final String? transferContent;
  final Map<String, dynamic>? rawResponse;

  PaymentTransaction({
    required this.id,
    required this.billId,
    required this.title,
    required this.amount,
    required this.payerEmail,
    required this.payerName,
    required this.method,
    this.status = PaymentStatus.pending,
    required this.createdAt,
    this.paidAt,
    this.transactionReference,
    this.qrCodeUrl,
    this.paymentUrl,
    this.bankAccount,
    this.bankName,
    this.transferContent,
    this.rawResponse,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'billId': billId,
        'title': title,
        'amount': amount,
        'payerEmail': payerEmail,
        'payerName': payerName,
        'method': method.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'paidAt': paidAt?.toIso8601String(),
        'transactionReference': transactionReference,
        'qrCodeUrl': qrCodeUrl,
        'paymentUrl': paymentUrl,
        'bankAccount': bankAccount,
        'bankName': bankName,
        'transferContent': transferContent,
      };
}

