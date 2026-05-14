import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const IfWishesPrankApp());
}

class IfWishesPrankApp extends StatelessWidget {
  const IfWishesPrankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'If Wishes Could Kill',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(primary: Colors.red),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _videoFile;
  Timer? _timer;
  Duration _countdown = const Duration(hours: 24);
  bool _isRunning = false;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked!= null) {
      setState(() {
        _videoFile = File(picked.path);
        _startCountdown();
      });
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdown = const Duration(hours: 24);
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _isRunning = false;
          _countdown = Duration.zero;
        });
        _showDoneDialog();
      } else {
        setState(() {
          _countdown = _countdown - const Duration(seconds: 1);
        });
      }
    });
  }

  void _showDoneDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Done', style: TextStyle(color: Colors.red)),
        content: const Text(
          'Time\'s up. Nothing happened 😏\nIt was just a prank.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _videoFile = null;
              });
            },
            child: const Text('LOL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IF WISHES COULD KILL'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _videoFile == null
            ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Upload a video to start the curse',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Video'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '⚠️ This is a prank. Nothing will be deleted.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_top, size: 80, color: Colors.red),
                    const SizedBox(height: 20),
                    const Text(
                      'Curse Activated',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDuration(_countdown),
                      style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isRunning
                        ? 'The wish will be executed in...'
                          : 'It\'s over.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        _timer?.cancel();
                        setState(() {
                          _videoFile = null;
                          _isRunning = false;
                        });
                      },
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
