import 'dart:async';
import 'dart:typed_data';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'piper_model.dart';

/// The main class for Piper TTS operations.
class PiperTts {
  sherpa.OfflineTts? _tts;
  PiperModel? _currentModel;

  /// Initializes the TTS engine with the provided [model].
  Future<void> loadModel(PiperModel model) async {
    sherpa.initBindings();
    
    if (_currentModel?.modelPath == model.modelPath && _tts != null) {
      return;
    }

    final vitsConfig = sherpa.OfflineTtsVitsModelConfig(
      model: model.modelPath,
      tokens: model.tokensPath,
      dataDir: model.espeakDataPath ?? '',
      noiseScale: 0.667,
      noiseScaleW: 0.8,
      lengthScale: 1.0 / model.speed,
    );

    final ttsConfig = sherpa.OfflineTtsConfig(
      model: sherpa.OfflineTtsModelConfig(
        vits: vitsConfig,
        numThreads: 1,
        debug: false,
        provider: 'cpu',
      ),
    );

    _tts = sherpa.OfflineTts(ttsConfig);
    _currentModel = model;
  }

  /// Synthesizes [text] into PCM 16-bit audio data.
  /// 
  /// Returns a [Uint8List] containing the raw audio bytes.
  Future<Uint8List> synthesize(String text) async {
    if (_tts == null) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    final audio = _tts!.generate(
      text: text,
      sid: _currentModel?.speakerId ?? 0,
      speed: _currentModel?.speed ?? 1.0,
    );

    // Sherpa-onnx returns Float32List, we convert to Int16 PCM (WAV compatible)
    return _float32ToInt16Bytes(audio.samples);
  }

  /// Returns the sample rate of the loaded model.
  int get sampleRate => _tts?.sampleRate ?? 22050;

  Uint8List _float32ToInt16Bytes(Float32List samples) {
    final int16List = Int16List(samples.length);
    for (var i = 0; i < samples.length; i++) {
      // Clamp and scale to Int16
      var sample = samples[i];
      if (sample > 1.0) sample = 1.0;
      if (sample < -1.0) sample = -1.0;
      int16List[i] = (sample * 32767).toInt();
    }
    return int16List.buffer.asUint8List();
  }

  /// Synthesizes [text] and returns a WAV file format [Uint8List].
  Future<Uint8List> synthesizeWav(String text) async {
    final pcm = await synthesize(text);
    final header = _getWavHeader(pcm.length, sampleRate);
    final wav = Uint8List(header.length + pcm.length);
    wav.setAll(0, header);
    wav.setAll(header.length, pcm);
    return wav;
  }

  Uint8List _getWavHeader(int pcmLength, int sampleRate) {
    final header = ByteData(44);
    
    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, 36 + pcmLength, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    
    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6d); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Subchunk1Size
    header.setUint16(20, 1, Endian.little); // AudioFormat (PCM)
    header.setUint16(22, 1, Endian.little); // NumChannels (Mono)
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    header.setUint16(32, 2, Endian.little); // BlockAlign
    header.setUint16(34, 16, Endian.little); // BitsPerSample
    
    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, pcmLength, Endian.little);
    
    return header.buffer.asUint8List();
  }

  /// Disposes the TTS engine.
  void dispose() {
    _tts?.free();
    _tts = null;
    _currentModel = null;
  }
}
