import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_chronometer_balance/providers/user_provider.dart';
import 'package:the_chronometer_balance/utils/const.dart';

// ─── Palette for onboarding dark canvas ───────────────────────────────────────
const _kDark = Color(0xFF0C1219);
const _kDarkCard = Color(0xFF14202E);
const _kGold = Color(0xFFC5A05A);
const _kStar = Color(0xFFFFFFFF);

// ─── Feature cards shown in the pager ─────────────────────────────────────────
class _Feature {
  final IconData icon;
  final String title;
  final String body;
  const _Feature(this.icon, this.title, this.body);
}

const _features = [
  _Feature(
    Icons.inventory_2_outlined,
    'Precision Archive',
    'Register every horological instrument — from depthing tools to marine chronometer testers — with full provenance and maker details.',
  ),
  _Feature(
    Icons.auto_awesome_rounded,
    'Observatory Mode',
    'Watch your entire collection orbit an animated orrery. Each instrument becomes a body in your private celestial sphere.',
  ),
  _Feature(
    Icons.bar_chart_rounded,
    'Balance Ledger',
    'Track preservation states, workshop origins, and production eras. A living statistical ledger for serious collectors.',
  ),
];

// ─── Main widget ──────────────────────────────────────────────────────────────
class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Continuous slow rotation for the clockwork backdrop
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    // One-shot entry animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _entryController.forward();
    });

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) setState(() => _currentPage = page);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _enter() {
    HapticFeedback.mediumImpact();
    ref.read(userProvider).setFirstTimeUser(false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      body: Stack(
        children: [
          // ── Animated clockwork background ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) => CustomPaint(
                painter: _ClockworkPainter(t: _bgController.value),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 48.h),
                    _buildWordmark(),
                    SizedBox(height: 48.h),
                    _buildPager(),
                    SizedBox(height: 24.h),
                    _buildDots(),
                    const Spacer(),
                    _buildCta(),
                    SizedBox(height: 36.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Wordmark ──────────────────────────────────────────────────────────────
  Widget _buildWordmark() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: _kGold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withAlpha(120),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'TCB·  HOROLOGICAL ARCHIVE',
                style: GoogleFonts.ibmPlexMono(
                  color: _kGold.withAlpha(160),
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.4,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Main logotype
          Text(
            'THE',
            style: GoogleFonts.libreBaskerville(
              color: _kStar.withAlpha(220),
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
              height: 1.0,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'CHRONOMETER',
            style: GoogleFonts.libreBaskerville(
              color: _kStar.withAlpha(220),
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              height: 0.95,
            ),
          ),
          SizedBox(height: 2.h),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [_kGold, Color(0xFFE8C97A), _kGold],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              'BALANCE',
              style: GoogleFonts.libreBaskerville(
                color: Colors.white,
                fontSize: 52.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -2.0,
                height: 0.88,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: 44.w,
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_kGold.withAlpha(0), _kGold, _kGold.withAlpha(0)],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  // ── Feature pager ──────────────────────────────────────────────────────────
  Widget _buildPager() {
    return SizedBox(
      height: 170.h,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _features.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          final f = _features[i];
          final isActive = i == _currentPage;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isActive ? 1.0 : 0.45,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Container(
                padding: EdgeInsets.all(22.w),
                decoration: BoxDecoration(
                  color: _kDarkCard.withAlpha(isActive ? 220 : 160),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? _kGold.withAlpha(80)
                        : _kStar.withAlpha(15),
                    width: isActive ? 1.5 : 1.0,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _kGold.withAlpha(15),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: _kGold.withAlpha(isActive ? 25 : 10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _kGold.withAlpha(isActive ? 70 : 30),
                        ),
                      ),
                      child: Icon(
                        f.icon,
                        color: isActive ? _kGold : _kGold.withAlpha(140),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: GoogleFonts.libreBaskerville(
                              color: _kStar.withAlpha(isActive ? 230 : 160),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            f.body,
                            style: GoogleFonts.sourceSans3(
                              color: _kStar.withAlpha(isActive ? 130 : 80),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w300,
                              height: 1.5,
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
        },
      ),
    );
  }

  // ── Page indicator dots ────────────────────────────────────────────────────
  Widget _buildDots() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Row(
        children: List.generate(_features.length, (i) {
          final isActive = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            margin: EdgeInsets.only(right: 6.w),
            width: isActive ? 20.w : 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: isActive ? _kGold : _kStar.withAlpha(40),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  // ── CTA button + subline ───────────────────────────────────────────────────
  Widget _buildCta() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: _enter,
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kGold, Color(0xFFB8903F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _kGold.withAlpha(60),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'OPEN THE BALANCE',
                    style: GoogleFonts.ibmPlexMono(
                      color: _kDark,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: _kDark.withAlpha(180),
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'For collectors who guard the second.',
            textAlign: TextAlign.center,
            style: GoogleFonts.libreBaskerville(
              color: _kStar.withAlpha(50),
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Clockwork background painter ─────────────────────────────────────────────
class _ClockworkPainter extends CustomPainter {
  final double t; // 0→1 repeating
  _ClockworkPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.36;

    _drawNebula(canvas, size, cx, cy);
    _drawStars(canvas, size);
    _drawGearRings(canvas, cx, cy, size);
    _drawTickMarks(canvas, cx, cy);
    _drawCenter(canvas, cx, cy);
  }

  void _drawNebula(Canvas canvas, Size size, double cx, double cy) {
    final shader = RadialGradient(
      center: Alignment(cx / size.width * 2 - 1, cy / size.height * 2 - 1),
      radius: 0.9,
      colors: [_kGold.withAlpha(18), kAccent.withAlpha(12), Colors.transparent],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _drawStars(Canvas canvas, Size size) {
    final rand = math.Random(91);
    for (int i = 0; i < 70; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final phase = rand.nextDouble() * math.pi * 2;
      final brightness = (math.sin(t * math.pi * 2 + phase) + 1) / 2;
      final alpha = (30 + brightness * 90).toInt().clamp(20, 120);
      final radius = 0.3 + rand.nextDouble() * 0.8;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = _kStar.withAlpha(alpha),
      );
    }
  }

  void _drawGearRings(Canvas canvas, double cx, double cy, Size size) {
    final maxR = math.min(size.width, size.height) * 0.44;

    final rings = [
      (0.38, 1.0, 40, 0.8, 1.0),
      (0.62, -0.5, 60, 0.6, 0.7),
      (0.88, 0.3, 80, 0.5, 0.5),
      (1.0, -0.2, 96, 0.4, 0.35),
    ];

    for (final (rf, speed, teeth, toothH, alf) in rings) {
      final r = maxR * rf;
      final angle = t * math.pi * 2 * speed;
      final alpha = (alf * 22).toInt().clamp(5, 24);

      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = _kGold.withAlpha(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      final toothLen = r * 0.028 * toothH;
      for (int i = 0; i < teeth; i++) {
        final a = angle + i * 2 * math.pi / teeth;
        final r1 = r - toothLen / 2;
        final r2 = r + toothLen / 2;
        canvas.drawLine(
          Offset(cx + r1 * math.cos(a), cy + r1 * math.sin(a)),
          Offset(cx + r2 * math.cos(a), cy + r2 * math.sin(a)),
          Paint()
            ..color = _kGold.withAlpha((alpha * 1.5).toInt().clamp(5, 36))
            ..strokeWidth = 0.9,
        );
      }
    }
  }

  void _drawTickMarks(Canvas canvas, double cx, double cy) {
    final innerR = math.min(300.0, 300.0) * 0.44 * 0.38;
    for (int i = 0; i < 60; i++) {
      final a = i * math.pi / 30 + t * math.pi * 2 * 0.3;
      final isMajor = i % 5 == 0;
      final r1 = innerR * (isMajor ? 0.80 : 0.88);
      final r2 = innerR * 0.96;
      canvas.drawLine(
        Offset(cx + r1 * math.cos(a), cy + r1 * math.sin(a)),
        Offset(cx + r2 * math.cos(a), cy + r2 * math.sin(a)),
        Paint()
          ..color = _kGold.withAlpha(isMajor ? 40 : 16)
          ..strokeWidth = isMajor ? 1.2 : 0.5,
      );
    }
  }

  void _drawCenter(Canvas canvas, double cx, double cy) {
    final pulse = (math.sin(t * math.pi * 2 * 1.5) + 1) / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      14 + pulse * 8,
      Paint()
        ..color = _kGold.withAlpha((8 + pulse * 18).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      2.8 + pulse * 1.2,
      Paint()..color = _kGold.withAlpha(200 + (pulse * 55).toInt()),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      6 + pulse * 2,
      Paint()
        ..color = _kGold.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_ClockworkPainter old) => old.t != t;
}
