import 'dart:io';

/// Represents a Piper TTS model and its associated files.
class PiperModel {
  /// The path to the .onnx model file.
  final String modelPath;

  /// The path to the tokens.txt file.
  final String tokensPath;


  /// The path to the espeak-ng-data directory (optional for character-based models).
  final String? espeakDataPath;

  /// The speaker ID (default is 0).
  final int speakerId;

  /// The synthesis speed (default is 1.0).
  final double speed;

  PiperModel({
    required this.modelPath,
    required this.tokensPath,
    this.espeakDataPath,
    this.speakerId = 0,
    this.speed = 1.0,
  });

  bool get exists =>
      File(modelPath).existsSync() &&
      File(tokensPath).existsSync() &&
      (espeakDataPath == null || Directory(espeakDataPath!).existsSync());
}
