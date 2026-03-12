import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  runApp(const VirtualJaapApp());
}

class VirtualJaapApp extends StatelessWidget {
  const VirtualJaapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Jaap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const JaapScreen(),
    );
  }
}

class JaapScreen extends StatefulWidget {
  const JaapScreen({super.key});

  @override
  State<JaapScreen> createState() => _JaapScreenState();
}

class _JaapScreenState extends State<JaapScreen> {
  int _beadCount = 0;
  int _malaCount = 0;
  bool _hasStarted = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playChant() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // We are trying to play a local asset. It will error gracefully if it doesn't exist yet!
      await _audioPlayer.play(AssetSource('audio/chant.mp3'));
    } catch (e) {
      debugPrint("Audio play failed: $e");
    }
  }

  Future<void> _stopChant() async {
    await _audioPlayer.stop();
  }

  void _increment() {
    HapticFeedback.lightImpact(); // May not work on web but fine for mobile
    setState(() {
      if (!_hasStarted) {
        _hasStarted = true;
        _playChant();
      }
      _beadCount++;
      if (_beadCount == 108) {
        // Haptic feedback for mala completion
        HapticFeedback.heavyImpact();
        _malaCount++;
        _stopChant();
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Jaap Completed!'),
            ],
          ),
          content: const Text(
            'Congratulations on completing 1 full Mala (108 beads). May peace be with you.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.grey, fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _beadCount = 0;
                  _hasStarted = false;
                });
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Play Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _beadCount = 0;
                  _hasStarted = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Counter'),
          content: const Text('Are you sure you want to reset your Jaap count?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () {
                setState(() {
                  _stopChant();
                  _beadCount = 0;
                  _malaCount = 0;
                  _hasStarted = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Virtual Jaap', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reset,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Ensures the entire screen is tappable even on transparent areas
        onTap: _increment,
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // Prevent scrolling from interfering with taps
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mala info
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCountBox('Beads', '$_beadCount / 108'),
                          _buildCountBox('Malas', '$_malaCount'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Mala visual (now containing the counter inside)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: math.min(size.width * 0.9, 350),
                          height: math.min(size.width * 0.9, 350),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: CustomPaint(
                            painter: MalaPainter(beadCount: _beadCount),
                          ),
                        ),
                        // The central count number display
                        if (_hasStarted)
                          Container(
                            width: math.min(size.width * 0.4, 150),
                            height: math.min(size.width * 0.4, 150),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepOrange.withOpacity(0.1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_beadCount',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 64 : 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Instructions text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Tap anywhere on the screen to chant.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange[800],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // "Tap anywhere to start" Overlay Animation
            if (!_hasStarted)
              Positioned.fill(
                child: Container(
                  color: Colors.orange[50]?.withOpacity(0.8), // semi-transparent backdrop
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.2),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      onEnd: () {
                         // We can't easily loop TweenAnimationBuilder without a controller, 
                         // but for simplicity we rely on the user tapping away the overlay.
                         // For a true infinite pulse, an AnimationController in initState is better.
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Tap anywhere to start',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[800],
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              color: Colors.deepOrange[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MalaPainter extends CustomPainter {
  final int beadCount;

  MalaPainter({required this.beadCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 24; // Padding from edge

    const totalBeads = 108;
    const beadRadius = 6.0;

    final paintCompleted = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;

    final paintRemaining = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;
      
    // Draw string connecting beads behind the beads
    final stringPaint = Paint()
      ..color = Colors.orange[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    canvas.drawCircle(center, radius, stringPaint);

    for (int i = 0; i < totalBeads; i++) {
        // Start from the top (-pi/2) and go clockwise
      final angle = -math.pi / 2 + (i * 2 * math.pi / totalBeads);
      
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      // Determine which paint to use
      final currentPaint = i < beadCount ? paintCompleted : paintRemaining;

      // Make the first bead slightly larger to represent the guru bead / start
      final currentRadius = (i == 0) ? beadRadius * 1.5 : beadRadius;

      // Add a small shadow to completed beads
      if (i < beadCount) {
        final shadowPaint = Paint()
          ..color = Colors.deepOrange.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        canvas.drawCircle(Offset(x, y), currentRadius + 2, shadowPaint);
      }

      canvas.drawCircle(Offset(x, y), currentRadius, currentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MalaPainter oldDelegate) {
    return oldDelegate.beadCount != beadCount;
  }
}
