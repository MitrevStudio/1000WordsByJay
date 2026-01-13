import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Streak level determines the celebration intensity
enum StreakLevel {
  /// 5 correct answers - basic celebration
  bronze,

  /// 10 correct answers - enhanced celebration
  silver,

  /// 15+ correct answers - epic celebration
  gold,
}

class StreakOverlay extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final int streakCount;

  const StreakOverlay({
    super.key,
    required this.onAnimationComplete,
    this.streakCount = 5,
  });

  StreakLevel get level {
    if (streakCount >= 15) return StreakLevel.gold;
    if (streakCount >= 10) return StreakLevel.silver;
    return StreakLevel.bronze;
  }

  @override
  State<StreakOverlay> createState() => _StreakOverlayState();
}

class _StreakOverlayState extends State<StreakOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  late final AnimationController _sparkleController;
  late final AnimationController _waveController;

  late final Animation<double> _backgroundFade;
  late final Animation<double> _badgeScale;
  late final Animation<double> _badgeRotation;
  late final Animation<double> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _glowPulse;
  late final Animation<double> _exitFade;

  final List<_Confetti> _confetti = [];
  final List<_Sparkle> _sparkles = [];
  final List<_Ring> _rings = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _createParticles();
    _triggerHaptic();
    _startAnimations();
  }

  void _initializeAnimations() {
    final duration = _getDuration();

    _mainController = AnimationController(vsync: this, duration: duration);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Background fade in
    _backgroundFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
      ),
    );

    // Badge scale with elastic bounce
    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 30),
    ]).animate(_mainController);

    // Subtle rotation during entry
    _badgeRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.1,
          end: 0.05,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.05,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 30),
    ]).animate(_mainController);

    // Text slide up
    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Text fade in
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.45, curve: Curves.easeOut),
      ),
    );

    // Glow pulse
    _glowPulse = Tween<double>(begin: 0.5, end: 1.0).animate(_pulseController);

    // Exit fade
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeInCubic),
      ),
    );
  }

  Duration _getDuration() {
    switch (widget.level) {
      case StreakLevel.gold:
        return const Duration(milliseconds: 3500);
      case StreakLevel.silver:
        return const Duration(milliseconds: 3000);
      case StreakLevel.bronze:
        return const Duration(milliseconds: 2500);
    }
  }

  void _createParticles() {
    final particleCount = _getParticleCount();
    final colors = _getColors();

    // Create confetti
    for (int i = 0; i < particleCount; i++) {
      _confetti.add(
        _Confetti(
          startX: _random.nextDouble(),
          delay: _random.nextDouble() * 0.3,
          speed: 0.3 + _random.nextDouble() * 0.4,
          amplitude: 20 + _random.nextDouble() * 40,
          color: colors[_random.nextInt(colors.length)],
          size: 8 + _random.nextDouble() * 12,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 10,
          shape: _ConfettiShape
              .values[_random.nextInt(_ConfettiShape.values.length)],
        ),
      );
    }

    // Create sparkles around the badge
    final sparkleCount = widget.level == StreakLevel.gold
        ? 12
        : widget.level == StreakLevel.silver
        ? 8
        : 5;
    for (int i = 0; i < sparkleCount; i++) {
      final angle = (2 * pi / sparkleCount) * i;
      _sparkles.add(
        _Sparkle(
          angle: angle,
          distance: 100 + _random.nextDouble() * 50,
          size: 15 + _random.nextDouble() * 15,
          delay: _random.nextDouble() * 0.5,
          color: colors[_random.nextInt(colors.length)],
        ),
      );
    }

    // Create expanding rings
    final ringCount = widget.level == StreakLevel.gold
        ? 4
        : widget.level == StreakLevel.silver
        ? 3
        : 2;
    for (int i = 0; i < ringCount; i++) {
      _rings.add(
        _Ring(
          delay: i * 0.15,
          color: colors[i % colors.length].withOpacity(0.6),
        ),
      );
    }
  }

  int _getParticleCount() {
    switch (widget.level) {
      case StreakLevel.gold:
        return 80;
      case StreakLevel.silver:
        return 50;
      case StreakLevel.bronze:
        return 30;
    }
  }

  List<Color> _getColors() {
    switch (widget.level) {
      case StreakLevel.gold:
        return [
          const Color(0xFFFFD700), // Gold
          const Color(0xFFFFA500), // Orange
          const Color(0xFFFF6B35), // Coral
          const Color(0xFFFFE55C), // Light gold
          const Color(0xFFFF4500), // Red-orange
          Colors.white,
        ];
      case StreakLevel.silver:
        return [
          const Color(0xFFC0C0C0), // Silver
          const Color(0xFF87CEEB), // Sky blue
          const Color(0xFFE6E6FA), // Lavender
          const Color(0xFF00CED1), // Dark cyan
          Colors.white,
        ];
      case StreakLevel.bronze:
        return [
          const Color(0xFFCD7F32), // Bronze
          Colors.orange,
          Colors.amber,
          const Color(0xFFFF8C00), // Dark orange
        ];
    }
  }

  void _triggerHaptic() {
    switch (widget.level) {
      case StreakLevel.gold:
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 100), () {
          HapticFeedback.heavyImpact();
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          HapticFeedback.heavyImpact();
        });
        break;
      case StreakLevel.silver:
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 150), () {
          HapticFeedback.mediumImpact();
        });
        break;
      case StreakLevel.bronze:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  void _startAnimations() {
    _mainController.forward().then((_) {
      if (mounted) widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = _getColors();
    final primaryColor = colors.first;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _pulseController,
        _sparkleController,
        _waveController,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _exitFade.value,
          child: Stack(
            children: [
              // Animated gradient background
              _buildBackground(size, primaryColor),

              // Expanding rings
              ..._rings.map((ring) => _buildRing(ring, size)),

              // Confetti
              ..._confetti.map((c) => _buildConfetti(c, size)),

              // Center content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sparkles around badge
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ..._sparkles.map((s) => _buildSparkle(s)),
                          _buildBadge(primaryColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildText(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackground(Size size, Color primaryColor) {
    return Opacity(
      opacity: _backgroundFade.value,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              primaryColor.withOpacity(0.3),
              Colors.black.withOpacity(0.85),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRing(_Ring ring, Size size) {
    final ringProgress = ((_mainController.value - ring.delay) / 0.6).clamp(
      0.0,
      1.0,
    );
    if (ringProgress <= 0) return const SizedBox();

    final scale = Curves.easeOutCubic.transform(ringProgress);
    final opacity = (1.0 - ringProgress) * 0.8;

    return Positioned.fill(
      child: Center(
        child: Transform.scale(
          scale: scale * 2,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ring.color.withOpacity(opacity),
                width: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfetti(_Confetti confetti, Size size) {
    final progress = ((_mainController.value - confetti.delay) / confetti.speed)
        .clamp(0.0, 1.0);
    if (progress <= 0) return const SizedBox();

    final y = -50 + (size.height + 100) * Curves.easeIn.transform(progress);
    final x =
        confetti.startX * size.width +
        sin(progress * pi * 3) * confetti.amplitude;
    final rotation = confetti.rotation + progress * confetti.rotationSpeed;
    final opacity = progress < 0.8 ? 1.0 : (1.0 - (progress - 0.8) / 0.2);

    return Positioned(
      left: x - confetti.size / 2,
      top: y - confetti.size / 2,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation,
          child: _buildConfettiShape(confetti),
        ),
      ),
    );
  }

  Widget _buildConfettiShape(_Confetti confetti) {
    switch (confetti.shape) {
      case _ConfettiShape.circle:
        return Container(
          width: confetti.size,
          height: confetti.size,
          decoration: BoxDecoration(
            color: confetti.color,
            shape: BoxShape.circle,
          ),
        );
      case _ConfettiShape.square:
        return Container(
          width: confetti.size,
          height: confetti.size,
          decoration: BoxDecoration(
            color: confetti.color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case _ConfettiShape.rectangle:
        return Container(
          width: confetti.size,
          height: confetti.size * 0.4,
          decoration: BoxDecoration(
            color: confetti.color,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      case _ConfettiShape.star:
        return Icon(Icons.star, size: confetti.size, color: confetti.color);
    }
  }

  Widget _buildSparkle(_Sparkle sparkle) {
    final progress = ((_mainController.value - sparkle.delay) * 2).clamp(
      0.0,
      1.0,
    );
    if (progress <= 0) return const SizedBox();

    final sparklePhase = (_sparkleController.value + sparkle.delay) % 1.0;
    final twinkle = 0.5 + 0.5 * sin(sparklePhase * 2 * pi);
    final scale = progress * (0.8 + twinkle * 0.4);

    final x = cos(sparkle.angle) * sparkle.distance * progress;
    final y = sin(sparkle.angle) * sparkle.distance * progress;

    return Positioned(
      left: 150 + x - sparkle.size / 2,
      top: 150 + y - sparkle.size / 2,
      child: Transform.scale(
        scale: scale,
        child: _buildStarShape(sparkle.size, sparkle.color, twinkle),
      ),
    );
  }

  Widget _buildStarShape(double size, Color color, double twinkle) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(color: color.withOpacity(0.8 + twinkle * 0.2)),
      ),
    );
  }

  Widget _buildBadge(Color primaryColor) {
    final glowIntensity = _glowPulse.value;

    return Transform.scale(
      scale: _badgeScale.value,
      child: Transform.rotate(
        angle: _badgeRotation.value,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            boxShadow: [
              // Outer glow
              BoxShadow(
                color: primaryColor.withOpacity(0.4 * glowIntensity),
                blurRadius: 40 * glowIntensity,
                spreadRadius: 10 * glowIntensity,
              ),
              // Inner shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.8),
                _getSecondaryColor(),
              ],
            ).createShader(bounds),
            child: Icon(_getIcon(), size: 90, color: Colors.white),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.level) {
      case StreakLevel.gold:
        return Icons.emoji_events_rounded;
      case StreakLevel.silver:
        return Icons.stars_rounded;
      case StreakLevel.bronze:
        return Icons.local_fire_department_rounded;
    }
  }

  Color _getSecondaryColor() {
    switch (widget.level) {
      case StreakLevel.gold:
        return const Color(0xFFFF6B35);
      case StreakLevel.silver:
        return const Color(0xFF00CED1);
      case StreakLevel.bronze:
        return Colors.deepOrange;
    }
  }

  Widget _buildText() {
    return Transform.translate(
      offset: Offset(0, _textSlide.value),
      child: Opacity(
        opacity: _textFade.value,
        child: Column(
          children: [
            Text(
              _getTitle(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: _getColors().first.withOpacity(0.8),
                    blurRadius: 20,
                  ),
                  const Shadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '🔥 ${widget.streakCount} ${_getStreakText()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.level) {
      case StreakLevel.gold:
        return 'ЛЕГЕНДА!';
      case StreakLevel.silver:
        return 'НЕВЕРОЯТНО!';
      case StreakLevel.bronze:
        return 'БРАВО!';
    }
  }

  String _getStreakText() {
    if (widget.streakCount == 1) return 'верен отговор';
    return 'поредни верни';
  }
}

// Custom star painter for sparkles
class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) - pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Add glow effect
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data classes for particles
enum _ConfettiShape { circle, square, rectangle, star }

class _Confetti {
  final double startX;
  final double delay;
  final double speed;
  final double amplitude;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final _ConfettiShape shape;

  _Confetti({
    required this.startX,
    required this.delay,
    required this.speed,
    required this.amplitude,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _Sparkle {
  final double angle;
  final double distance;
  final double size;
  final double delay;
  final Color color;

  _Sparkle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.color,
  });
}

class _Ring {
  final double delay;
  final Color color;

  _Ring({required this.delay, required this.color});
}
