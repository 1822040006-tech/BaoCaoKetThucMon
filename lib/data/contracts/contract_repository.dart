import '../demo_store.dart';
import '../../models/dorm_contract.dart';

/// Hợp đồng giao tiếp dữ liệu. Có thể thay implementation demo bằng REST API
/// hoặc repository dùng database mà không cần sửa giao diện StudentContractPage.
abstract interface class ContractRepository {
  Future<DormContract?> getCurrentContract(String studentEmail);
  Future<List<DormContract>> getContractHistory(String studentEmail);
  Future<DormContract> renewContract(String studentEmail, String contractId);
  Future<DormContract> terminateContract(String studentEmail, String contractId);
}

/// Nguồn dữ liệu demo dùng chung với DemoStore.contracts để Quản lý và Sinh viên
/// luôn thấy cùng một bản ghi dữ liệu duy nhất.
class DemoContractRepository implements ContractRepository {
  DemoContractRepository._();

  static final DemoContractRepository instance = DemoContractRepository._();

  DormContract _fromMap(Map<String, String> m, {bool isCurrent = false}) {
    final building = m['building'] ?? '';
    final room = m['room'] ?? '';
    final displayRoom = building.isNotEmpty && room.isNotEmpty
        ? '$building — $room'
        : (room.isNotEmpty ? room : building);

    return DormContract(
      id: m['id'] ?? '',
      room: displayRoom,
      roomType: m['roomType'] ?? 'Phòng tiêu chuẩn',
      startDate: m['startDate'] ?? '',
      endDate: m['endDate'] ?? '',
      monthlyFee: m['monthlyFee'] ?? '600.000 đ',
      deposit: m['deposit'] ?? '1.200.000 đ',
      status: m['status'] ?? 'Đang hiệu lực',
      isCurrent: isCurrent,
    );
  }

  @override
  Future<DormContract?> getCurrentContract(String studentEmail) async {
    final email = studentEmail.trim().toLowerCase();
    final student = DemoStore.students.firstWhere(
      (s) => (s['email'] ?? '').toLowerCase() == email,
      orElse: () => {},
    );
    final studentId = (student['id'] ?? '').toLowerCase();
    final studentName = (student['name'] ?? '').toLowerCase();

    final matchIndex = DemoStore.contracts.indexWhere((c) {
      final cEmail = (c['email'] ?? '').toLowerCase();
      final cCode = (c['studentCode'] ?? '').toLowerCase();
      final cName = (c['student'] ?? '').toLowerCase();
      final isStudent = (cEmail.isNotEmpty && cEmail == email) ||
          (studentId.isNotEmpty && cCode == studentId) ||
          (studentName.isNotEmpty && cName == studentName);
      final isCurrent =
          c['status'] == 'Đang hiệu lực' || c['status'] == 'Sắp hết hạn';
      return isStudent && isCurrent;
    });

    if (matchIndex < 0) return null;
    return _fromMap(DemoStore.contracts[matchIndex], isCurrent: true);
  }

  @override
  Future<List<DormContract>> getContractHistory(String studentEmail) async {
    final email = studentEmail.trim().toLowerCase();
    final student = DemoStore.students.firstWhere(
      (s) => (s['email'] ?? '').toLowerCase() == email,
      orElse: () => {},
    );
    final studentId = (student['id'] ?? '').toLowerCase();
    final studentName = (student['name'] ?? '').toLowerCase();

    final matches = DemoStore.contracts.where((c) {
      final cEmail = (c['email'] ?? '').toLowerCase();
      final cCode = (c['studentCode'] ?? '').toLowerCase();
      final cName = (c['student'] ?? '').toLowerCase();
      final isStudent = (cEmail.isNotEmpty && cEmail == email) ||
          (studentId.isNotEmpty && cCode == studentId) ||
          (studentName.isNotEmpty && cName == studentName);
      final isHistorical =
          c['status'] == 'Đã thanh lý' || c['status'] == 'Hết hạn';
      return isStudent && isHistorical;
    }).map((c) => _fromMap(c, isCurrent: false)).toList();

    return matches;
  }

  @override
  Future<DormContract> renewContract(String studentEmail, String contractId) async {
    final index = DemoStore.contracts.indexWhere((c) => c['id'] == contractId);
    if (index < 0) {
      throw StateError('Không tìm thấy hợp đồng để gia hạn.');
    }
    final endDate = DateTime.now().add(const Duration(days: 365));
    final newEndDate =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    DemoStore.contracts[index]['endDate'] = newEndDate;
    DemoStore.contracts[index]['status'] = 'Đang hiệu lực';
    DemoStore.addAudit('Yêu cầu gia hạn hợp đồng $contractId', studentEmail);
    return _fromMap(DemoStore.contracts[index], isCurrent: true);
  }

  @override
  Future<DormContract> terminateContract(String studentEmail, String contractId) async {
    final index = DemoStore.contracts.indexWhere((c) => c['id'] == contractId);
    if (index < 0) {
      throw StateError('Không tìm thấy hợp đồng để chấm dứt.');
    }
    DemoStore.contracts[index]['status'] = 'Đã thanh lý';
    DemoStore.addAudit('Yêu cầu chấm dứt hợp đồng $contractId', studentEmail);
    return _fromMap(DemoStore.contracts[index], isCurrent: false);
  }
}
