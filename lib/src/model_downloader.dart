import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'piper_model.dart';

class ModelDownloader {
  static const String _baseUrl = 'https://huggingface.co/csukuangfj';
  static const String _nepaliModelRepo =
      'https://github.com/sabin-bhattarai/compressed_piper_model/raw/main/ne_NP-google-x_low_int8.onnx';
  static const String _espeakUrl = 'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/espeak-ng-data.tar.bz2';

  Future<String> downloadEspeakData() async {
    final docDir = await getApplicationDocumentsDirectory();
    final espeakDir = Directory(p.join(docDir.path, 'espeak-ng-data'));
    
    if (espeakDir.existsSync()) {
      return espeakDir.path;
    }

    print('Downloading espeak-ng-data...');
    final response = await http.get(Uri.parse(_espeakUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download espeak-ng-data');
    }

    final bytes = response.bodyBytes;
    final archive = BZip2Decoder().decodeBytes(bytes);
    final tarArchive = TarDecoder().decodeBytes(archive);

    for (final file in tarArchive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(p.join(docDir.path, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(p.join(docDir.path, filename)).createSync(recursive: true);
      }
    }

    return espeakDir.path;
  }

  /// Downloads a Piper model for the given [language].
  /// [language] can be 'en' or 'ne'.
  Future<PiperModel> downloadModel(String language) async {
    final docDir = await getApplicationDocumentsDirectory();
    final espeakPath = await downloadEspeakData();

    String repoName;
    String modelFileName;

    if (language == 'en') {
      repoName = 'vits-piper-en_US-lessac-medium';
      modelFileName = 'en_US-lessac-medium.onnx';
    } else if (language == 'ne') {
      repoName = 'vits-piper-ne_NP-google-x_low';
      modelFileName = 'ne_NP-google-x_low.onnx';
    } else {
      throw ArgumentError('Unsupported language: $language');
    }

    final modelDir = Directory(p.join(docDir.path, repoName));
    if (!modelDir.existsSync()) {
      modelDir.createSync(recursive: true);
    }

    final modelPath = p.join(modelDir.path, modelFileName);
    final tokensPath = p.join(modelDir.path, 'tokens.txt');

    if (language == 'ne') {
      await _downloadFile(_nepaliModelRepo, modelPath);
    } else {
      await _downloadFile(
        '$_baseUrl/$repoName/resolve/main/$modelFileName',
        modelPath,
      );
    }
    await _downloadFile(
      '$_baseUrl/$repoName/resolve/main/tokens.txt',
      tokensPath,
    );

    return PiperModel(
      modelPath: modelPath,
      tokensPath: tokensPath,
      espeakDataPath: espeakPath,
    );
  }

  Future<void> _downloadFile(String url, String savePath) async {
    final file = File(savePath);
    if (file.existsSync()) return;

    print('Downloading $url...');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download file: $url (Status: ${response.statusCode})',
      );
    }
    await file.writeAsBytes(response.bodyBytes);
  }
}
