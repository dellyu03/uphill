import 'dart:async';
import 'package:flutter/material.dart';

class RoutineInProgressScreen extends StatefulWidget {
  final String title;

  const RoutineInProgressScreen({super.key, required this.title});

  @override
  State<RoutineInProgressScreen> createState() =>
      _RoutineInProgressScreenState();
}

class _RoutineInProgressScreenState extends State<RoutineInProgressScreen> {
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    final int seconds = (milliseconds / 1000).truncate();
    final int minutes = (seconds / 60).truncate();
    final int hours = (minutes / 60).truncate();

    final String hoursStr = (hours % 60).toString().padLeft(2, '0');
    final String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    final String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '루틴 진행 중',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            Text(
              _formatTime(_stopwatch.elapsedMilliseconds),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                  label: _stopwatch.isRunning ? '일시정지' : '재개',
                  onTap: () {
                    setState(() {
                      if (_stopwatch.isRunning) {
                        _stopwatch.stop();
                      } else {
                        _stopwatch.start();
                      }
                    });
                  },
                ),
                const SizedBox(width: 48),
                _buildControlButton(
                  icon: Icons.stop,
                  label: '종료',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 40, color: color),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
