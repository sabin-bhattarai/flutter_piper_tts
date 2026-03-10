import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:piper_tts/piper_tts.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PiperTts instantiation test', (WidgetTester tester) async {
    final PiperTts plugin = PiperTts();
    expect(plugin, isNotNull);
  });
}
