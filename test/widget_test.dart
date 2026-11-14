import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/auth/presentation/splash.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('SplashScreen smoke test displays OS CLUB branding', (WidgetTester tester) async {
    final auth = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: Sizer(
          builder: (context, orientation, deviceType) => const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      ),
    );

    expect(find.text('OS'), findsOneWidget);
    expect(find.text('CLUB'), findsOneWidget);

    // Advance fake timer to clear the 2-second navigation timer in SplashScreen
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
