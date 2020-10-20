import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sourcepoint_cmp/sourcepoint_cmp.dart';

void main() {
  const MethodChannel channel = MethodChannel('sourcepoint_cmp');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
