class RoleMenus {
  static const List<String> studentMenu = [
    'Trang chủ',
    'Đăng ký phòng',
    'Hợp đồng',
    'Hóa đơn & thanh toán',
    'Báo sự cố / Sửa chữa',
    'Thông báo',
    'Hồ sơ cá nhân',
  ];

  static const List<String> managerMenu = [
    'Dashboard',
    'Duyệt đơn đăng ký',
    'Sinh viên / Phòng',
    'Quản lý hợp đồng',
    'Hóa đơn & công nợ',
    'Điện nước',
    'Vi phạm',
    'Thông báo',
    'Báo cáo',
  ];

  static const List<String> technicianMenu = [
    'Dashboard',
    'Yêu cầu sửa chữa',
    'Lịch bảo trì',
    'Quản lý vật tư',
    'Báo cáo',
  ];

  static const List<String> adminMenu = [
    'Dashboard',
    'Quản lý tài khoản',
    'Phân quyền',
    'Cấu hình hệ thống',
    'Nhật ký hệ thống',
  ];

  /// Trả về null nếu role không hợp lệ; caller xử lý redirect/khóa.
  static List<String>? getMenuForRoleOrNull(String role) {
    switch (role) {
      case 'Sinh viên':
        return studentMenu;
      case 'Kỹ thuật viên':
        return technicianMenu;
      case 'Quản trị viên':
        return adminMenu;
      case 'Quản lý KTX':
        return managerMenu;
      default:
        return null;
    }
  }

  /// Giữ backward-compat; role không hợp lệ trả về list rỗng thay vì managerMenu.
  static List<String> getMenuForRole(String role) {
    return getMenuForRoleOrNull(role) ?? const [];
  }
}
