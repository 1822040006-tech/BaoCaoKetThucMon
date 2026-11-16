import 'package:dormhub_flutter/data/demo_store.dart';
import 'package:dormhub_flutter/pages/home_page.dart';
import 'package:dormhub_flutter/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('technician pages open from the sidebar', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: HomePage(
        role: 'Kỹ thuật viên',
        email: 'technician@university.com',
        displayName: 'Kỹ thuật viên thử nghiệm',
        loginPageBuilder: (_) => const Scaffold(),
      ),
    ));
    expect(tester.takeException(), isNull);

    for (final page in [
      'Yêu cầu sửa chữa',
      'Lịch bảo trì',
      'Quản lý vật tư',
      'Báo cáo',
    ]) {
      final item = find.descendant(
        of: find.byType(AppSidebar),
        matching: find.text(page),
      );
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Failed to open $page');
    }
  });

  testWidgets('technician pages open from the mobile drawer', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: HomePage(
        role: 'Kỹ thuật viên',
        email: 'technician@university.com',
        displayName: 'Kỹ thuật viên thử nghiệm',
        loginPageBuilder: (_) => const Scaffold(),
      ),
    ));
    expect(tester.takeException(), isNull);

    for (final page in [
      'Yêu cầu sửa chữa',
      'Lịch bảo trì',
      'Quản lý vật tư',
      'Báo cáo',
    ]) {
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(AppSidebar),
        matching: find.text(page),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Failed to open $page');
    }
  });

  testWidgets('technician actions respond without layout errors', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repair = DemoStore.repairs.first;
    final originalRepair = Map<String, String>.from(repair);
    addTearDown(() {
      repair
        ..clear()
        ..addAll(originalRepair);
    });

    await tester.pumpWidget(MaterialApp(
      home: HomePage(
        role: 'Kỹ thuật viên',
        email: 'technician@university.com',
        displayName: 'Kỹ thuật viên thử nghiệm',
        loginPageBuilder: (_) => const Scaffold(),
      ),
    ));

    Future<void> openPage(String page) async {
      await tester.tap(find.descendant(
        of: find.byType(AppSidebar),
        matching: find.text(page),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await openPage('Yêu cầu sửa chữa');
    final claimButton = find.text('Nhận việc').first;
    await tester.ensureVisible(claimButton);
    await tester.tap(claimButton);
    await tester.pumpAndSettle();
    expect(repair['status'], 'Đang xử lý');
    expect(tester.takeException(), isNull);

    for (final action in [
      ('Lịch bảo trì', 'Thêm lịch bảo trì'),
      ('Quản lý vật tư', 'Nhập vật tư'),
      ('Báo cáo', 'Lập báo cáo mới'),
    ]) {
      await openPage(action.$1);
      await tester.tap(find.text(action.$2));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Hủy').last);
      await tester.pumpAndSettle();
    }
  });
}
