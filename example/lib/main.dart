import 'dart:io';
import 'package:flutter/material.dart';
import 'package:piper_tts/piper_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piper TTS Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const TtsDemo(),
    );
  }
}

class TtsDemo extends StatefulWidget {
  const TtsDemo({super.key});

  @override
  State<TtsDemo> createState() => _TtsDemoState();
}

class _TtsDemoState extends State<TtsDemo> {
  final PiperTts _piperTts = PiperTts();
  final ModelDownloader _downloader = ModelDownloader();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  final TextEditingController _textController = TextEditingController(
    text: "नमस्ते! यो पाइपर टीटीएस नेपालीमा बोल्दै छ। कस्तो लाग्यो यो आवाज?",
  );

  bool _isLoading = false;
  String _status = "Ready";
  String _selectedLanguage = "ne"; // 'en' or 'ne'

  @override
  void dispose() {
    _piperTts.dispose();
    _audioPlayer.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _synthesizeAndPlay() async {
    setState(() {
      _isLoading = true;
      _status = "Loading model...";
    });

    try {
      // 1. Download/Install model if needed
      final model = await _downloader.downloadModel(_selectedLanguage);
      
      // 2. Load the model into the engine
      _status = "Initializing engine...";
      await _piperTts.loadModel(model);

      // 3. Synthesize text to WAV
      _status = "Synthesizing...";
      final wavData = await _piperTts.synthesizeWav(_textController.text);

      // 4. Save to temp file and play
      _status = "Playing...";
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, 'output.wav'));
      await tempFile.writeAsBytes(wavData);

      await _audioPlayer.play(DeviceFileSource(tempFile.path));
      
      setState(() {
        _status = "Success!";
      });
    } catch (e) {
      setState(() {
        _status = "Error: $e";
      });
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Piper TTS (Offline)')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Language: "),
                Radio<String>(
                  value: "en",
                  groupValue: _selectedLanguage,
                  onChanged: (v) => setState(() {
                    _selectedLanguage = v!;
                    _textController.text = "Hello! This is Piper TTS speaking in English.";
                  }),
                ),
                const Text("English"),
                Radio<String>(
                  value: "ne",
                  groupValue: _selectedLanguage,
                  onChanged: (v) => setState(() {
                    _selectedLanguage = v!;
                    _textController.text = "संख्या परीक्षण: ४५२४५२४५२ ,नेपाल एक सुन्दर देश हो। यहाँ हिमाल, पहाड र तराईका सुन्दर दृश्यहरू पाइन्छन्। सबैलाई धन्यवाद।";
                  }),
                ),
                const Text("Nepali"),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text to speak',
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _synthesizeAndPlay,
                icon: const Icon(Icons.volume_up),
                label: const Text('Synthesize & Play'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              "Status: $_status",
              style: TextStyle(
                color: _status.startsWith("Error") ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
