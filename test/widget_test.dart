import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dengim/main.dart';

void main() {
  testWidgets('DengimApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DengimApp());
    
    // Ana uygulama yüklendiğini kontrol et
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
