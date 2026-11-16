/// Dữ liệu demo dùng chung trong bộ nhớ của ứng dụng.
/// Dữ liệu sẽ được đặt lại khi ứng dụng khởi động lại; cần backend/CSDL cho môi trường thật.
class DemoStore {
  DemoStore._();

  static final List<Map<String, String>> accounts = [
    {'name': 'Nguyễn Minh Anh', 'email': 'sv@university.edu.vn', 'role': 'Sinh viên', 'status': 'Đang hoạt động'},
    {'name': 'Trần Thu Hà', 'email': 'qlktx@university.edu.vn', 'role': 'Quản lý KTX', 'status': 'Đang hoạt động'},
    {'name': 'Lê Quang Huy', 'email': 'kt@university.edu.vn', 'role': 'Kỹ thuật viên', 'status': 'Đang hoạt động'},
    {'name': 'Nguyễn Hoàng Nam', 'email': 'admin@university.edu.vn', 'role': 'Quản trị viên', 'status': 'Đang hoạt động'},
  ];

  static final List<Map<String, String>> students = [
    {'id': 'SV2026001', 'name': 'Nguyễn Minh Anh', 'email': 'sv@university.edu.vn', 'room': 'A-203', 'status': 'Đang ở'},
    {'id': 'SV2026002', 'name': 'Trần Quốc Bảo', 'email': 'sv2026002@university.edu.vn', 'room': 'B-105', 'status': 'Đang ở'},
    {'id': 'SV2026003', 'name': 'Phạm Thu Hà', 'email': 'sv2026003@university.edu.vn', 'room': 'C-402', 'status': 'Chờ nhận phòng'},
    {'id': 'SV2026004', 'name': 'Lê Tuấn Kiệt', 'email': 'sv2026004@university.edu.vn', 'room': 'D-201', 'status': 'Đang ở'},
    {'id': 'SV2026005', 'name': 'Vũ Khánh Linh', 'email': 'sv2026005@university.edu.vn', 'room': 'A-105', 'status': 'Đang ở'},
  ];

  static final List<Map<String, String>> applications = [
    {'id': 'DK-2026-031', 'name': 'Nguyễn Minh Anh', 'code': 'SV2026001', 'email': 'sv@university.edu.vn', 'room': 'A-203', 'type': 'Phòng 4 người', 'date': '20/10/2026', 'status': 'Đã duyệt'},
    {'id': 'DK-2026-030', 'name': 'Trần Quốc Bảo', 'code': 'SV2026002', 'email': 'sv2026002@university.edu.vn', 'room': 'B-105', 'type': 'Phòng 6 người', 'date': '19/10/2026', 'status': 'Chờ duyệt'},
    {'id': 'DK-2026-029', 'name': 'Phạm Thu Hà', 'code': 'SV2026003', 'email': 'sv2026003@university.edu.vn', 'room': 'C-402', 'type': 'Phòng 4 người', 'date': '18/10/2026', 'status': 'Đã duyệt'},
    {'id': 'DK-2026-028', 'name': 'Lê Tuấn Kiệt', 'code': 'SV2026004', 'email': 'sv2026004@university.edu.vn', 'room': 'D-201', 'type': 'Phòng 8 người', 'date': '17/10/2026', 'status': 'Từ chối'},
  ];

  static final List<Map<String, String>> repairs = [
    {'id': 'SC-1024', 'title': 'Vòi nước bị rò rỉ', 'room': 'A-203', 'student': 'Nguyễn Minh Anh', 'email': 'sv@university.edu.vn', 'date': '20/10/2026', 'status': 'Mới'},
    {'id': 'SC-1023', 'title': 'Đèn phòng không sáng', 'room': 'B-105', 'student': 'Trần Quốc Bảo', 'email': 'sv2026002@university.edu.vn', 'date': '19/10/2026', 'status': 'Đã gán'},
    {'id': 'SC-1022', 'title': 'Điều hòa phát tiếng ồn', 'room': 'C-402', 'student': 'Phạm Thu Hà', 'email': 'sv2026003@university.edu.vn', 'date': '19/10/2026', 'status': 'Đang xử lý'},
    {'id': 'SC-1021', 'title': 'Khóa cửa khó mở', 'room': 'A-312', 'student': 'Lê Tuấn Kiệt', 'email': 'sv2026004@university.edu.vn', 'date': '18/10/2026', 'status': 'Hoàn thành'},
  ];

  static final List<Map<String, String>> bills = [
    {
      'id': 'HD-1026-015',
      'title': 'Hóa đơn lưu trú tháng 10',
      'studentName': 'Nguyễn Minh Anh',
      'studentCode': 'SV2026001',
      'period': '10/2026',
      'amount': '745.000 ₫',
      'rawAmount': '745000',
      'email': 'sv@university.edu.vn',
      'status': 'Chưa thanh toán',
      'room': 'A-203',
      'rentAmount': '600000',
      'electricKwh': '120',
      'electricRate': '1000',
      'waterM3': '5',
      'waterRate': '5000',
      'sanitationAmount': '0',
      'dueDate': '15/11/2026'
    },
    {
      'id': 'HD-1026-014',
      'title': 'Điện nước tháng 9',
      'studentName': 'Nguyễn Minh Anh',
      'studentCode': 'SV2026001',
      'period': '09/2026',
      'amount': '185.000 ₫',
      'rawAmount': '185000',
      'email': 'sv@university.edu.vn',
      'status': 'Đã thanh toán',
      'room': 'A-203',
      'dueDate': '15/10/2026'
    },
    {
      'id': 'HD-1026-013',
      'title': 'Phí lưu trú tháng 9',
      'studentName': 'Nguyễn Minh Anh',
      'studentCode': 'SV2026001',
      'period': '09/2026',
      'amount': '850.000 ₫',
      'rawAmount': '850000',
      'email': 'sv@university.edu.vn',
      'status': 'Đã thanh toán',
      'room': 'A-203',
      'dueDate': '15/10/2026'
    },
    {
      'id': 'HD-2024-1102',
      'title': 'Hóa đơn lưu trú tháng 11',
      'studentName': 'Trần Quốc Bảo',
      'studentCode': 'SV2026002',
      'room': 'B-105',
      'period': '11/2026',
      'amount': '718.000 ₫',
      'rawAmount': '718000',
      'email': 'sv2026002@university.edu.vn',
      'status': 'Đã thanh toán',
      'dueDate': '15/12/2026'
    },
    {
      'id': 'HD-2024-1003',
      'title': 'Hóa đơn lưu trú tháng 10',
      'studentName': 'Lê Tuấn Kiệt',
      'studentCode': 'SV2026004',
      'room': 'D-201',
      'period': '10/2026',
      'amount': '582.000 ₫',
      'rawAmount': '582000',
      'email': 'sv2026004@university.edu.vn',
      'status': 'Quá hạn',
      'dueDate': '15/11/2026'
    },
    {
      'id': 'HD-2024-1104',
      'title': 'Hóa đơn lưu trú tháng 11',
      'studentName': 'Phạm Thu Hà',
      'studentCode': 'SV2026003',
      'room': 'C-402',
      'period': '11/2026',
      'amount': '505.000 ₫',
      'rawAmount': '505000',
      'email': 'sv2026003@university.edu.vn',
      'status': 'Chưa thanh toán',
      'dueDate': '15/12/2026'
    },
    {
      'id': 'HD-2024-0905',
      'title': 'Hóa đơn lưu trú tháng 9',
      'studentName': 'Vũ Khánh Linh',
      'studentCode': 'SV2026005',
      'room': 'A-105',
      'period': '09/2026',
      'amount': '726.000 ₫',
      'rawAmount': '726000',
      'email': 'sv2026005@university.edu.vn',
      'status': 'Quá hạn',
      'dueDate': '15/10/2026'
    },
  ];

  static final List<Map<String, String>> notifications = [
    {
      'id': 'TB-001',
      'title': 'Kiểm tra PCCC tòa A',
      'status': 'Đã gửi',
      'sendType': 'In-app',
      'content': 'Ban quản lý sẽ kiểm tra hệ thống PCCC tòa A vào lúc 08:00 ngày 15/11.',
      'target': 'Sinh viên tòa A',
      'author': 'Quản lý KTX',
      'createdAt': '10/11/2026',
      'isRead': 'false',
    },
    {
      'id': 'TB-002',
      'title': 'Nhắc thanh toán hóa đơn lưu trú',
      'status': 'Bản nháp',
      'sendType': 'In-app',
      'content': 'Sinh viên vui lòng hoàn tất thanh toán hóa đơn trước hạn quy định.',
      'target': 'Sinh viên chưa thanh toán',
      'author': 'Quản lý KTX',
      'createdAt': '11/11/2026',
      'isRead': 'false',
    },
    {
      'id': 'TB-003',
      'title': 'Bảo trì hệ thống nước tòa A & B',
      'status': 'Đã gửi',
      'sendType': 'In-app',
      'content': 'Đội kỹ thuật sẽ tạm ngưng cấp nước sinh hoạt từ 08:00 - 11:30 ngày 25/10/2026 để súc rửa bể ngầm.',
      'target': 'Tòa A & Tòa B',
      'author': 'Kỹ thuật viên',
      'createdAt': '24/10/2026',
      'isRead': 'false',
    },
    {
      'id': 'TB-004',
      'title': 'Hóa đơn tháng 10 đã phát sinh',
      'status': 'Đã gửi',
      'sendType': 'In-app',
      'content': 'Hóa đơn lưu trú tháng 10 đã được phát hành. Hạn thanh toán đến 15/11/2026.',
      'target': 'Toàn thể sinh viên',
      'author': 'Quản lý KTX',
      'createdAt': '20/10/2026',
      'isRead': 'true',
    },
  ];

  static final List<Map<String, String>> maintenanceSchedules = [
    {
      'id': 'BT-2026-01',
      'title': 'Bảo trì & súc rửa bể nước ngầm',
      'location': 'Tòa A & Tòa B',
      'time': '08:00 - 11:30 · 25/10/2026',
      'type': 'Hệ thống nước',
      'status': 'Sắp diễn ra',
      'impact': 'Tạm ngưng cấp nước sinh hoạt',
    },
    {
      'id': 'BT-2026-02',
      'title': 'Kiểm tra & bảo dưỡng hệ thống PCCC',
      'location': 'Tòa C (Toàn bộ các tầng)',
      'time': '14:00 - 16:30 · 26/10/2026',
      'type': 'An toàn PCCC',
      'status': 'Sắp diễn ra',
      'impact': 'Thử chuông báo cháy ngắt quãng',
    },
    {
      'id': 'BT-2026-03',
      'title': 'Sửa chữa máy phát điện dự phòng',
      'location': 'Trạm kỹ thuật trung tâm',
      'time': '09:00 - 12:00 · 22/10/2026',
      'type': 'Hệ thống điện',
      'status': 'Đang thực hiện',
      'impact': 'Không ảnh hưởng điện lưới chính',
    },
    {
      'id': 'BT-2026-04',
      'title': 'Vệ sinh bộ lọc điều hòa hành lang',
      'location': 'Tòa D · Tầng 1 - 4',
      'time': '08:30 - 16:00 · 20/10/2026',
      'type': 'Điều hòa',
      'status': 'Hoàn thành',
      'impact': 'Đã hoàn tất bảo trì',
    },
  ];

  static final List<Map<String, String>> reports = [
    {
      'id': 'BC-KT-101',
      'title': 'Báo cáo tổng hợp sự cố điện nước Tháng 10',
      'type': 'Báo cáo tháng',
      'content': 'Đã khắc phục 42/45 sự cố phát sinh trong tháng 10. Tỷ lệ hoàn thành 93.3%.',
      'date': '20/10/2026',
      'author': 'Lê Quang Huy',
      'status': 'Đã duyệt',
    },
    {
      'id': 'BC-KT-102',
      'title': 'Đề xuất thay mới 20 bóng đèn LED Tòa B',
      'type': 'Đề xuất vật tư',
      'content': 'Đề xuất mua bổ sung 20 bóng đèn LED để thay thế các vị trí hành lang tầng 2 và tầng 3.',
      'date': '18/10/2026',
      'author': 'Lê Quang Huy',
      'status': 'Chờ xem xét',
    },
    {
      'id': 'BC-KT-103',
      'title': 'Báo cáo bảo trì máy bơm nước Tòa C',
      'type': 'Bảo trì định kỳ',
      'content': 'Đã hoàn thành kiểm tra và thay thế gioăng phớt máy bơm tăng áp Tòa C.',
      'date': '15/10/2026',
      'author': 'Lê Quang Huy',
      'status': 'Đã duyệt',
    },
  ];

  static final List<Map<String, String>> violations = [
    {'id': 'VP-026', 'student': 'Trần Quốc Bảo', 'description': 'Để xe sai khu vực', 'date': '20/10/2026', 'status': 'Chờ xác minh'},
    {'id': 'VP-025', 'student': 'Lê Tuấn Kiệt', 'description': 'Gây ồn sau giờ quy định', 'date': '18/10/2026', 'status': 'Đã nhắc nhở'},
  ];

  static final List<Map<String, String>> inventory = [
    {'id': 'VT-001', 'name': 'Bóng đèn LED', 'quantity': '08', 'status': 'Sắp hết'},
    {'id': 'VT-002', 'name': 'Vòi nước', 'quantity': '15', 'status': 'Còn hàng'},
    {'id': 'VT-003', 'name': 'Khóa cửa', 'quantity': '03', 'status': 'Sắp hết'},
  ];


    static final List<Map<String, String>> contracts = [
    {
      'id': 'HD-KTX-2025-0312',
      'student': 'Nguyễn Minh Anh',
      'studentCode': 'SV2026001',
      'email': 'sv@university.edu.vn',
      'room': 'A-203',
      'building': 'Tòa A',
      'startDate': '01/09/2025',
      'endDate': '31/05/2026',
      'monthlyFee': '600.000 đ',
      'deposit': '1.200.000 đ',
      'status': 'Đang hiệu lực',
    },
    {
      'id': 'HD-KTX-2025-0298',
      'student': 'Trần Quốc Bảo',
      'studentCode': 'SV2026002',
      'email': 'sv2026002@university.edu.vn',
      'room': 'B-105',
      'building': 'Tòa B',
      'startDate': '01/09/2025',
      'endDate': '28/02/2026',
      'monthlyFee': '600.000 đ',
      'deposit': '1.200.000 đ',
      'status': 'Sắp hết hạn',
    },
    {
      'id': 'HD-KTX-2024-0155',
      'student': 'Lê Tuấn Kiệt',
      'studentCode': 'SV2026004',
      'email': 'sv2026004@university.edu.vn',
      'room': 'D-201',
      'building': 'Tòa D',
      'startDate': '01/09/2024',
      'endDate': '31/05/2025',
      'monthlyFee': '550.000 đ',
      'deposit': '1.100.000 đ',
      'status': 'Đã thanh lý',
    },
    {
      'id': 'HD-KTX-2024-0102',
      'student': 'Nguyễn Minh Anh',
      'studentCode': 'SV2026001',
      'email': 'sv@university.edu.vn',
      'room': 'A-102',
      'building': 'Tòa A',
      'startDate': '01/09/2024',
      'endDate': '31/05/2025',
      'monthlyFee': '550.000 đ',
      'deposit': '1.100.000 đ',
      'status': 'Hết hạn',
    },
    {
      'id': 'HD-KTX-2025-0401',
      'student': 'Vũ Khánh Linh',
      'studentCode': 'SV2026005',
      'email': 'sv2026005@university.edu.vn',
      'room': 'A-105',
      'building': 'Tòa A',
      'startDate': '01/09/2025',
      'endDate': '31/05/2026',
      'monthlyFee': '600.000 đ',
      'deposit': '1.200.000 đ',
      'status': 'Đang hiệu lực',
    },
  ];

  static final List<Map<String, String>> auditLogs = [
    {'action': 'Đăng nhập thành công', 'actor': 'Quản lý KTX', 'time': '20/10/2026 08:15'},
    {'action': 'Cập nhật trạng thái yêu cầu', 'actor': 'Kỹ thuật viên', 'time': '19/10/2026 16:40'},
    {'action': 'Rà soát quyền người dùng', 'actor': 'Quản trị viên', 'time': '19/10/2026 14:05'},
  ];

  static void addAudit(String action, String actor) {
    final now = DateTime.now();
    final date = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    auditLogs.insert(0, {'action': action, 'actor': actor, 'time': '$date $time'});
    if (auditLogs.length > 100) auditLogs.removeRange(100, auditLogs.length);
  }

  static String dateToday() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  static int _idCounter = 100;
  static String nextId(String prefix) {
    _idCounter++;
    final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase();
    return '$prefix-$micros-${_idCounter.toString().padLeft(3, '0')}';
  }
}
