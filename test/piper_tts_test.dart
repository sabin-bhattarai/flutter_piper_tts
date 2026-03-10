import 'package:flutter_test/flutter_test.dart';
import 'package:piper_tts/piper_tts.dart';

void main() {
  test('PiperTts can be instantiated', () {
    final piperTts = PiperTts();
    expect(piperTts, isNotNull);
  });

  test('ModelDownloader can be instantiated', () {
    final downloader = ModelDownloader();
    expect(downloader, isNotNull);
  });
}
