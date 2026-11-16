import '../config/role_menus.dart';
import 'technician/technician_maintenance_page.dart';
import 'technician/technician_reports_page.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

import '../data/demo_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/common_widgets.dart';
import 'dashboards/admin_dashboard.dart';
import 'dashboards/manager_dashboard.dart';
import 'dashboards/student_dashboard.dart';
import 'dashboards/technician_dashboard.dart';
import 'manager/manager_billing_debt_page.dart';
import 'manager/manager_contract_page.dart';
import 'manager/manager_notifications_page.dart';
import 'manager/manager_reports_page.dart';
import 'manager/student_room_manager_page.dart';
import 'student/billing_page.dart';
import 'student/contract_page.dart';
import 'student/issue_pages.dart';
import 'student/room_booking_page.dart';

class HomePage extends StatefulWidget {
  final String role;
  final String email;
  final String displayName;
  final String? studentCode;
  final WidgetBuilder loginPageBuilder;

  const HomePage(
      {super.key,
      required this.role,
      required this.email,
      required this.displayName,
      this.studentCode,
      required this.loginPageBuilder});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String page = 'Dashboard';
  bool emailNotificationsEnabled = false;
  List<Map<String, String>> get students => DemoStore.students;
  List<Map<String, String>> get applications => DemoStore.applications;
  List<Map<String, String>> get repairs => DemoStore.repairs;
  List<Map<String, String>> get bills => DemoStore.bills;

  @override
  void initState() {
    super.initState();
    if (widget.role == 'Sinh viên') page = 'Trang chủ';
  }

  Map<String, String> get currentAccount => DemoStore.accounts.firstWhere(
        (account) =>
            account['email']?.toLowerCase() == widget.email.toLowerCase(),
        orElse: () =>
            {'name': 'Người dùng', 'email': widget.email, 'role': widget.role},
      );

  String get currentUserName => widget.displayName;

  String get currentStudentCode => widget.studentCode ?? '';

  List<String> get menu {
    return RoleMenus.getMenuForRole(widget.role);
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final wide = screenWidth >= 900;
    final compactToolbar = screenWidth < 390;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 68,
        automaticallyImplyLeading: !wide,
        titleSpacing: wide
            ? 26
            : compactToolbar
                ? 6
                : 12,
        title: Row(
          children: [
            if (!wide) ...[
              const DormHubLogo(size: 35),
              const SizedBox(width: 10),
              const Text('DormHub',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ] else ...[
              const Text('Không gian làm việc',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500)),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.muted)),
              Flexible(
                  child: Text(page,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.text,
                          fontWeight: FontWeight.w700))),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: IconButton(
              tooltip: 'Thông báo',
              onPressed: () =>
                  _notice('Bạn đang xem bản demo, chưa có thông báo mới.'),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF3F6FC),
                foregroundColor: AppColors.muted,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize:
                    compactToolbar ? const Size(36, 36) : const Size(40, 40),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.notifications_none_rounded, size: 20),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 3, right: compactToolbar ? 4 : 12),
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => setState(() => page = widget.role == 'Sinh viên'
                    ? 'Hồ sơ cá nhân'
                    : (menu.contains('Quản lý tài khoản')
                        ? 'Quản lý tài khoản'
                        : page)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    children: [
                      const CircleAvatar(
                          radius: 17,
                          backgroundColor: AppColors.primarySoft,
                          child: Icon(Icons.person_outline_rounded,
                              size: 19, color: AppColors.primary)),
                      if (MediaQuery.sizeOf(context).width > 600) ...[
                        const SizedBox(width: 9),
                        ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 145),
                            child: Text(widget.role,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text))),
                        const SizedBox(width: 3),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18, color: AppColors.muted),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 2, right: compactToolbar ? 7 : 15, top: 13, bottom: 13),
            child: IconButton(
              tooltip: 'Đăng xuất',
              onPressed: () async {
                try {
                  await AuthService.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: widget.loginPageBuilder));
                } catch (_) {
                  if (mounted) _notice('Đăng xuất thất bại. Vui lòng thử lại.');
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0F1),
                foregroundColor: AppColors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize:
                    compactToolbar ? const Size(36, 36) : const Size(40, 40),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.logout_rounded, size: 19),
            ),
          ),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
              width: 286,
              backgroundColor: AppColors.navy,
              child: AppSidebar(
                  role: widget.role,
                  currentPage: page,
                  menu: menu,
                  onSelect: _selectPage),
            ),
      body: Row(
        children: [
          if (wide)
            SizedBox(
                width: 264,
                child: AppSidebar(
                    role: widget.role,
                    currentPage: page,
                    menu: menu,
                    onSelect: _selectPage)),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  void _selectPage(String value) {
    final destination =
        value == 'Đơn đăng ký của tôi' && widget.role == 'Sinh viên'
            ? 'Đăng ký phòng'
            : value;
    setState(() => page = destination);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  Widget _content() {
    final width = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(width < 600 ? 15 : 30, width < 600 ? 20 : 28,
          width < 600 ? 15 : 30, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!(widget.role == 'Sinh viên' &&
                      (page == 'Hóa đơn & thanh toán' || page == 'Hợp đồng')) &&
                  !(widget.role == 'Kỹ thuật viên' &&
                      (page == 'Lịch bảo trì' || page == 'Báo cáo')))
                PageIntro(title: page, subtitle: _subtitle()),
              if (page == 'Dashboard' || page == 'Trang chủ')
                _dashboard()
              else if (page == 'Quản lý hợp đồng' &&
                  widget.role == 'Quản lý KTX')
                const ManagerContractPageWidget()
              else if (page == 'Hóa đơn & công nợ' &&
                  widget.role == 'Quản lý KTX')
                const ManagerBillingDebtPageWidget()
              else if (page == 'Sinh viên / Phòng')
                const StudentRoomManagerPageWidget()
              else if (page == 'Duyệt đơn đăng ký')
                _applicationsTable()
              else if (page == 'Đơn đăng ký của tôi')
                widget.role == 'Sinh viên'
                    ? StudentRoomBookingPage(
                        email: widget.email, onNavigate: _selectPage)
                    : _myApplicationsTable()
              else if (page == 'Đăng ký phòng')
                widget.role == 'Sinh viên'
                    ? StudentRoomBookingPage(
                        email: widget.email, onNavigate: _selectPage)
                    : _applicationsTable()
              else if (page == 'Yêu cầu sửa chữa')
                _repairsTable()
              else if (page == 'Thông báo' && widget.role == 'Quản lý KTX')
                const ManagerNotificationsPageWidget()
              else if (page == 'Lịch bảo trì' && widget.role == 'Kỹ thuật viên')
                TechnicianMaintenancePageWidget(authorName: currentUserName)
              else if (page == 'Báo cáo')
                widget.role == 'Kỹ thuật viên'
                    ? TechnicianReportsPageWidget(authorName: currentUserName)
                    : const ReportsPageWidget()
              else if (page == 'Báo sự cố / Sửa chữa')
                StudentIssuePage(
                    email: widget.email,
                    userName: currentUserName,
                    onNavigate: _selectPage)
              else if (page == 'Hợp đồng' && widget.role == 'Sinh viên')
                StudentContractPage(email: widget.email)
              else if (page == 'Hóa đơn & thanh toán')
                widget.role == 'Sinh viên'
                    ? StudentBillingPage(
                        email: widget.email, userName: currentUserName)
                    : _billsTable()
              else if (page == 'Điện nước')
                _billsTable()
              else if (page == 'Hồ sơ cá nhân')
                _profile()
              else
                _generic(),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 10),
              const Text('© 2026 DormHub  ·  Bản demo giao diện Flutter',
                  style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    if (page == 'Dashboard' || page == 'Trang chủ') {
      return 'Theo dõi nhanh hoạt động và những việc cần ưu tiên.';
    }
    if (page == 'Quản lý hợp đồng') {
      return 'Theo dõi danh sách và tình trạng hợp đồng lưu trú.';
    }
    if (page.contains('Sinh viên')) {
      return 'Danh sách sinh viên, mã số và phòng đang ở.';
    }
    if (page.contains('đơn') || page.contains('Đăng ký')) {
      return 'Theo dõi và xử lý yêu cầu đăng ký chỗ ở.';
    }
    if (page.contains('sửa chữa') || page.contains('Sửa chữa')) {
      return 'Tiếp nhận và theo dõi các sự cố trong ký túc xá.';
    }
    if (page.contains('Hóa đơn') || page.contains('Điện nước')) {
      return 'Theo dõi khoản thu và trạng thái thanh toán.';
    }
    if (page == 'Đơn đăng ký của tôi') {
      return 'Theo dõi trạng thái các yêu cầu lưu trú do bạn gửi.';
    }
    if (page == 'Theo dõi sự cố') {
      return 'Xem tiến độ các yêu cầu sửa chữa bạn đã báo.';
    }
    if (page == 'Lịch bảo trì') {
      return 'Lịch công việc kỹ thuật theo tòa và khu vực.';
    }
    if (page == 'Quản lý vật tư') {
      return 'Theo dõi số lượng vật tư và mức tồn kho.';
    }
    if (page == 'Quản lý tài khoản') {
      return 'Tạo tài khoản nhân sự và quản lý trạng thái truy cập.';
    }
    if (page == 'Phân quyền') {
      return 'Quyền thao tác được xác định từ tài khoản đã cấp.';
    }
    if (page == 'Hồ sơ cá nhân') {
      return 'Thông tin tài khoản đang sử dụng hệ thống.';
    }
    return 'Quản lý thông tin và tác vụ trong hệ thống ký túc xá.';
  }

  Widget _dashboard() {
    if (widget.role == 'Sinh viên') {
      return StudentDashboard(email: widget.email, onNavigate: _selectPage);
    }
    if (widget.role == 'Kỹ thuật viên') {
      return TechnicianDashboard(onNavigate: _selectPage);
    }
    if (widget.role == 'Quản trị viên') {
      return AdminDashboard(onNavigate: _selectPage);
    }
    if (widget.role == 'Quản lý KTX') {
      return ManagerDashboard(
        students: students,
        applications: applications,
        repairs: repairs,
        onNavigate: _selectPage,
      );
    }
    // Role không hợp lệ: hiện thông báo thay vì cấp giao diện quản lý
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block_rounded, size: 56, color: Color(0xFFCBD5E1)),
            SizedBox(height: 18),
            Text('Vai trò không hợp lệ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text(
                'Tài khoản này chưa được cấp quyền truy cập hệ thống.\nVui lòng liên hệ Quản trị viên.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _myApplicationsTable() => _applicationsTable();

  Widget _applicationsTable() => SectionCard(
        title: 'Đơn đăng ký phòng',
        subtitle: 'Xem và cập nhật trạng thái xét duyệt',
        child: _simpleTable(
            [
              'Mã đơn',
              'Sinh viên',
              'Mã SV',
              'Phòng',
              'Loại phòng',
              'Ngày',
              'Trạng thái'
            ],
            applications
                .map((a) => [
                      a['id']!,
                      a['name']!,
                      a['code']!,
                      a['room']!,
                      a['type']!,
                      a['date']!,
                      a['status']!
                    ])
                .toList(),
            actions: true),
      );

  Widget _repairsTable() => SectionCard(
        title: 'Yêu cầu sửa chữa',
        subtitle:
            'Quản lý, phân công kỹ thuật viên và theo dõi tiến độ khắc phục sự cố',
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 45,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 72,
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFF7F9FC)),
                columns: const [
                  DataColumn(
                      label: Text('MÃ SC',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.muted))),
                  DataColumn(
                      label: Text('SỰ CỐ',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.muted))),
                  DataColumn(
                      label: Text('PHÒNG',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.muted))),
                  DataColumn(
                      label: Text('NGƯỜI BÁO',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.muted))),
                  DataColumn(
                      label: Text('NGÀY BÁO',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.muted))),
                  DataColumn(
                      label: Text('PHÂN CÔNG',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.muted))),
                  DataColumn(
                      label: Text('TRẠNG THÁI',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.muted))),
                  DataColumn(
                      label: Text('THAO TÁC',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.muted))),
                ],
                rows: repairs.map((r) {
                  final assigned = r['assignedTo'] ?? 'Chưa phân công';
                  final isCompleted = r['status'] == 'Hoàn thành';

                  return DataRow(cells: [
                    DataCell(Text(r['id']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12))),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(r['title']!,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          if ((r['description'] ?? '').isNotEmpty)
                            Text(
                              r['description']!,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.muted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    DataCell(
                        Text(r['room']!, style: const TextStyle(fontSize: 12))),
                    DataCell(Text(r['student']!,
                        style: const TextStyle(fontSize: 12))),
                    DataCell(
                        Text(r['date']!, style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: assigned == 'Chưa phân công'
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          assigned,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: assigned == 'Chưa phân công'
                                ? const Color(0xFFD97706)
                                : const Color(0xFF1D61F2),
                          ),
                        ),
                      ),
                    ),
                    DataCell(StatusChip(label: r['status']!)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.role == 'Quản lý KTX' ||
                              widget.role == 'Quản trị viên')
                            IconButton(
                              tooltip: 'Phân công kỹ thuật viên',
                              icon: const Icon(Icons.assignment_ind_outlined,
                                  color: AppColors.primary, size: 20),
                              onPressed: isCompleted
                                  ? null
                                  : () => _showAssignDialog(r),
                            ),
                          if (widget.role == 'Kỹ thuật viên' &&
                              !isCompleted &&
                              (assigned == 'Chưa phân công' ||
                                  assigned.isEmpty))
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4)),
                              onPressed: () {
                                setState(() {
                                  r['assignedTo'] = currentUserName;
                                  r['status'] = 'Đang xử lý';
                                });
                                DemoStore.addAudit(
                                    'Nhận xử lý sự cố ${r['id']}',
                                    currentUserName);
                                _notice('Đã nhận xử lý sự cố ${r['id']}.');
                              },
                              icon: const Icon(Icons.touch_app_outlined,
                                  size: 16),
                              label: const Text('Nhận việc',
                                  style: TextStyle(fontSize: 11)),
                            ),
                          if (widget.role == 'Kỹ thuật viên' ||
                              widget.role == 'Quản lý KTX' ||
                              widget.role == 'Quản trị viên')
                            IconButton(
                              tooltip: 'Đánh dấu hoàn thành',
                              icon: const Icon(Icons.check_circle_outline,
                                  color: AppColors.green, size: 20),
                              onPressed: isCompleted
                                  ? null
                                  : () {
                                      setState(
                                          () => r['status'] = 'Hoàn thành');
                                      DemoStore.addAudit(
                                          'Hoàn thành sự cố ${r['id']}',
                                          currentUserName);
                                      _notice(
                                          'Đã đánh dấu hoàn thành sự cố ${r['id']}.');
                                    },
                            ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      );

  void _showAssignDialog(Map<String, String> repair) {
    String selectedTech = 'Lê Quang Huy';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Phân công xử lý sự cố ${repair['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sự cố: ${repair['title']} - Phòng ${repair['room']}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedTech,
              decoration:
                  const InputDecoration(labelText: 'Chọn kỹ thuật viên'),
              items: const [
                DropdownMenuItem(
                    value: 'Lê Quang Huy',
                    child: Text('Lê Quang Huy (Đội Điện/Nước)')),
                DropdownMenuItem(
                    value: 'Nguyễn Văn Mạnh',
                    child: Text('Nguyễn Văn Mạnh (Đội Mạng/TB)')),
                DropdownMenuItem(
                    value: 'Trần Đình Trọng',
                    child: Text('Trần Đình Trọng (Xây dựng)')),
              ],
              onChanged: (val) {
                if (val != null) selectedTech = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              setState(() {
                repair['assignedTo'] = selectedTech;
                repair['status'] = 'Đang xử lý';
              });
              Navigator.pop(context);
              _notice(
                  'Đã phân công ${repair['assignedTo']} xử lý sự cố ${repair['id']}.');
            },
            child: const Text('Xác nhận phân công'),
          ),
        ],
      ),
    );
  }

  Widget _billsTable() {
    final isStudent = widget.role == 'Sinh viên';
    final visibleBills = bills
        .where((bill) =>
            !isStudent ||
            bill['email']?.toLowerCase() == widget.email.toLowerCase())
        .toList();
    return SectionCard(
      title: isStudent ? 'Hóa đơn của tôi' : 'Quản lý hóa đơn và điện nước',
      subtitle: isStudent
          ? 'Xem các khoản phí thuộc tài khoản của bạn.'
          : 'Theo dõi và tạo khoản thu cho sinh viên.',
      action: widget.role == 'Quản lý KTX'
          ? FilledButton.icon(
              onPressed: () => _addDialog(
                'Tạo hóa đơn',
                [
                  'Mã hóa đơn',
                  'Nội dung',
                  'Kỳ thu',
                  'Số tiền',
                  'Email sinh viên'
                ],
                onSave: (values) {
                  setState(() {
                    bills.insert(0, {
                      'id': values[0],
                      'title': values[1],
                      'period': values[2],
                      'amount': values[3],
                      'email': values[4].toLowerCase(),
                      'status': 'Chưa thanh toán',
                    });
                  });
                  DemoStore.addAudit(
                      'Tạo hóa đơn ${values[0]}', currentUserName);
                  _notice('Đã tạo hóa đơn demo cho ${values[4]}.');
                },
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tạo hóa đơn'),
            )
          : null,
      child: visibleBills.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Center(
                  child: Text('Chưa có hóa đơn nào cho tài khoản này.',
                      style: TextStyle(color: AppColors.muted))),
            )
          : LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowHeight: 45,
                    dataRowMinHeight: 54,
                    dataRowMaxHeight: 64,
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFF7F9FC)),
                    columns: [
                      ...[
                        'Mã hóa đơn',
                        'Nội dung',
                        'Kỳ',
                        'Số tiền',
                        'Trạng thái'
                      ].map((header) => DataColumn(
                          label: Text(header,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: AppColors.muted)))),
                      if (isStudent)
                        const DataColumn(
                            label: Text('Thao tác',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    color: AppColors.muted))),
                    ],
                    rows: visibleBills.map((bill) {
                      final unpaid = bill['status'] == 'Chưa thanh toán';
                      return DataRow(cells: [
                        DataCell(Text(bill['id'] ?? '',
                            style: const TextStyle(fontSize: 12))),
                        DataCell(Text(bill['title'] ?? '',
                            style: const TextStyle(fontSize: 12))),
                        DataCell(Text(bill['period'] ?? '',
                            style: const TextStyle(fontSize: 12))),
                        DataCell(Text(bill['amount'] ?? '',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700))),
                        DataCell(StatusChip(label: bill['status'] ?? '')),
                        if (isStudent)
                          DataCell(
                            unpaid
                                ? TextButton(
                                    onPressed: () {
                                      setState(() =>
                                          bill['status'] = 'Đã thanh toán');
                                      DemoStore.addAudit(
                                          'Xác nhận thanh toán demo ${bill['id']}',
                                          currentUserName);
                                      _notice(
                                          'Đã cập nhật trạng thái thanh toán demo. Không có giao dịch tiền thật.');
                                    },
                                    child: const Text('Xác nhận demo'),
                                  )
                                : const Icon(Icons.check_circle_outline,
                                    color: AppColors.green, size: 20),
                          ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _profile() {
    if (widget.role == 'Sinh viên') {
      return _studentProfileWidget();
    }
    return SectionCard(
      title: 'Hồ sơ tài khoản',
      subtitle: 'Thông tin đăng nhập bản demo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.person_outline_rounded,
                    size: 34, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentUserName,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                    const SizedBox(height: 4),
                    Text(widget.role,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    const SizedBox(height: 5),
                    Text(widget.email,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              const StatusChip(label: 'Đang hoạt động'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentProfileWidget() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 8,
          children: [
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                _addDialog(
                  'Chỉnh sửa thông tin cá nhân',
                  ['Họ và tên', 'Số điện thoại', 'Ngày sinh'],
                  initialValues: [
                    currentUserName,
                    '0912 345 678',
                    '15/03/2003'
                  ],
                  onSave: (values) {
                    setState(() {
                      currentAccount['name'] = values[0];
                    });
                    _notice('Đã cập nhật thông tin cá nhân.');
                  },
                );
              },
              child: const Text('Chỉnh sửa',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.text,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x050D2148),
                  blurRadius: 14,
                  offset: Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'NA',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1D61F2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUserName.isEmpty
                              ? 'Nguyễn Văn An'
                              : currentUserName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currentStudentCode · Công nghệ thông tin K21',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.muted),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Đang lưu trú',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 580;
                  final items = [
                    _profileInfoBox(
                        'Email',
                        widget.email.isEmpty
                            ? 'an.nv@university.edu.vn'
                            : widget.email),
                    _profileInfoBox('Số điện thoại', '0912 345 678'),
                    _profileInfoBox('Ngày sinh', '15/03/2003'),
                    _profileInfoBox('CCCD', '079203012345'),
                    _profileInfoBox('Phòng hiện tại', 'Tòa A — A301'),
                    _profileInfoBox('Năm học', '2024-2025'),
                  ];

                  if (isWide) {
                    return Column(
                      children: [
                        Row(children: [
                          Expanded(child: items[0]),
                          const SizedBox(width: 16),
                          Expanded(child: items[1])
                        ]),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(child: items[2]),
                          const SizedBox(width: 16),
                          Expanded(child: items[3])
                        ]),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(child: items[4]),
                          const SizedBox(width: 16),
                          Expanded(child: items[5])
                        ]),
                      ],
                    );
                  }

                  return Column(
                    children: items
                        .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: item))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x050D2148),
                  blurRadius: 14,
                  offset: Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đổi mật khẩu',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text),
              ),
              const SizedBox(height: 18),
              const Text('Mật khẩu hiện tại',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              const SizedBox(height: 8),
              TextFormField(
                controller: currentPassController,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Mật khẩu mới',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              const SizedBox(height: 8),
              TextFormField(
                controller: newPassController,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileInfoBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text)),
        ],
      ),
    );
  }

  Widget _studentNotificationsWidget() {
    final activeNotifs = DemoStore.notifications
        .where((n) => n['status'] == 'Đã gửi' || n['status'] == 'Đã phát hành')
        .toList();

    return StatefulBuilder(
      builder: (context, setNotificationState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              const Text(
                'Thông báo',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text),
              ),
              InkWell(
                onTap: () {
                  setNotificationState(() {
                    for (var n in DemoStore.notifications) {
                      n['isRead'] = 'true';
                    }
                  });
                  _notice('Đã đánh dấu tất cả thông báo là đã đọc.');
                },
                child: const Text(
                  'Đánh dấu tất cả đã đọc',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (activeNotifs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text('Chưa có thông báo nào.',
                    style: TextStyle(color: AppColors.muted)),
              ),
            )
          else
            ...activeNotifs.map((n) {
              final title = n['title'] ?? 'Thông báo';
              final lower = title.toLowerCase();
              String tag = 'TB';
              if (lower.contains('hóa đơn') || lower.contains('nợ')) {
                tag = 'HĐ';
              } else if (lower.contains('sự cố') ||
                  lower.contains('sửa chữa')) {
                tag = 'SC';
              } else if (lower.contains('bảo trì')) {
                tag = 'BT';
              } else if (lower.contains('pccc') || lower.contains('an toàn')) {
                tag = 'AT';
              }
              final isUnread = n['isRead'] != 'true';
              final time = n['createdAt'] ?? '';
              final content = n['content'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _notificationCard(
                  tag: tag,
                  title: title,
                  subtitle: content.isNotEmpty ? content : null,
                  time: time,
                  isUnread: isUnread,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _notificationCard({
    required String tag,
    required String title,
    String? subtitle,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x040D2148), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF1D61F2),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _generic() {
    if (widget.role == 'Sinh viên') {
      if (page == 'Thông báo') {
        return _studentNotificationsWidget();
      }
    }
    if (widget.role == 'Kỹ thuật viên') {
      if (page == 'Lịch bảo trì') {
        return const SectionCard(
            title: 'Lịch bảo trì',
            subtitle: 'Lịch công việc mẫu theo khu vực',
            child: Column(children: [
              RoleModuleHeading(
                  icon: Icons.calendar_month_outlined,
                  title: '08:30 · Kiểm tra hệ thống nước',
                  subtitle: 'Tòa A · Khu vệ sinh tầng 2'),
              Divider(height: 24),
              RoleModuleHeading(
                  icon: Icons.electrical_services_outlined,
                  title: '13:30 · Kiểm tra chiếu sáng',
                  subtitle: 'Tòa B · Hành lang tầng 1'),
              Divider(height: 24),
              RoleModuleHeading(
                  icon: Icons.ac_unit_outlined,
                  title: '15:00 · Bảo trì điều hòa',
                  subtitle: 'Tòa C · Phòng C-402'),
            ]));
      }
      if (page == 'Quản lý vật tư') {
        return SectionCard(
          title: 'Quản lý vật tư',
          subtitle: 'Theo dõi tồn kho và ghi nhận nhập vật tư.',
          action: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _addDialog(
                  'Xuất vật tư',
                  [
                    'Mã vật tư',
                    'Số lượng xuất',
                    'Mã sự cố liên quan (VD: SC-1024)'
                  ],
                  onSave: (values) {
                    final quantity = int.tryParse(values[1]);
                    if (quantity == null || quantity < 1) {
                      _notice('Số lượng xuất phải là số nguyên lớn hơn 0.');
                      return;
                    }
                    final index = DemoStore.inventory
                        .indexWhere((item) => item['id'] == values[0]);
                    if (index < 0) {
                      _notice('Không tìm thấy vật tư có mã ${values[0]}.');
                      return;
                    }
                    final currentQty = int.tryParse(
                            DemoStore.inventory[index]['quantity'] ?? '0') ??
                        0;
                    if (currentQty < quantity) {
                      _notice(
                          'Tồn kho không đủ! Hiện tại chỉ còn $currentQty sản phẩm.');
                      return;
                    }
                    setState(() {
                      final total = currentQty - quantity;
                      DemoStore.inventory[index]['quantity'] =
                          total.toString().padLeft(2, '0');
                      DemoStore.inventory[index]['status'] = total == 0
                          ? 'Hết hàng'
                          : (total <= 5 ? 'Sắp hết' : 'Còn hàng');
                    });
                    DemoStore.addAudit(
                        'Xuất $quantity ${values[0]} cho sự cố ${values[2]}',
                        currentUserName);
                    _notice('Đã xuất kho $quantity vật tư ${values[0]}.');
                  },
                ),
                icon: const Icon(Icons.remove_circle_outline, size: 17),
                label: const Text('Xuất vật tư'),
              ),
              FilledButton.icon(
                onPressed: () => _addDialog(
                  'Nhập vật tư',
                  ['Mã vật tư', 'Tên vật tư', 'Số lượng nhập'],
                  onSave: (values) {
                    final quantity = int.tryParse(values[2]);
                    if (quantity == null || quantity < 1) {
                      _notice('Số lượng phải là số nguyên lớn hơn 0.');
                      return;
                    }
                    setState(() {
                      final index = DemoStore.inventory
                          .indexWhere((item) => item['id'] == values[0]);
                      if (index >= 0) {
                        final oldQuantity = int.tryParse(
                                DemoStore.inventory[index]['quantity'] ??
                                    '0') ??
                            0;
                        final total = oldQuantity + quantity;
                        DemoStore.inventory[index]['quantity'] =
                            total.toString().padLeft(2, '0');
                        DemoStore.inventory[index]['status'] =
                            total <= 5 ? 'Sắp hết' : 'Còn hàng';
                      } else {
                        DemoStore.inventory.add({
                          'id': values[0],
                          'name': values[1],
                          'quantity': quantity.toString().padLeft(2, '0'),
                          'status': quantity <= 5 ? 'Sắp hết' : 'Còn hàng',
                        });
                      }
                    });
                    DemoStore.addAudit(
                        'Nhập kho vật tư ${values[0]} (+$quantity)',
                        currentUserName);
                    _notice('Đã nhập kho vật tư thành công.');
                  },
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nhập vật tư'),
              ),
            ],
          ),
          child: _simpleTable(
            ['Mã vật tư', 'Tên vật tư', 'Tồn kho', 'Trạng thái'],
            DemoStore.inventory
                .map((item) => [
                      item['id']!,
                      item['name']!,
                      item['quantity']!,
                      item['status']!
                    ])
                .toList(),
          ),
        );
      }
    }
    if (widget.role == 'Quản trị viên') {
      if (page == 'Quản lý tài khoản') {
        return _AdminAccountManagementWidget(
            currentEmail: widget.email,
            currentUserName: currentUserName,
            onAccountsChanged: () => setState(() {}));
      }
      if (page == 'Phân quyền') {
        return _AdminPermissionMatrixWidget(currentUserName: currentUserName);
      }
      if (page == 'Nhật ký hệ thống') {
        return SectionCard(
          title: 'Nhật ký hệ thống',
          subtitle: 'Các hoạt động mới nhất trong phiên demo.',
          child: _simpleTable(
            ['Hoạt động', 'Người thực hiện', 'Thời gian'],
            DemoStore.auditLogs
                .map((entry) =>
                    [entry['action']!, entry['actor']!, entry['time']!])
                .toList(),
          ),
        );
      }
      if (page == 'Cấu hình' || page == 'Cấu hình hệ thống') {
        return SectionCard(
          title: 'Cấu hình hệ thống',
          subtitle: 'Các tùy chọn demo chỉ có hiệu lực trong phiên hiện tại.',
          child: Column(children: [
            const RoleModuleHeading(
                icon: Icons.palette_outlined,
                title: 'Giao diện',
                subtitle: 'Tông màu xanh trắng DormHub'),
            const Divider(height: 20),
            Material(
              color: Colors.transparent,
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bật thông báo qua email',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: const Text(
                    'Hiện chưa gửi email thật vì chưa cấu hình máy chủ.',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
                value: emailNotificationsEnabled,
                onChanged: (value) =>
                    setState(() => emailNotificationsEnabled = value),
              ),
            ),
            const Divider(height: 20),
            const RoleModuleHeading(
                icon: Icons.storage_outlined,
                title: 'Cơ sở dữ liệu',
                subtitle: 'Hiện dữ liệu đang lưu tạm trong bộ nhớ'),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                    onPressed: () {
                      DemoStore.addAudit('Lưu cấu hình demo', currentUserName);
                      _notice(
                          'Đã ghi nhận cấu hình trong phiên demo. Các thay đổi sẽ mất khi tải lại ứng dụng.');
                    },
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Lưu cấu hình demo'))),
          ]),
        );
      }
    }
    if (widget.role == 'Quản lý KTX' && page == 'Vi phạm') {
      return SectionCard(
        title: 'Theo dõi vi phạm',
        subtitle: 'Ghi nhận và xử lý vi phạm nội quy ký túc xá.',
        action: FilledButton.icon(
            onPressed: () => _addDialog('Ghi nhận vi phạm', [
                  'Mã ghi nhận',
                  'Tên sinh viên',
                  'Nội dung vi phạm'
                ], onSave: (values) {
                  setState(() => DemoStore.violations.insert(0, {
                        'id': values[0],
                        'student': values[1],
                        'description': values[2],
                        'date': DemoStore.dateToday(),
                        'status': 'Chờ xác minh'
                      }));
                  DemoStore.addAudit(
                      'Ghi nhận vi phạm ${values[0]}', currentUserName);
                  _notice('Đã ghi nhận vi phạm demo.');
                }),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ghi nhận')),
        child: _simpleTable(
          ['Mã ghi nhận', 'Sinh viên', 'Nội dung', 'Ngày', 'Trạng thái'],
          DemoStore.violations
              .map((item) => [
                    item['id']!,
                    item['student']!,
                    item['description']!,
                    item['date']!,
                    item['status']!
                  ])
              .toList(),
          actions: true,
        ),
      );
    }

    return SectionCard(
      title: 'Chức năng: $page',
      subtitle: 'Khu vực thao tác của vai trò ${widget.role}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RoleModuleHeading(
              icon: Icons.dashboard_customize_outlined,
              title: 'Khu vực chức năng đã tách riêng',
              subtitle:
                  'Nội dung được nhóm theo vai trò để dễ tìm và thao tác.'),
          const SizedBox(height: 18),
          const Text(
              'Dữ liệu hiện là minh họa. Cần kết nối API và cơ sở dữ liệu để lưu, đồng bộ và kiểm soát quyền truy cập thật.',
              style:
                  TextStyle(color: AppColors.muted, height: 1.6, fontSize: 12)),
          const SizedBox(height: 20),
          FilledButton.icon(
              onPressed: () => _addDialog(
                  'Thêm dữ liệu - $page', ['Tên / tiêu đề', 'Mô tả']),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm dữ liệu demo')),
        ],
      ),
    );
  }

  void _handleTableAction(String id, bool primary) {
    setState(() {
      if (id.startsWith('DK')) {
        final index =
            applications.indexWhere((application) => application['id'] == id);
        if (index < 0) return;
        final application = applications[index];
        if (!primary) {
          application['status'] = 'Từ chối';
          DemoStore.notifications.insert(0, {
            'id': DemoStore.nextId('TB-TUCHOI'),
            'title': 'Đơn đăng ký phòng bị từ chối',
            'content':
                'Đơn đăng ký phòng của bạn (${application['id']}) đã bị từ chối do không còn chỗ trống phù hợp.',
            'target': application['name'] ?? 'Sinh viên',
            'author': 'Quản lý KTX',
            'status': 'Đã gửi',
            'sendType': 'In-app',
            'createdAt': DemoStore.dateToday(),
            'isRead': 'false',
          });
          DemoStore.addAudit(
              'Từ chối đơn đăng ký ${application['id']}', currentUserName);
          return;
        }
        application['status'] = 'Đã duyệt';
        var assignedRoom = application['room'] ?? 'Chưa phân';
        if (assignedRoom == 'Chưa phân' ||
            assignedRoom.isEmpty ||
            assignedRoom == 'Chờ phân phòng') {
          const candidateRooms = [
            'A-106',
            'A-107',
            'B-101',
            'B-102',
            'C-101',
            'C-102',
            'D-101'
          ];
          final occupiedRooms =
              students.map((student) => student['room']).toSet();
          assignedRoom = candidateRooms.firstWhere(
              (room) => !occupiedRooms.contains(room),
              orElse: () => 'Chờ phân phòng');
          application['room'] = assignedRoom;
        }
        final studentIndex = students.indexWhere((student) =>
            student['email']?.toLowerCase() ==
            (application['email'] ?? '').toLowerCase());
        if (studentIndex >= 0) {
          students[studentIndex]['room'] = assignedRoom;
          students[studentIndex]['status'] =
              assignedRoom.startsWith('Chờ') ? 'Chờ nhận phòng' : 'Đang ở';
        } else {
          students.add({
            'id': application['code'] ?? DemoStore.nextId('SV'),
            'name': application['name'] ?? 'Sinh viên mới',
            'email': application['email'] ?? '',
            'room': assignedRoom,
            'status':
                assignedRoom.startsWith('Chờ') ? 'Chờ nhận phòng' : 'Đang ở',
          });
        }
        // Tự động tạo hợp đồng tương ứng vào DemoStore.contracts
        final appEmail = (application['email'] ?? '').toLowerCase();
        final hasContract = DemoStore.contracts.any((c) =>
            (c['email'] ?? '').toLowerCase() == appEmail &&
            c['status'] == 'Đang hiệu lực');
        if (!hasContract && !assignedRoom.startsWith('Chờ')) {
          DemoStore.contracts.insert(0, {
            'id': DemoStore.nextId('HD-KTX'),
            'student': application['name'] ?? '',
            'studentCode': application['code'] ?? '',
            'email': application['email'] ?? '',
            'room': assignedRoom,
            'building': application['building'] ?? 'Tòa A',
            'startDate': DemoStore.dateToday(),
            'endDate': '31/05/2026',
            'monthlyFee': '600.000 đ',
            'deposit': '1.200.000 đ',
            'status': 'Đang hiệu lực',
          });
        }
        DemoStore.notifications.insert(0, {
          'id': DemoStore.nextId('TB-DUYET'),
          'title': 'Đơn đăng ký phòng đã được duyệt',
          'content':
              'Chúc mừng bạn! Đơn đăng ký lưu trú đã được duyệt. Phòng được phân: $assignedRoom.',
          'target': application['name'] ?? 'Sinh viên',
          'author': 'Quản lý KTX',
          'status': 'Đã gửi',
          'sendType': 'In-app',
          'createdAt': DemoStore.dateToday(),
          'isRead': 'false',
        });
        DemoStore.addAudit(
            'Duyệt đơn đăng ký ${application['id']} - Xếp phòng $assignedRoom',
            currentUserName);
        return;
      }
      if (id.startsWith('SC')) {
        final index = repairs.indexWhere((repair) => repair['id'] == id);
        if (index < 0) return;
        if (widget.role == 'Kỹ thuật viên') {
          repairs[index]['status'] = primary ? 'Đang xử lý' : 'Hoàn thành';
        } else {
          repairs[index]['status'] = primary ? 'Đã gán' : 'Đang xử lý';
          if (primary) repairs[index]['assignedTo'] = 'Đội kỹ thuật';
        }
        return;
      }
      if (id.startsWith('VP')) {
        final index = DemoStore.violations
            .indexWhere((violation) => violation['id'] == id);
        if (index >= 0) {
          DemoStore.violations[index]['status'] =
              primary ? 'Đã nhắc nhở' : 'Đã xử lý';
        }
      }
    });
    if (id.startsWith('DK')) {
      DemoStore.addAudit(
          primary ? 'Duyệt đơn đăng ký $id' : 'Từ chối đơn đăng ký $id',
          currentUserName);
      _notice(primary
          ? 'Đã duyệt đơn và cập nhật thông tin phòng.'
          : 'Đã từ chối đơn đăng ký.');
    } else if (id.startsWith('SC')) {
      DemoStore.addAudit(
          primary ? 'Cập nhật sự cố $id' : 'Cập nhật hoàn tất sự cố $id',
          currentUserName);
      _notice(primary
          ? (widget.role == 'Kỹ thuật viên'
              ? 'Đã nhận xử lý yêu cầu.'
              : 'Đã gán yêu cầu cho đội kỹ thuật.')
          : (widget.role == 'Kỹ thuật viên'
              ? 'Đã đánh dấu hoàn thành.'
              : 'Đã cập nhật trạng thái xử lý.'));
    } else if (id.startsWith('VP')) {
      DemoStore.addAudit(primary ? 'Nhắc nhở vi phạm $id' : 'Đóng vi phạm $id',
          currentUserName);
      _notice(
          primary ? 'Đã ghi nhận nhắc nhở.' : 'Đã đánh dấu vi phạm đã xử lý.');
    }
  }

  Widget _simpleTable(List<String> headers, List<List<String>> rows,
      {bool actions = false}) {
    const statusValues = {
      'Đang ở',
      'Chờ nhận phòng',
      'Chờ duyệt',
      'Đã duyệt',
      'Từ chối',
      'Mới',
      'Đã gán',
      'Đang xử lý',
      'Hoàn thành',
      'Chưa thanh toán',
      'Đã thanh toán',
      'Chờ xác minh',
      'Đã nhắc nhở',
      'Đã xử lý',
      'Còn hàng',
      'Sắp hết',
      'Đang hoạt động',
      'Đã khóa',
      'Chưa phân',
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 45,
              dataRowMinHeight: 54,
              dataRowMaxHeight: 62,
              horizontalMargin: 12,
              columnSpacing: 24,
              dividerThickness: .5,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF7F9FC)),
              columns: [
                ...headers.map((header) => DataColumn(
                    label: Text(header,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: AppColors.muted)))),
                if (actions)
                  const DataColumn(
                      label: Text('Thao tác',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppColors.muted))),
              ],
              rows: rows.map((row) {
                final id = row.isNotEmpty ? row.first : '';
                final isApplicationRow = id.startsWith('DK');
                final isViolationRow = id.startsWith('VP');
                final isTechnician = widget.role == 'Kỹ thuật viên';
                final rowStatus = row.isNotEmpty ? row.last : '';
                final isFinalRow =
                    (isApplicationRow && rowStatus != 'Chờ duyệt') ||
                        (id.startsWith('SC') && rowStatus == 'Hoàn thành') ||
                        (isViolationRow && rowStatus == 'Đã xử lý');
                return DataRow(cells: [
                  ...row.asMap().entries.map((entry) {
                    final value = entry.value;
                    final isStatus = entry.key == row.length - 1 &&
                        statusValues.contains(value);
                    return DataCell(
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: value.contains('@') ? 210 : 190),
                        child: isStatus
                            ? StatusChip(label: value)
                            : Text(value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w500)),
                      ),
                    );
                  }),
                  if (actions)
                    DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        tooltip: isApplicationRow
                            ? 'Duyệt đơn'
                            : isViolationRow
                                ? 'Nhắc nhở'
                                : isTechnician
                                    ? 'Nhận xử lý'
                                    : 'Gán kỹ thuật viên',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                            isApplicationRow
                                ? Icons.check_circle_outline_rounded
                                : isViolationRow
                                    ? Icons.check_circle_outline_rounded
                                    : isTechnician
                                        ? Icons.play_circle_outline_rounded
                                        : Icons.assignment_ind_outlined,
                            color: AppColors.green,
                            size: 20),
                        onPressed: isFinalRow
                            ? null
                            : () => _handleTableAction(id, true),
                      ),
                      IconButton(
                        tooltip: isApplicationRow
                            ? 'Từ chối đơn'
                            : isViolationRow
                                ? 'Đánh dấu đã xử lý'
                                : isTechnician
                                    ? 'Đánh dấu hoàn thành'
                                    : 'Chuyển sang đang xử lý',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                            isApplicationRow
                                ? Icons.cancel_outlined
                                : isViolationRow
                                    ? Icons.task_alt_rounded
                                    : Icons.pending_actions_outlined,
                            color: isApplicationRow
                                ? AppColors.red
                                : AppColors.purple,
                            size: 20),
                        onPressed: isFinalRow
                            ? null
                            : () => _handleTableAction(id, false),
                      ),
                    ])),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _addDialog(
    String title,
    List<String> fields, {
    List<String>? initialValues,
    void Function(List<String> values)? onSave,
  }) {
    final controllers = List.generate(
        fields.length,
        (index) => TextEditingController(
              text: initialValues != null && index < initialValues.length
                  ? initialValues[index]
                  : '',
            ));
    final formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 430,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    fields.length,
                    (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: controllers[index],
                            maxLines:
                                fields[index].toLowerCase().contains('mô tả')
                                    ? 3
                                    : 1,
                            decoration: InputDecoration(
                                labelText: fields[index],
                                alignLabelWithHint: true),
                            validator: (value) => (value?.trim().isEmpty ??
                                    true)
                                ? 'Vui lòng nhập ${fields[index].toLowerCase()}.'
                                : null,
                          ),
                        )),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final values = controllers
                  .map((controller) => controller.text.trim())
                  .toList();
              Navigator.pop(dialogContext);
              if (onSave != null) {
                onSave(values);
              } else {
                _notice(
                    'Đã nhận thông tin demo. Dữ liệu chỉ tồn tại trong phiên ứng dụng hiện tại.');
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    ).then((_) {
      for (final controller in controllers) {
        controller.dispose();
      }
    });
  }
}

class _AdminAccountManagementWidget extends StatefulWidget {
  final String currentEmail;
  final String currentUserName;
  final VoidCallback onAccountsChanged;

  const _AdminAccountManagementWidget({
    required this.currentEmail,
    required this.currentUserName,
    required this.onAccountsChanged,
  });

  @override
  State<_AdminAccountManagementWidget> createState() =>
      _AdminAccountManagementWidgetState();
}

class _AdminAccountManagementWidgetState
    extends State<_AdminAccountManagementWidget> {
  String searchQuery = '';
  String filterRole = 'Tất cả vai trò';
  String filterStatus = 'Tất cả trạng thái';

  void _notice(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = DemoStore.accounts.where((acc) {
      final name = (acc['name'] ?? '').toLowerCase();
      final email = (acc['email'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase().trim();

      final matchesQuery =
          query.isEmpty || name.contains(query) || email.contains(query);
      final matchesRole =
          filterRole == 'Tất cả vai trò' || acc['role'] == filterRole;
      final matchesStatus = filterStatus == 'Tất cả trạng thái' ||
          (acc['status'] ?? 'Đang hoạt động') == filterStatus;

      return matchesQuery && matchesRole && matchesStatus;
    }).toList();

    return SectionCard(
      title: 'Quản lý tài khoản người dùng',
      subtitle:
          'Dữ liệu mẫu trong bộ nhớ; các thao tác ở đây không cập nhật Firebase Auth hoặc Firestore.',
      action: FilledButton.icon(
        onPressed: _addAccountDialog,
        icon: const Icon(Icons.person_add_alt_1, size: 18),
        label: const Text('Thêm tài khoản'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chức năng quản trị tài khoản thật cần backend đặc quyền. Các bản ghi dưới đây chỉ dùng để minh họa giao diện.',
            style: TextStyle(color: AppColors.orange, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo họ tên, email...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(
                width: 170,
                child: DropdownButtonFormField<String>(
                  initialValue: filterRole,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Tất cả vai trò',
                        child: Text('Tất cả vai trò',
                            style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'Sinh viên',
                        child:
                            Text('Sinh viên', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'Quản lý KTX',
                        child: Text('Quản lý KTX',
                            style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'Kỹ thuật viên',
                        child: Text('Kỹ thuật viên',
                            style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'Quản trị viên',
                        child: Text('Quản trị viên',
                            style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => filterRole = val);
                  },
                ),
              ),
              SizedBox(
                width: 170,
                child: DropdownButtonFormField<String>(
                  initialValue: filterStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Tất cả trạng thái',
                        child: Text('Tất cả trạng thái',
                            style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'Đang hoạt động',
                        child: Text('Đang hoạt động',
                            style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'Đã khóa',
                        child: Text('Đã khóa', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => filterStatus = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowHeight: 45,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 66,
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFFF7F9FC)),
                  columns: const [
                    DataColumn(
                        label: Text('HỌ TÊN',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.muted))),
                    DataColumn(
                        label: Text('EMAIL',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.muted))),
                    DataColumn(
                        label: Text('VAI TRÒ',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.muted))),
                    DataColumn(
                        label: Text('TRẠNG THÁI',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.muted))),
                    DataColumn(
                        label: Text('THAO TÁC',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.muted))),
                  ],
                  rows: filtered.map((account) {
                    final active = (account['status'] ?? 'Đang hoạt động') ==
                        'Đang hoạt động';
                    final isSelf = account['email']?.toLowerCase() ==
                        widget.currentEmail.toLowerCase();

                    return DataRow(cells: [
                      DataCell(Text(account['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600))),
                      DataCell(Text(account['email'] ?? '',
                          style: const TextStyle(fontSize: 12))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(account['role'] ?? '',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D61F2))),
                      )),
                      DataCell(StatusChip(
                          label: account['status'] ?? 'Đang hoạt động')),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Chỉnh sửa tài khoản',
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.primary, size: 19),
                            onPressed: () => _editAccountDialog(account),
                          ),
                          IconButton(
                            tooltip:
                                active ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
                            icon: Icon(
                                active
                                    ? Icons.lock_outline_rounded
                                    : Icons.lock_open_rounded,
                                color:
                                    active ? AppColors.orange : AppColors.green,
                                size: 19),
                            onPressed: () {
                              if (active && isSelf) {
                                _notice(
                                    'Không thể tự khóa tài khoản đang đăng nhập.');
                                return;
                              }
                              setState(() => account['status'] =
                                  active ? 'Đã khóa' : 'Đang hoạt động');
                              DemoStore.addAudit(
                                  active
                                      ? 'Khóa tài khoản ${account['email']}'
                                      : 'Mở khóa tài khoản ${account['email']}',
                                  widget.currentUserName);
                              _notice(active
                                  ? 'Đã khóa tài khoản ${account['email']}.'
                                  : 'Đã mở khóa tài khoản ${account['email']}.');
                              widget.onAccountsChanged();
                            },
                          ),
                          IconButton(
                            tooltip: 'Xóa tài khoản',
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.red, size: 19),
                            onPressed: isSelf
                                ? null
                                : () => _deleteAccountDialog(account),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addAccountDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedRole = 'Sinh viên';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Thêm tài khoản mới',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: 'Họ và tên người dùng'),
                      validator: (value) => (value?.trim().length ?? 0) < 2
                          ? 'Vui lòng nhập họ tên.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(labelText: 'Email định danh'),
                      validator: (value) {
                        final normalized = value?.trim().toLowerCase() ?? '';
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(normalized)) {
                          return 'Email không hợp lệ.';
                        }
                        if (DemoStore.accounts.any((acc) =>
                            acc['email']?.toLowerCase() == normalized)) {
                          return 'Email đã tồn tại.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Phân vai trò hệ thống'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Sinh viên', child: Text('Sinh viên')),
                        DropdownMenuItem(
                            value: 'Quản lý KTX', child: Text('Quản lý KTX')),
                        DropdownMenuItem(
                            value: 'Kỹ thuật viên',
                            child: Text('Kỹ thuật viên')),
                        DropdownMenuItem(
                            value: 'Quản trị viên',
                            child: Text('Quản trị viên')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedRole = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final email = emailController.text.trim().toLowerCase();
                final name = nameController.text.trim();
                Navigator.pop(dialogContext);
                setState(() {
                  DemoStore.accounts.add({
                    'name': name,
                    'email': email,
                    'role': selectedRole,
                    'status': 'Đang hoạt động',
                  });
                });
                DemoStore.addAudit('Thêm tài khoản $email ($selectedRole)',
                    widget.currentUserName);
                _notice(
                    'Đã thêm bản ghi demo cho $name. Firebase chưa có tài khoản này.');
                widget.onAccountsChanged();
              },
              child: const Text('Thêm bản ghi demo'),
            ),
          ],
        ),
      ),
    );
  }

  void _editAccountDialog(Map<String, String> account) {
    final nameController = TextEditingController(text: account['name']);
    String selectedRole = account['role'] ?? 'Sinh viên';
    String selectedStatus = account['status'] ?? 'Đang hoạt động';
    final isSelf =
        account['email']?.toLowerCase() == widget.currentEmail.toLowerCase();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Chỉnh sửa tài khoản ${account['email']}',
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Họ và tên'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Vai trò'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Sinh viên', child: Text('Sinh viên')),
                      DropdownMenuItem(
                          value: 'Quản lý KTX', child: Text('Quản lý KTX')),
                      DropdownMenuItem(
                          value: 'Kỹ thuật viên', child: Text('Kỹ thuật viên')),
                      DropdownMenuItem(
                          value: 'Quản trị viên', child: Text('Quản trị viên')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'Trạng thái tài khoản'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Đang hoạt động',
                          child: Text('Đang hoạt động')),
                      DropdownMenuItem(
                          value: 'Đã khóa', child: Text('Đã khóa')),
                    ],
                    onChanged: isSelf
                        ? null
                        : (val) {
                            if (val != null) {
                              setDialogState(() => selectedStatus = val);
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy')),
            FilledButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isEmpty) return;
                Navigator.pop(dialogContext);
                setState(() {
                  account['name'] = newName;
                  account['role'] = selectedRole;
                  account['status'] = selectedStatus;
                });
                DemoStore.addAudit('Sửa tài khoản ${account['email']}',
                    widget.currentUserName);
                _notice('Đã cập nhật tài khoản ${account['email']}.');
                widget.onAccountsChanged();
              },
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAccountDialog(Map<String, String> account) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa tài khoản'),
        content: Text(
            'Bạn có chắc chắn muốn xóa tài khoản ${account['email']} (${account['name']}) khỏi hệ thống?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                DemoStore.accounts
                    .removeWhere((acc) => acc['email'] == account['email']);
              });
              DemoStore.addAudit(
                  'Xóa tài khoản ${account['email']}', widget.currentUserName);
              _notice('Đã xóa tài khoản ${account['email']}.');
              widget.onAccountsChanged();
            },
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );
  }
}

class _AdminPermissionMatrixWidget extends StatefulWidget {
  final String currentUserName;

  const _AdminPermissionMatrixWidget({required this.currentUserName});

  @override
  State<_AdminPermissionMatrixWidget> createState() =>
      _AdminPermissionMatrixWidgetState();
}

class _AdminPermissionMatrixWidgetState
    extends State<_AdminPermissionMatrixWidget> {
  final Map<String, Map<String, Map<String, bool>>> matrix = {
    'Đăng ký & Hợp đồng': {
      'Sinh viên': {'read': true, 'write': true, 'delete': false},
      'Kỹ thuật viên': {'read': false, 'write': false, 'delete': false},
      'Quản lý KTX': {'read': true, 'write': true, 'delete': true},
      'Quản trị viên': {'read': true, 'write': false, 'delete': false},
    },
    'Hóa đơn & Điện nước': {
      'Sinh viên': {'read': true, 'write': false, 'delete': false},
      'Kỹ thuật viên': {'read': false, 'write': false, 'delete': false},
      'Quản lý KTX': {'read': true, 'write': true, 'delete': true},
      'Quản trị viên': {'read': true, 'write': false, 'delete': false},
    },
    'Sự cố & Bảo trì': {
      'Sinh viên': {'read': true, 'write': true, 'delete': false},
      'Kỹ thuật viên': {'read': true, 'write': true, 'delete': false},
      'Quản lý KTX': {'read': true, 'write': true, 'delete': true},
      'Quản trị viên': {'read': true, 'write': false, 'delete': false},
    },
    'Quản lý Vật tư': {
      'Sinh viên': {'read': false, 'write': false, 'delete': false},
      'Kỹ thuật viên': {'read': true, 'write': true, 'delete': false},
      'Quản lý KTX': {'read': true, 'write': false, 'delete': false},
      'Quản trị viên': {'read': true, 'write': false, 'delete': false},
    },
    'Tài khoản & Phân quyền': {
      'Sinh viên': {'read': false, 'write': false, 'delete': false},
      'Kỹ thuật viên': {'read': false, 'write': false, 'delete': false},
      'Quản lý KTX': {'read': false, 'write': false, 'delete': false},
      'Quản trị viên': {'read': true, 'write': true, 'delete': true},
    },
    'Cấu hình & Audit Logs': {
      'Sinh viên': {'read': false, 'write': false, 'delete': false},
      'Kỹ thuật viên': {'read': false, 'write': false, 'delete': false},
      'Quản lý KTX': {'read': false, 'write': false, 'delete': false},
      'Quản trị viên': {'read': true, 'write': true, 'delete': true},
    },
  };

  void _notice(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = [
      'Sinh viên',
      'Kỹ thuật viên',
      'Quản lý KTX',
      'Quản trị viên'
    ];

    return SectionCard(
      title: 'Ma trận Phân quyền Vai trò (RBAC)',
      subtitle:
          'Thiết lập chi tiết quyền Xem (Read), Tạo/Sửa (Write) và Xóa/Quản trị (Admin) theo vai trò',
      action: FilledButton.icon(
        onPressed: () {
          DemoStore.addAudit(
              'Lưu ma trận phân quyền hệ thống', widget.currentUserName);
          _notice('Đã lưu cấu hình ma trận phân quyền thành công.');
        },
        icon: const Icon(Icons.save_outlined, size: 18),
        label: const Text('Lưu phân quyền'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhấp vào từng ô để điều chỉnh quyền truy cập của nhóm vai trò tương ứng:',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowHeight: 48,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 74,
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFFF7F9FC)),
                  columns: [
                    const DataColumn(
                        label: Text('MÔ-ĐƯN HỆ THỐNG',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.muted))),
                    ...roles.map((role) => DataColumn(
                          label: Text(role.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.muted)),
                        )),
                  ],
                  rows: matrix.entries.map((entry) {
                    final moduleName = entry.key;
                    final rolePerms = entry.value;

                    return DataRow(cells: [
                      DataCell(Text(moduleName,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700))),
                      ...roles.map((role) {
                        final perms = rolePerms[role] ??
                            {'read': false, 'write': false, 'delete': false};
                        final isAdminRole = role == 'Quản trị viên' &&
                            moduleName.contains('Tài khoản');

                        return DataCell(
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: isAdminRole
                                ? () => _notice(
                                    'Không thể chỉnh sửa quyền Quản trị tối cao.')
                                : () =>
                                    _editCellDialog(moduleName, role, perms),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Wrap(
                                spacing: 4,
                                children: [
                                  _permChip('Xem', perms['read'] ?? false,
                                      const Color(0xFF1D61F2)),
                                  _permChip('Sửa', perms['write'] ?? false,
                                      AppColors.purple),
                                  _permChip('Xóa', perms['delete'] ?? false,
                                      AppColors.red),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permChip(String label, bool active, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: .12) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color:
                active ? color.withValues(alpha: .4) : const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          color: active ? color : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  void _editCellDialog(String module, String role, Map<String, bool> perms) {
    bool read = perms['read'] ?? false;
    bool write = perms['write'] ?? false;
    bool delete = perms['delete'] ?? false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Cấu hình quyền $role — $module',
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('Quyền Xem (Read)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: const Text('Cho phép truy cập và tra cứu dữ liệu',
                    style: TextStyle(fontSize: 11)),
                value: read,
                onChanged: (val) => setDialogState(() => read = val ?? false),
              ),
              CheckboxListTile(
                title: const Text('Quyền Tạo / Sửa (Write)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: const Text(
                    'Cho phép tạo mới, cập nhật và duyệt hồ sơ',
                    style: TextStyle(fontSize: 11)),
                value: write,
                onChanged: (val) => setDialogState(() => write = val ?? false),
              ),
              CheckboxListTile(
                title: const Text('Quyền Xóa / Quản trị (Admin)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: const Text(
                    'Cho phép xóa dữ liệu hoặc thay đổi cấu hình',
                    style: TextStyle(fontSize: 11)),
                value: delete,
                onChanged: (val) => setDialogState(() => delete = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy')),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  perms['read'] = read;
                  perms['write'] = write;
                  perms['delete'] = delete;
                });
                DemoStore.addAudit('Cập nhật quyền $role trên $module',
                    widget.currentUserName);
                _notice('Đã cập nhật quyền hạn của nhóm $role.');
              },
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }
}
