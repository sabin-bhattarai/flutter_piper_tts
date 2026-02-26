import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'piper_tts_method_channel.dart';

abstract class PiperTtsPlatform extends PlatformInterface {
  /// Constructs a PiperTtsPlatform.
  PiperTtsPlatform() : super(token: _token);

  static final Object _token = Object();

  static PiperTtsPlatform _instance = MethodChannelPiperTts();

  /// The default instance of [PiperTtsPlatform] to use.
  ///
  /// Defaults to [MethodChannelPiperTts].
  static PiperTtsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PiperTtsPlatform] when
  /// they register themselves.
  static set instance(PiperTtsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
