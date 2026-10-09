import 'package:flutter_test/flutter_test.dart';
import 'package:mecity_marketplace/buyer_app/buyer_main.dart';

void main() {
  testWidgets('Mecity Marketplace smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MecityBuyerApp());
    expect(find.byType(MecityBuyerApp), findsOneWidget);
  });
}
