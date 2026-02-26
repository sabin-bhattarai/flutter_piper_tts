import 'package:flutter_test/flutter_test.dart';
import 'package:piper_tts/piper_tts.dart';
import 'package:piper_tts/piper_tts_platform_interface.dart';
import 'package:piper_tts/piper_tts_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPiperTtsPlatform
    with MockPlatformInterfaceMixin
    implements PiperTtsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PiperTtsPlatform initialPlatform = PiperTtsPlatform.instance;

  test('$MethodChannelPiperTts is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPiperTts>());
  });

  test('getPlatformVersion', () async {
    PiperTts piperTtsPlugin = PiperTts();
    MockPiperTtsPlatform fakePlatform = MockPiperTtsPlatform();
    PiperTtsPlatform.instance = fakePlatform;

    expect(await piperTtsPlugin.getPlatformVersion(), '42');
  });
}
