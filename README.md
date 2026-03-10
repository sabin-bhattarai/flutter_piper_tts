# Piper TTS for Flutter

A high-performance, offline Text-to-Speech (TTS) plugin for Flutter that uses Piper models via `sherpa-onnx`. This package provides high-quality speech synthesis for English and Nepali with a small footprint.

## Features

- **Offline Support**: Synthesize speech without an internet connection.
- **High Quality**: Uses neural Piper models for natural-sounding speech.
- **Multi-language**: Built-in support for English (US) and Nepali.
- **Optimized Performance**: Parallel model/token downloads and efficient memory management.
- **Compressed Models**: Supports INT8 quantized models for reduced app size.

## Getting Started

### Installation

Add `piper_tts` to your `pubspec.yaml`:

```yaml
dependencies:
  piper_tts:
    path: ../piper_tts # Or use the git/pub.dev path
```

### Android Setup

Ensure your `minSdkVersion` is at least **21** in `android/app/build.gradle`.

### iOS Setup

Add the following to your `Podfile` if not already present:

```ruby
platform :ios, '13.0'
```

## Usage

### 1. Initialize and Download Models

The `ModelDownloader` handles fetching the necessary models and phonemization data (`espeak-ng-data`).

```dart
import 'package:piper_tts/piper_tts.dart';

final downloader = ModelDownloader();
final piper = PiperTts();

// Download and load Nepali model
final model = await downloader.downloadModel('ne');
await piper.loadModel(model);
```

### 2. Synthesize Speech

You can synthesize text to raw PCM bytes or a WAV file.

```dart
// Synthesize to PCM (Int16)
final Uint8List pcm = await piper.synthesize("नमस्ते, म पाइपर टीटीएस हुँ।");

// Synthesize directly to WAV (ready for playback)
final Uint8List wav = await piper.synthesizeWav("नमस्ते, म पाइपर टीटीएस हुँ।");
```

### 3. Play Audio

Use a package like `audioplayers` to play the generated WAV data.

```dart
import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();
await player.play(BytesSource(wav));
```

## Optimization Tips

- **Parallelism**: The `ModelDownloader` uses parallel streams to fetch model components, reducing wait times.
- **Cleanup**: Call `piper.dispose()` when the TTS engine is no longer needed to free up native memory.

## Troubleshooting

- **Metadata Crash**: If you encounter `'sample_rate' does not exist in the metadata`, ensure your ONNX model has a companion `.json` configuration file in the same directory, or use the `piper` configuration field (default in this package).
- **Phonemization Error**: Ensure `downloadEspeakData()` has completed successfully, as Piper requires `espeak-ng-data` for high-quality synthesis.

## License

This project is licensed under the MIT License.
