// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/sound_manager.dart';
import 'main_menu.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _fadeController;
  final SoundManager sound = SoundManager();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverseDuration: Duration.zero,
    );

    _controller =
        VideoPlayerController.asset('assets/videos/onephone-init-screen.mp4')
          ..initialize().then((_) {
            _controller.setVolume(kIsWeb ? 0.0 : 1.0);
            _controller.play();
            _controller.setLooping(false);

            setState(() {});

            precacheImage(const AssetImage('assets/images/onephone-logo.png'), context);
            sound.preload('sounds/tap.mp3');
          });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration && mounted) {
        _fadeController.forward().then((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainMenuScreen()),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? SizedBox(
                    width: screenSize.width,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          FadeTransition(
            opacity: _fadeController,
            child: Container(color: Colors.black),
          ),
        ],
        ),
      ),
    );
  }
}
