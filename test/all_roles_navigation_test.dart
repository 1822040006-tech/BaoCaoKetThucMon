import 'package:dormhub_flutter/config/role_menus.dart';
import 'package:dormhub_flutter/pages/home_page.dart';
import 'package:dormhub_flutter/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const accounts = [
    ('Sinh viên', '240001@university.com'),
    ('Quản lý KTX', 'manager@university.com'),
    ('Kỹ thuật viên', 'technician@university.com'),
    ('Quản trị viên', 'admin@university.com'),
  ];

  for (final compact in [false, true]) {
    for (final account in accounts) {
      testWidgets(
        '${account.$1} opens every page on ${compact ? 'phone' : 'desktop'}',
        (tester) async {
          tester.view.physicalSize =
              compact ? const Size(412, 915) : const Size(1440, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(MaterialApp(
            home: HomePage(
              role: account.$1,
              email: account.$2,
              displayName: 'Tài khoản thử nghiệm',
              studentCode: account.$1 == 'Sinh viên' ? '240001' : null,
              loginPageBuilder: (_) => const Scaffold(),
            ),
          ));
          expect(tester.takeException(), isNull, reason: 'Initial dashboard');

          for (final page in RoleMenus.getMenuForRole(account.$1)) {
            if (compact) {
              await tester.tap(find.byIcon(Icons.menu));
              await tester.pumpAndSettle();
            }
            await tester.tap(find.descendant(
              of: find.byType(AppSidebar),
              matching: find.text(page),
            ));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull,
                reason: '${account.$1}: $page');
          }
        },
      );
    }
  }
}
