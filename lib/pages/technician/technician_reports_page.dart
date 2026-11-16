import 'package:flutter/material.dart';
import '../../data/demo_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class TechnicianReportsPageWidget extends StatefulWidget {
  final String authorName;
  const TechnicianReportsPageWidget(
      {super.key, this.authorName = 'Kỹ thuật viên'});

  @override
  State<TechnicianReportsPageWidget> createState() =>
      _TechnicianReportsPageWidgetState();
}

class _TechnicianReportsPageWidgetState
    extends State<TechnicianReportsPageWidget> {
  List<Map<String, String>> get reportsList => DemoStore.reports;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Báo cáo Kỹ thuật & Sửa chữa',
          subtitle:
              'Tổng hợp chỉ số khắc phục sự cố, vật tư tiêu hao và gửi báo cáo công việc.',
          action: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1D61F2),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _showCreateReportDialog,
            icon: const Icon(Icons.post_add_rounded, size: 18),
            label: const Text('Lập báo cáo mới',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width < 750 ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: MediaQuery.sizeOf(context).width < 750 ? 1.0 : 1.6,
          children: [
            _buildKpiCard('Sự cố đã hoàn thành', '42/45', 'Tỷ lệ 93.3%',
                Icons.check_circle_outline, const Color(0xFF16A34A)),
            _buildKpiCard('Thời gian xử lý TB', '2.4 giờ', 'Mục tiêu < 4h',
                Icons.timer_outlined, const Color(0xFF1D61F2)),
            _buildKpiCard(
                'Vật tư đã sử dụng',
                '38 món',
                'Chủ yếu: Đèn, Vòi nước',
                Icons.inventory_2_outlined,
                const Color(0xFFD97706)),
            _buildKpiCard('Bảo trì định kỳ', '100%', '4/4 lượt tháng này',
                Icons.build_circle_outlined, const Color(0xFF9333EA)),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lịch sử Báo cáo đã lập',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 45,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 60,
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(
                        label: Text('MÃ BÁO CÁO',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B)))),
                    DataColumn(
                        label: Text('TIÊU ĐỀ BÁO CÁO',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B)))),
                    DataColumn(
                        label: Text('LOẠI BÁO CÁO',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B)))),
                    DataColumn(
                        label: Text('NGÀY LẬP',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B)))),
                    DataColumn(
                        label: Text('NGƯỜI LẬP',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B)))),
                    DataColumn(
                        label: Text('TRẠNG THÁI',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B)))),
                  ],
                  rows: reportsList.map((rep) {
                    final isApproved = rep['status'] == 'Đã duyệt';
                    return DataRow(cells: [
                      DataCell(Text(rep['id']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12))),
                      DataCell(Text(rep['title']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13))),
                      DataCell(Text(rep['type']!,
                          style: const TextStyle(fontSize: 12))),
                      DataCell(Text(rep['date']!,
                          style: const TextStyle(fontSize: 12))),
                      DataCell(Text(rep['author']!,
                          style: const TextStyle(fontSize: 12))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(rep['status']!,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isApproved
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFD97706))),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
      String title, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        ],
      ),
    );
  }

  void _showCreateReportDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String reportType = 'Báo cáo tháng';
    // Lưu messenger trước khi mở dialog để tránh dùng context đã unmount
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Tạo Báo cáo Kỹ thuật mới',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: reportType,
                    decoration:
                        const InputDecoration(labelText: 'Loại báo cáo'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Báo cáo tháng', child: Text('Báo cáo tháng')),
                      DropdownMenuItem(
                          value: 'Đề xuất vật tư',
                          child: Text('Đề xuất mua / Thay thế vật tư')),
                      DropdownMenuItem(
                          value: 'Bảo trì định kỳ',
                          child: Text('Báo cáo bảo trì định kỳ')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => reportType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(labelText: 'Tên báo cáo')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: 'Nội dung chi tiết báo cáo')),
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
                final newContent = contentController.text.trim();
                final finalType = reportType;
                setState(() {
                  reportsList.insert(0, {
                    'id': DemoStore.nextId('BC-KT'),
                    'title': newTitle,
                    'type': finalType,
                    'content': newContent,
                    'date': DemoStore.dateToday(),
                    'author': widget.authorName,
                    'status': 'Chờ xem xét',
                  });
                });
                Navigator.pop(dialogContext);
                DemoStore.addAudit(
                    'Gửi báo cáo kỹ thuật: $newTitle', widget.authorName);
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Đã gửi báo cáo kỹ thuật cho Quản lý KTX thành công.'),
                      behavior: SnackBarBehavior.floating),
                );
              },
              child: const Text('Gửi báo cáo'),
            ),
          ],
        ),
      ),
    );
  }
}
