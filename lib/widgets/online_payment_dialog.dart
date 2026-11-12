import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/payment_transaction.dart';
import '../services/payment_service.dart';
import '../theme/app_theme.dart';

/// Hộp thoại thanh toán trực tuyến đa kênh (VietQR, VNPay, MoMo)
class OnlinePaymentDialog extends StatefulWidget {
  final Map<String, dynamic> bill;
  final String payerEmail;
  final String payerName;
  final String? studentCode;
  final VoidCallback? onPaymentSuccess;

  const OnlinePaymentDialog({
    super.key,
    required this.bill,
    required this.payerEmail,
    required this.payerName,
    this.studentCode,
    this.onPaymentSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> bill,
    required String payerEmail,
    required String payerName,
    String? studentCode,
    VoidCallback? onPaymentSuccess,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OnlinePaymentDialog(
        bill: bill,
        payerEmail: payerEmail,
        payerName: payerName,
        studentCode: studentCode,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<OnlinePaymentDialog> createState() => _OnlinePaymentDialogState();
}

class _OnlinePaymentDialogState extends State<OnlinePaymentDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.vietQR;
  PaymentTransaction? _currentTransaction;
  bool _isProcessing = false;
  bool _isSuccess = false;
  int _countdownSeconds = 900; // 15 phút
  Timer? _countdownTimer;

  // Lựa chọn kênh con của VNPay
  String _vnpayBankOption = 'VNPAYQR';

  @override
  void initState() {
    super.initState();
    _initTransaction();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  double _parseAmount(dynamic rawAmount) {
    if (rawAmount is num) return rawAmount.toDouble();
    if (rawAmount is String) {
      final sanitized = rawAmount.replaceAll(RegExp(r'[^0-9]'), '');
      return double.tryParse(sanitized) ?? 0.0;
    }
    return 0.0;
  }

  void _initTransaction() {
    final amount = _parseAmount(widget.bill['amount'] ?? widget.bill['rentAmount'] ?? 0);
    final billId = widget.bill['id']?.toString() ?? 'HD-DEMO';
    final title = widget.bill['title']?.toString() ?? 'Hóa đơn ký túc xá';

    _currentTransaction = PaymentService.instance.createTransaction(
      billId: billId,
      title: title,
      amount: amount,
      payerEmail: widget.payerEmail,
      payerName: widget.payerName,
      method: _selectedMethod,
      studentCode: widget.studentCode,
    );
  }

  void _changeMethod(PaymentMethod method) {
    if (_selectedMethod == method) return;
    setState(() {
      _selectedMethod = method;
      _initTransaction();
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_currentTransaction == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    final success = await PaymentService.instance.verifyAndCompletePayment(_currentTransaction!.id);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
      widget.onPaymentSuccess?.call();
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác thực thất bại hoặc chưa nhận được giao dịch. Vui lòng thử lại.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatMoney(double amount) {
    final intVal = amount.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()} ₫';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: _isSuccess ? _buildSuccessView() : _buildPaymentForm(isMobile),
      ),
    );
  }

  Widget _buildPaymentForm(bool isMobile) {
    final txn = _currentTransaction!;
    final billId = widget.bill['id'] ?? 'Hóa đơn';
    final billTitle = widget.bill['title'] ?? 'Phí lưu trú ký túc xá';
    final room = widget.bill['room'] ?? 'KTX';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payment_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thanh toán trực tuyến',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$billId • Phòng $room',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Scrollable Body
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khung số tiền thanh toán
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              billTitle,
                              style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatMoney(txn.amount),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 14, color: Colors.amber.shade900),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimer(_countdownSeconds),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Lựa chọn phương thức thanh toán
                const Text(
                  'Chọn phương thức thanh toán',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMethodChip(PaymentMethod.vietQR, 'VietQR (Napas 247)', Icons.qr_code_scanner_rounded),
                    _buildMethodChip(PaymentMethod.vnpay, 'Cổng VNPay', Icons.account_balance_rounded),
                    _buildMethodChip(PaymentMethod.momo, 'Ví MoMo', Icons.account_balance_wallet_rounded),
                  ],
                ),
                const SizedBox(height: 20),

                // Nội dung chi tiết theo phương thức
                if (_selectedMethod == PaymentMethod.vietQR)
                  _buildVietQrContent(txn)
                else if (_selectedMethod == PaymentMethod.vnpay)
                  _buildVNPayContent(txn)
                else
                  _buildMoMoContent(txn),
              ],
            ),
          ),
        ),

        // Footer Actions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              TextButton(
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedMethod == PaymentMethod.vnpay
                      ? const Color(0xFF005BAA)
                      : _selectedMethod == PaymentMethod.momo
                          ? const Color(0xFFA50064)
                          : AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  _isProcessing
                      ? 'Đang kiểm tra...'
                      : _selectedMethod == PaymentMethod.vietQR
                          ? 'Tôi đã chuyển khoản thành công'
                          : _selectedMethod == PaymentMethod.vnpay
                              ? 'Xác nhận thanh toán qua VNPay'
                              : 'Xác nhận thanh toán MoMo',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodChip(PaymentMethod method, String label, IconData icon) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => _changeMethod(method),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.muted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVietQrContent(PaymentTransaction txn) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBD5E1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  txn.qrCodeUrl ?? '',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      width: 220,
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 220,
                    height: 220,
                    color: const Color(0xFFF1F5F9),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.qr_code_2_rounded, size: 64, color: AppColors.muted),
                        SizedBox(height: 8),
                        Text('Mã QR Napas 247', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.flash_on_rounded, size: 14, color: AppColors.green),
                  SizedBox(width: 4),
                  Text(
                    'Quét mã bằng bất kỳ App Ngân hàng nào (Miễn phí 24/7)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chi tiết tài khoản thụ hưởng
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildInfoRow('Ngân hàng', PaymentService.vietQrBankName, null),
              const Divider(height: 18),
              _buildInfoRow(
                'Số tài khoản',
                PaymentService.vietQrAccountNo,
                () => _copyToClipboard(PaymentService.vietQrAccountNo, 'Số tài khoản'),
              ),
              const Divider(height: 18),
              _buildInfoRow('Chủ tài khoản', PaymentService.vietQrAccountName, null),
              const Divider(height: 18),
              _buildInfoRow(
                'Số tiền',
                _formatMoney(txn.amount),
                () => _copyToClipboard(txn.amount.toInt().toString(), 'Số tiền'),
              ),
              const Divider(height: 18),
              _buildInfoRow(
                'Nội dung CK',
                txn.transferContent ?? '',
                () => _copyToClipboard(txn.transferContent ?? '', 'Nội dung chuyển khoản'),
                highlight: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVNPayContent(PaymentTransaction txn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF005BAA),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text('VNPAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cổng thanh toán điện tử VNPAY-QR',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E3A8A)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hỗ trợ thẻ ATM nội địa, Thẻ quốc tế Visa/Mastercard và VNPay-QR.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF3B82F6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Chọn kênh thanh toán VNPay:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        RadioListTile<String>(
          value: 'VNPAYQR',
          groupValue: _vnpayBankOption,
          onChanged: (val) => setState(() => _vnpayBankOption = val!),
          title: const Text('Ứng dụng thanh toán hỗ trợ VNPAY-QR', style: TextStyle(fontSize: 13)),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          value: 'VNBANK',
          groupValue: _vnpayBankOption,
          onChanged: (val) => setState(() => _vnpayBankOption = val!),
          title: const Text('Thẻ ATM / Tài khoản ngân hàng nội địa', style: TextStyle(fontSize: 13)),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          value: 'INTCARD',
          groupValue: _vnpayBankOption,
          onChanged: (val) => setState(() => _vnpayBankOption = val!),
          title: const Text('Thẻ quốc tế (Visa, MasterCard, JCB)', style: TextStyle(fontSize: 13)),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mã giao dịch (TxnRef):', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  Text(txn.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Chuẩn chữ ký:', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  Text('HMAC-SHA512 (v2.1.0)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoMoContent(PaymentTransaction txn) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF2F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFBCFE8)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFA50064),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text('MoMo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thanh toán qua Ví MoMo',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF831843)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Mở ứng dụng MoMo trên điện thoại để quét mã QR thanh toán tức thì.',
                      style: TextStyle(fontSize: 11, color: Color(0xFFBE185D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              txn.qrCodeUrl ?? '',
              width: 180,
              height: 180,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 180,
                height: 180,
                color: const Color(0xFFF1F5F9),
                alignment: Alignment.center,
                child: const Icon(Icons.qr_code_scanner_rounded, size: 64, color: Color(0xFFA50064)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, VoidCallback? onCopy, {bool highlight = false}) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.primary : AppColors.text,
            ),
          ),
        ),
        if (onCopy != null)
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('Sao chép', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSuccessView() {
    final txn = _currentTransaction!;
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thanh toán thành công!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          Text(
            'Hệ thống đã ghi nhận khoản thanh toán cho hóa đơn ${txn.billId}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 20),

          // Biên lai chi tiết
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildReceiptRow('Mã hóa đơn', txn.billId),
                const Divider(height: 14),
                _buildReceiptRow('Số tiền thanh toán', _formatMoney(txn.amount), isBold: true),
                const Divider(height: 14),
                _buildReceiptRow('Phương thức', txn.method.displayName),
                const Divider(height: 14),
                _buildReceiptRow('Mã giao dịch', txn.id),
                const Divider(height: 14),
                _buildReceiptRow('Mã đối chiếu ngân hàng', txn.transactionReference ?? 'REF-ONLINE-OK'),
                const Divider(height: 14),
                _buildReceiptRow('Thời gian', dateStr),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text: 'Biên lai thanh toán DormHub: ${txn.billId} - Số tiền: ${_formatMoney(txn.amount)} - Mã GD: ${txn.id} - Thời gian: $dateStr',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép thông tin biên lai!')),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_rounded, size: 16),
                  label: const Text('Sao chép biên lai'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Hoàn tất', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? AppColors.green : AppColors.text,
          ),
        ),
      ],
    );
  }
}
