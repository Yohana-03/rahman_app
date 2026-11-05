import 'package:finalrahman/app.dart';
import 'package:finalrahman/app_dependencies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash stays up for 3 seconds before sign in', (tester) async {
    await tester.pumpWidget(RahmanApp(dependencies: AppDependencies.memory()));

    expect(find.text('Rahman'), findsOneWidget);
    expect(find.text('Parent Portal'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Parent Portal'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Sign in'), findsNWidgets(2));
    expect(find.text('Parent Portal'), findsNothing);
  });
}
