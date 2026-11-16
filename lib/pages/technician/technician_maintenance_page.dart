import 'package:flutter/material.dart';
import '../../data/demo_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class TechnicianMaintenancePageWidget extends StatefulWidget {
  final String authorName;
  const TechnicianMaintenancePageWidget(
      {super.key, this.authorName = 'Kỹ thuật viên'});

  @override
  State<TechnicianMaintenancePageWidget> createState() =>
      _TechnicianMaintenancePageWidgetState();
}

class _TechnicianMaintenancePageWidgetState
    extends State<TechnicianMaintenancePageWidget> {
  String selectedFilter = 'Tất cả';

  List<Map<String, String>> get maintenanceSchedules =>
      DemoStore.maintenanceSchedules;

  @override
  Widget build(BuildContext context) {
    final filtered = maintenanceSchedules.where((item) {
      if (selectedFilter == 'Tất cả') return true;
      return item['status'] == selectedFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Lịch bảo trì & Kiểm tra kỹ thuật',
          subtitle:
              'Quản lý tiến độ bảo trì định kỳ và chủ động gửi thông báo tới sinh viên.',
          action: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1D61F2),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _showAddScheduleDialog,
            icon: const Icon(Icons.add_task_rounded, size: 18),
            label: const Text('Thêm lịch bảo trì',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Tất cả', 'Sắp diễn ra', 'Đang thực hiện', 'Hoàn thành']
                .map((filter) {
              final isSelected = selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor:
                      const Color(0xFF1D61F2).withValues(alpha: 0.15),
                  checkmarkColor: const Color(0xFF1D61F2),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? const Color(0xFF1D61F2) : AppColors.text,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (_) => setState(() => selectedFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) => _buildScheduleCard(filtered[index]),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, String> item) {
    Color statusColor = const Color(0xFF1D61F2);
    Color statusBg = const Color(0xFFEFF6FF);
    if (item['status'] == 'Đang thực hiện') {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
    } else if (item['status'] == 'Hoàn thành') {
      statusColor = const Color(0xFF16A34A);
      statusBg = const Color(0xFFDCFCE7);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x040D2148), blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(item['type']!,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569))),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusBg, borderRadius: BorderRadius.circular(20)),
                child: Text(item['status']!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item['title']!,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text('Khu vực: ${item['location']}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.text))),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 16, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text(item['time']!,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.text,
                              fontWeight: FontWeight.w600))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 16, color: Color(0xFFEA580C)),
              const SizedBox(width: 4),
              Expanded(
                  child: Text('Ảnh hưởng: ${item['impact']}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEA580C),
                          fontWeight: FontWeight.w600))),
            ],
          ),
          const Divider(height: 24),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              DropdownButton<String>(
                value: item['status'],
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                      value: 'Sắp diễn ra',
                      child: Text('Trạng thái: Sắp diễn ra',
                          style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(
                      value: 'Đang thực hiện',
                      child: Text('Trạng thái: Đang thực hiện',
                          style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(
                      value: 'Hoàn thành',
                      child: Text('Trạng thái: Hoàn thành',
                          style: TextStyle(fontSize: 12))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => item['status'] = val);
                    DemoStore.addAudit(
                        'Cập nhật trạng thái bảo trì ${item['id']}: $val',
                        widget.authorName);
                  }
                },
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showNotifyStudentsDialog(item),
                icon: const Icon(Icons.campaign_outlined, size: 18),
                label: const Text('Gửi thông báo cho SV',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNotifyStudentsDialog(Map<String, String> item) {
    final titleController =
        TextEditingController(text: 'Thông báo bảo trì: ${item['title']}');
    final contentController = TextEditingController(
      text:
          'Đội kỹ thuật sẽ tiến hành "${item['title']}" tại khu vực ${item['location']}.\n'
          'Thời gian dự kiến: ${item['time']}.\n'
          'Ảnh hưởng: ${item['impact']}.\n'
          'Trân trọng thông báo đến sinh viên sắp xếp sinh hoạt.',
    );
    // Lưu messenger trước khi pop dialog để tránh dùng context đã unmount
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text('Gửi thông báo cho Sinh viên',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Phạm vi gửi thông báo:',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(item['location']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AppColors.text)),
                ),
                const SizedBox(height: 14),
                TextField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(labelText: 'Tiêu đề thông báo')),
                const SizedBox(height: 12),
                TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(labelText: 'Nội dung chi tiết')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy')),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7)),
            onPressed: () {
              final location = item['location'] ?? 'Toàn KTX';
              final titleText = titleController.text.trim();
              final contentText = contentController.text.trim();
              DemoStore.notifications.insert(0, {
                'id': DemoStore.nextId('TB-BT'),
                'title': titleText,
                'content': contentText,
                'target': location,
                'author': widget.authorName,
                'status': 'Đã gửi',
                'sendType': 'In-app',
                'createdAt': DemoStore.dateToday(),
                'isRead': 'false',
              });
              Navigator.pop(dialogContext);
              DemoStore.addAudit(
                  'Phát thông báo bảo trì in-app khu vực $location',
                  widget.authorName);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                      'Đã phát thông báo in-app tới sinh viên tại: $location (chưa gửi push notification).'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF16A34A),
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Phát thông báo'),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController();
    final impactController = TextEditingController();
    // Lưu messenger trước khi mở dialog
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm lịch bảo trì mới',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        labelText: 'Tên công việc bảo trì')),
                const SizedBox(height: 10),
                TextField(
                    controller: locationController,
                    decoration:
                        const InputDecoration(labelText: 'Vị trí / Tòa nhà')),
                const SizedBox(height: 10),
                TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                        labelText: 'Thời gian thực hiện')),
                const SizedBox(height: 10),
                TextField(
                    controller: impactController,
                    decoration: const InputDecoration(
                        labelText: 'Ảnh hưởng (VD: Cắt nước 2 giờ)')),
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
              if (titleController.text.isEmpty) return;
              final newTitle = titleController.text.trim();
              setState(() {
                maintenanceSchedules.insert(0, {
                  'id': DemoStore.nextId('BT'),
                  'title': newTitle,
                  'location': locationController.text.trim().isEmpty
                      ? 'Toàn KTX'
                      : locationController.text.trim(),
                  'time': timeController.text.trim().isEmpty
                      ? '08:00 - 12:00'
                      : timeController.text.trim(),
                  'type': 'Hệ thống điện',
                  'status': 'Sắp diễn ra',
                  'impact': impactController.text.trim().isEmpty
                      ? 'Không gián đoạn'
                      : impactController.text.trim(),
                });
              });
              Navigator.pop(dialogContext);
              messenger.showSnackBar(
                const SnackBar(
                    content: Text('Đã thêm lịch bảo trì mới thành công.'),
                    behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Lưu lịch bảo trì'),
          ),
        ],
      ),
    );
  }
}
