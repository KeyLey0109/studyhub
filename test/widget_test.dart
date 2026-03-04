import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyhub/main.dart';
import 'package:studyhub/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('Kiem tra hien thi trang Login', (WidgetTester tester) async {
    // 1. Chạy app
    await tester.pumpWidget(const StudyHubApp());

    // 2. Kiem tra xem co chu StudyHub tren man hinh khong
    expect(find.text('StudyHub'), findsOneWidget);

    // 3. Kiem tra xem co nut DANG NHAP khong
    expect(find.byType(ElevatedButton), findsOneWidget);

    // 4. Tim kiem LoginPage trong cay Widget
    expect(find.byType(LoginPage), findsOneWidget);
  });
}