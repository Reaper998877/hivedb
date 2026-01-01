import 'package:flutter/material.dart';
import 'package:hive_db/view/person_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fadeAnimation, _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800), // 1.8 sec
      vsync:
          this, // Avoids unnecessary CPU/GPU usage (uses Ticker from the State class).
    );

    // opacity 0 -> 1
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    ); // Curves.easeIn = starts slow, ends fast.

    // Scale from 0.5x to 1.0x (small → full size).
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    ); // Curve easeOutBack creates a bounce-like overshoot at the end.

    // Offset(0, 0.5) means the widget starts slightly downwards.
    // It slides upward to its original position.
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        ); // Curves.easeOut = fast at beginning, slow at end.

    _controller.forward(); // Start animation

    // When animation is completed navigate to next screen.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PersonScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisAlignment: .center,
                children: [
                  // Glowing logo + scale animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Image.asset(
                        'res/icon/logo-transparent.png',
                        width: MediaQuery.sizeOf(context).width * 0.42,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // text slide animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      'Hive DB Tutorial',
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'amaranth',
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
