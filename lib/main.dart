import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/generative_ai_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuroraPage(),
    );
  }
}

class AuroraPage extends StatefulWidget {
  const AuroraPage({super.key});

  @override
  State<AuroraPage> createState() => _AuroraPageState();
}

class _AuroraPageState extends State<AuroraPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  FragmentShader? _shader;
  final SpeechToText _speechToText = SpeechToText();
  final GenerativeAiService _aiService = GenerativeAiService();
  bool _speechEnabled = false;
  String _lastWords = "";
  String _aiResponse = "";
  bool _isProcessing = false;
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _loadShader();
    _initSpeech();
  }

  void _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechEnabled = await _speechToText.initialize();
    } else {
      debugPrint("Microphone permission denied");
    }
    setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) return;
    _lastWords = "";
    _aiResponse = "";
    await _speechToText.listen(
      onResult: _onSpeechResult,
      onSoundLevelChange: (level) {
        setState(() {
          _soundLevel = level;
        });
      },
    );
    setState(() {});
  }

  void _stopListening() async {
    if (!_speechEnabled) return;
    await _speechToText.stop();
    setState(() {
      _isProcessing = true;
    });
    if (_lastWords.isNotEmpty) {
      final response = await _aiService.generateContent(_lastWords);
      setState(() {
        _aiResponse = response;
        _isProcessing = false;
      });
    }
     setState(() {
        _isProcessing = false;
      });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  void _loadShader() async {
    try {
      final program = await FragmentProgram.fromAsset('assets/shaders/aurora.frag');
      setState(() {
        _shader = program.fragmentShader();
      });
    } catch (e) {
      debugPrint('Error loading shader: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Center(
                child: _shader == null
                    ? const CircularProgressIndicator()
                    : AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return ClipOval(
                            child: CustomPaint(
                              size: const Size(250, 250),
                              painter: AuroraPainter(
                                _shader!,
                                _controller.value * 10,
                                _speechToText.isListening ? _soundLevel * 2.0 + 0.5 : 0.5,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                     Container(
                       padding: const EdgeInsets.all(16),
                       child: Text(
                         _lastWords,
                         style: const TextStyle(color: Colors.white70, fontSize: 18, fontStyle: FontStyle.italic),
                         textAlign: TextAlign.center,
                       ),
                     ),
                    if (_isProcessing)
                      const CircularProgressIndicator(),
                    if (_aiResponse.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Text(
                          _aiResponse,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ), 
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        backgroundColor: _speechToText.isListening ? Colors.red : Theme.of(context).colorScheme.secondary,
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}

class AuroraPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  final double intensity;

  AuroraPainter(this.shader, this.time, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, time);
    shader.setFloat(1, size.width);
    shader.setFloat(2, size.height);
    shader.setFloat(3, intensity);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) {
    return time != oldDelegate.time || intensity != oldDelegate.intensity;
  }
}
