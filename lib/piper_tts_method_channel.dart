import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'piper_tts_platform_interface.dart';

/// An implementation of [PiperTtsPlatform] that uses method channels.
class MethodChannelPiperTts extends PiperTtsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('piper_tts');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
