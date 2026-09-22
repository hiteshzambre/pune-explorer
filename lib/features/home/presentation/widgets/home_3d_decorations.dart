import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Indicates if code is executing inside automated Flutter test runner.
bool get _isTestEnv =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test') ||
    const bool.fromEnvironment('FLUTTER_TEST');

/// 1. Floating 3D Location Pin with metallic bevel, perspective tilt, and dynamic ground shadow
class Floating3DLocationPin extends StatefulWidget {
  final double size;
  final Color pinColor;
  final String label;

  const Floating3DLocationPin({
    super.key,
    this.size = 54.0,
    this.pinColor = AppColors.saffron,
    this.label = 'Pune, MH',
  });

  @override
  State<Floating3DLocationPin> createState() => _Floating3DLocationPinState();
}

class _Floating3DLocationPinState extends State<Floating3DLocationPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (!_isTestEnv) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final floatOffset = math.sin(_controller.value * math.pi) * 8.0;
        final shadowScale = 1.0 - (_controller.value * 0.28);
        final shadowOpacity = 0.45 - (_controller.value * 0.2);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D Pin with Perspective Tilt & Float
            Transform.translate(
              offset: Offset(0, -floatOffset),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateX(0.12)
                  ..rotateY(-0.10),
                child: Container(
                  width: widget.size,
                  height: widget.size * 1.25,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF9E3D),
                        widget.pinColor,
                        const Color(0xFFC2410C),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(widget.size / 2),
                      topRight: Radius.circular(widget.size / 2),
                      bottomLeft: Radius.circular(widget.size / 2),
                      bottomRight: const Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.pinColor.withValues(alpha: 0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(-2, -2),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: widget.size * 0.48,
                      height: widget.size * 0.48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🚩',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Dynamic Ground Shadow that contracts as pin rises
            Transform.scale(
              scaleX: shadowScale,
              scaleY: shadowScale * 0.8,
              child: Container(
                width: widget.size * 0.65,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: shadowOpacity.clamp(0.1, 0.6)),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: shadowOpacity.clamp(0.1, 0.6)),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 2. Slow Rotating 3D Compass with brass & emerald beveled dial and magnetic needle
class SlowRotatingCompass3D extends StatefulWidget {
  final double size;

  const SlowRotatingCompass3D({
    super.key,
    this.size = 56.0,
  });

  @override
  State<SlowRotatingCompass3D> createState() => _SlowRotatingCompass3DState();
}

class _SlowRotatingCompass3DState extends State<SlowRotatingCompass3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
    if (!_isTestEnv) {
      _controller.repeat();
    } else {
      _controller.value = 0.25;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..rotateX(0.15)
        ..rotateY(0.10),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFDE68A), // Brass gold
              Color(0xFFB45309), // Deep amber brass
              Color(0xFF064E3B), // Sahyadri emerald rim
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFFCD34D).withValues(alpha: 0.7),
            width: 1.8,
          ),
        ),
        padding: const EdgeInsets.all(3.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cardinal Markers (N, S, E, W)
              const Positioned(
                top: 2,
                child: Text(
                  'N',
                  style: TextStyle(
                    color: AppColors.saffron,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Positioned(
                bottom: 2,
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Positioned(
                left: 3,
                child: Text(
                  'W',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Positioned(
                right: 3,
                child: Text(
                  'E',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Animated Magnetic Needle
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Oscillate slowly around North (0 to 25 degrees)
                  final angle = math.sin(_controller.value * 2 * math.pi) * 0.28;
                  return Transform.rotate(
                    angle: angle,
                    child: CustomPaint(
                      size: Size(widget.size * 0.24, widget.size * 0.65),
                      painter: _CompassNeedlePainter(),
                    ),
                  );
                },
              ),

              // Center Pivot Gem
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFCD34D),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // North Pointer (Saffron with bright highlight)
    final northPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(size.width, cy)
      ..lineTo(0, cy)
      ..close();

    final northPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7A00), Color(0xFFDC2626)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, cy));
    canvas.drawPath(northPath, northPaint);

    // South Pointer (Silver/Slate)
    final southPath = Path()
      ..moveTo(cx, size.height)
      ..lineTo(size.width, cy)
      ..lineTo(0, cy)
      ..close();

    final southPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF94A3B8), Color(0xFF475569)],
      ).createShader(Rect.fromLTWH(0, cy, size.width, cy));
    canvas.drawPath(southPath, southPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3. Layered Silhouette of Pune Landmarks (Shaniwar Wada Bastions + Sahyadri Hills)
class PuneLandmarkSilhouettePainter extends CustomPainter {
  final Color tintColor;

  PuneLandmarkSilhouettePainter({
    this.tintColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Distant Sahyadri mountain contour ridge
    final mountainPath = Path()
      ..moveTo(0, h * 0.72)
      ..cubicTo(w * 0.2, h * 0.62, w * 0.35, h * 0.78, w * 0.55, h * 0.65)
      ..cubicTo(w * 0.7, h * 0.58, w * 0.85, h * 0.70, w, h * 0.60)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final mountainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          tintColor.withValues(alpha: 0.07),
          tintColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.55, w, h * 0.45));
    canvas.drawPath(mountainPath, mountainPaint);

    // 2. Shaniwar Wada Delhi Darwaja & Bastion Silhouette
    final fortPath = Path();
    final fortBaseY = h * 0.76;
    final fortLeft = w * 0.65;
    final fortRight = w * 0.98;

    // Sinhagad bastion / Shaniwar Wada battlements
    fortPath.moveTo(fortLeft, h);
    fortPath.lineTo(fortLeft, fortBaseY + 12);
    // Left bastion curve
    fortPath.quadraticBezierTo(fortLeft - 10, fortBaseY - 14, fortLeft + 15, fortBaseY - 14);
    fortPath.lineTo(fortLeft + 30, fortBaseY - 14);
    // Crenellations (Kanguras)
    for (int i = 0; i < 4; i++) {
      final bx = fortLeft + 30 + (i * 12.0);
      fortPath.lineTo(bx, fortBaseY - 20);
      fortPath.lineTo(bx + 6, fortBaseY - 20);
      fortPath.lineTo(bx + 6, fortBaseY - 14);
    }
    // Grand Delhi Darwaja Arch
    final archCenter = fortLeft + 90;
    fortPath.lineTo(archCenter - 14, fortBaseY - 14);
    fortPath.quadraticBezierTo(archCenter, fortBaseY - 32, archCenter + 14, fortBaseY - 14);
    // Right bastion
    fortPath.lineTo(fortRight - 25, fortBaseY - 14);
    fortPath.quadraticBezierTo(fortRight + 5, fortBaseY - 14, fortRight, fortBaseY + 12);
    fortPath.lineTo(fortRight, h);
    fortPath.close();

    final fortPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          tintColor.withValues(alpha: 0.12),
          tintColor.withValues(alpha: 0.04),
        ],
      ).createShader(Rect.fromLTWH(fortLeft - 15, fortBaseY - 35, fortRight - fortLeft + 20, h));
    canvas.drawPath(fortPath, fortPaint);

    // 3. Subtle Topographical Contour lines
    final contourPaint = Paint()
      ..color = tintColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final contour1 = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.3, h * 0.74, w * 0.6, h * 0.84)
      ..quadraticBezierTo(w * 0.8, h * 0.90, w, h * 0.82);
    canvas.drawPath(contour1, contourPaint);

    final contour2 = Path()
      ..moveTo(0, h * 0.89)
      ..quadraticBezierTo(w * 0.4, h * 0.82, w * 0.75, h * 0.92)
      ..lineTo(w, h * 0.90);
    canvas.drawPath(contour2, contourPaint);
  }

  @override
  bool shouldRepaint(covariant PuneLandmarkSilhouettePainter oldDelegate) =>
      oldDelegate.tintColor != tintColor;
}

/// 4. Floating 3D Destination Micro-Card with perspective tilt & soft glow
class FloatingDestinationBadge3D extends StatelessWidget {
  final String title;
  final String rating;
  final String tag;
  final String emoji;
  final VoidCallback? onTap;

  const FloatingDestinationBadge3D({
    super.key,
    required this.title,
    required this.rating,
    required this.tag,
    this.emoji = '🏰',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.saffron.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.saffron.withValues(alpha: 0.4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, color: AppColors.amber, size: 12),
                          Text(
                            rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
