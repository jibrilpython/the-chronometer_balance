import 'dart:math' as math;
import 'dart:io' show File;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_chronometer_balance/enum/my_enums.dart';
import 'package:the_chronometer_balance/models/archive_item_model.dart';
import 'package:the_chronometer_balance/providers/project_provider.dart';
import 'package:the_chronometer_balance/utils/const.dart';

const _kObsBg = Color(0xFF0B1622);
const _kObsCard = Color(0xFF162A41);
const _kObsStar = Color(0xFFFFFFFF);

IconData _iconForType(InstrumentType type) {
  switch (type) {
    case InstrumentType.stakingTool:
      return Icons.build_rounded;
    case InstrumentType.depthingTool:
      return Icons.straighten_rounded;
    case InstrumentType.mainspringWinder:
      return Icons.timer_rounded;
    case InstrumentType.poiseScale:
      return Icons.balance_rounded;
    case InstrumentType.watchTimingMachine:
      return Icons.schedule_rounded;
    case InstrumentType.marineChronometerTester:
      return Icons.waves_rounded;
    case InstrumentType.masterClock:
      return Icons.access_time_rounded;
    case InstrumentType.transitInstrument:
      return Icons.explore_rounded;
    case InstrumentType.ratingScale:
      return Icons.speed_rounded;
  }
}

class ObservatoryMapScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const ObservatoryMapScreen({super.key, this.isActive = true});

  @override
  ConsumerState<ObservatoryMapScreen> createState() =>
      _ObservatoryMapScreenState();
}

class _ObservatoryMapScreenState extends ConsumerState<ObservatoryMapScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Ticker _ticker;
  double _time = 0;
  double _dragRotation = 0;
  double _targetRotation = 0;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker((elapsed) {
      _time = elapsed.inMicroseconds / 1000000;
      _dragRotation += (_targetRotation - _dragRotation) * 0.08;
      if (mounted) setState(() {});
    });
    if (widget.isActive) _ticker.start();
  }

  @override
  void didUpdateWidget(ObservatoryMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    if (widget.isActive) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      if (_ticker.isActive) _ticker.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_ticker.isActive) _ticker.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isActive && !_ticker.isActive) _ticker.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(projectProvider).entries;
    final safeSelected = _selectedIndex != null && _selectedIndex! < all.length
        ? _selectedIndex
        : null;

    return Scaffold(
      backgroundColor: _kObsBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(all.length),
            if (all.isEmpty)
              _buildEmptyState()
            else
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final orrerySize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return GestureDetector(
                      onPanUpdate: (d) {
                        _targetRotation += d.delta.dx * 0.005;
                      },
                      onTapUp: (details) =>
                          _handleTap(details.localPosition, all, orrerySize),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size.infinite,
                            painter: _OrreryPainter(
                              count: all.length,
                              time: _time,
                              rotation: _dragRotation,
                              selected: safeSelected,
                              orrerySize: orrerySize,
                            ),
                          ),
                          ..._buildBodies(all, orrerySize),
                          if (safeSelected != null)
                            _buildPanel(all[safeSelected]),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: kAccent.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _kObsStar.withAlpha(200),
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Observatory',
                style: GoogleFonts.libreBaskerville(
                  color: _kObsStar,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$count ${count == 1 ? 'instrument' : 'instruments'} in orbit',
                style: GoogleFonts.ibmPlexMono(
                  color: _kObsStar.withAlpha(80),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (_selectedIndex != null)
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = null),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _kObsCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kAccent.withAlpha(60)),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: _kObsStar.withAlpha(180),
                  size: 18.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccent.withAlpha(30),
              ),
              child: Icon(
                Icons.explore_rounded,
                color: kAccent.withAlpha(150),
                size: 36.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Your observatory awaits',
              style: GoogleFonts.libreBaskerville(
                color: _kObsStar.withAlpha(200),
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add instruments to your collection\nto populate the orrery.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexMono(
                color: _kObsStar.withAlpha(70),
                fontSize: 12.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_BodyInfo> _calculateBodies(
    List<HorologicalInstrumentModel> all,
    Size screen,
  ) {
    final cx = screen.width / 2;
    final cy = screen.height * 0.4;
    final maxR = math.min(screen.width, screen.height) * 0.36;

    final bodies = <_BodyInfo>[];
    for (int i = 0; i < all.length; i++) {
      final ringIndex = i % 5;
      final ringR = maxR * (0.18 + ringIndex * 0.22);
      final speed = 0.08 + ringIndex * 0.025;
      final phase = (i * 2.4) % (2 * math.pi);
      final angle = phase + _dragRotation + _time * speed;
      final x = cx + ringR * math.cos(angle);
      final y = cy + ringR * 0.65 * math.sin(angle);
      final depth = (math.sin(angle) + 1) / 2;

      bodies.add(
        _BodyInfo(index: i, x: x, y: y, depth: depth, ring: ringIndex),
      );
    }

    bodies.sort((a, b) => a.depth.compareTo(b.depth));
    return bodies;
  }

  void _handleTap(
    Offset position,
    List<HorologicalInstrumentModel> all,
    Size screen,
  ) {
    final bodies = _calculateBodies(all, screen);

    int? tappedIndex;
    double? tappedDepth;

    for (final b in bodies) {
      final scale = 0.8 + b.depth * 0.3;
      final hitRadius = 90 * scale * 0.45;
      final dist = (Offset(b.x, b.y) - position).distance;
      if (dist <= hitRadius &&
          (tappedIndex == null || b.depth > tappedDepth!)) {
        tappedIndex = b.index;
        tappedDepth = b.depth;
      }
    }

    if (tappedIndex != null) {
      HapticFeedback.mediumImpact();
      setState(
        () =>
            _selectedIndex = _selectedIndex == tappedIndex ? null : tappedIndex,
      );
    }
  }

  List<Widget> _buildBodies(List<HorologicalInstrumentModel> all, Size screen) {
    final bodies = _calculateBodies(all, screen);

    return bodies.map((b) {
      final i = b.index;
      final scale = 0.8 + b.depth * 0.3;
      const size = 90.0;
      return Positioned(
        left: b.x - size / 2,
        top: b.y - size / 2,
        child: IgnorePointer(
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: size,
              height: size,
              child: _OrreryNode(
                entry: all[i],
                isSelected: _selectedIndex == i,
                depth: b.depth,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPanel(HorologicalInstrumentModel entry) {
    final typeColor = getInstrumentColor(entry.instrumentType);
    final hasPhoto = entry.photoPath.isNotEmpty;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 108.h),
            decoration: BoxDecoration(
              color: _kObsCard.withAlpha(210),
              border: Border(
                top: BorderSide(color: kAccent.withAlpha(80), width: 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 40,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: typeColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: typeColor.withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: hasPhoto
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(
                                File(entry.photoPath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  _iconForType(entry.instrumentType),
                                  color: typeColor,
                                  size: 22.sp,
                                ),
                              ),
                            )
                          : Icon(
                              _iconForType(entry.instrumentType),
                              color: typeColor,
                              size: 22.sp,
                            ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.manufacturerAndMaker.isEmpty
                                ? 'Unknown Maker'
                                : entry.manufacturerAndMaker,
                            style: GoogleFonts.libreBaskerville(
                              color: _kObsStar,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            entry.temporalIdentifier.isEmpty
                                ? 'UNCATALOGUED'
                                : entry.temporalIdentifier,
                            style: GoogleFonts.ibmPlexMono(
                              color: _kObsStar.withAlpha(120),
                              fontSize: 10.sp,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Divider(color: _kObsStar.withAlpha(20), height: 1),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _chip(entry.instrumentType.label, typeColor),
                    _chip(entry.countryOfOrigin.label, _kWarmGlow),
                    if (entry.eraOfProduction.isNotEmpty)
                      _chip(entry.eraOfProduction, _kObsStar.withAlpha(140)),
                    if (entry.precisionRating.isNotEmpty)
                      _chip(
                        '\u00B1${entry.precisionRating}',
                        Colors.amber.withAlpha(200),
                      ),
                    _chip(
                      entry.conditionState.label,
                      getConditionColor(entry.conditionState),
                    ),
                  ],
                ),
                if (entry.provenance.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Text(
                    entry.provenance,
                    style: GoogleFonts.sourceSans3(
                      color: _kObsStar.withAlpha(150),
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 14.h),
                GestureDetector(
                  onTap: () {
                    final idx = ref
                        .read(projectProvider)
                        .entries
                        .indexOf(entry);
                    Navigator.pushNamed(
                      context,
                      '/info_screen',
                      arguments: {'index': idx},
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 44.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [typeColor, typeColor.withAlpha(180)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: _kObsStar,
                            size: 14.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'VIEW DETAILS',
                            style: GoogleFonts.ibmPlexMono(
                              color: _kObsStar,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexMono(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

const Color _kWarmGlow = Color(0xFF3B6FA0);

class _BodyInfo {
  final int index;
  final double x;
  final double y;
  final double depth;
  final int ring;
  _BodyInfo({
    required this.index,
    required this.x,
    required this.y,
    required this.depth,
    required this.ring,
  });
}

class _OrreryPainter extends CustomPainter {
  final int count;
  final double time;
  final double rotation;
  final int? selected;
  final Size orrerySize;

  _OrreryPainter({
    required this.count,
    required this.time,
    required this.rotation,
    required this.selected,
    required this.orrerySize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = orrerySize.width / 2;
    final cy = orrerySize.height * 0.4;
    final maxR = math.min(orrerySize.width, orrerySize.height) * 0.36;

    _drawBackground(canvas, size, cx, cy);
    _drawStars(canvas, size);
    _drawOrbitRings(canvas, cx, cy, maxR);
    _drawConstellations(canvas, cx, cy, maxR);
    _drawCenter(canvas, cx, cy);
  }

  void _drawBackground(Canvas c, Size s, double cx, double cy) {
    c.drawRect(Offset.zero & s, Paint()..color = _kObsBg);

    final nebula = RadialGradient(
      center: Alignment(cx / s.width * 2 - 1, cy / s.height * 2 - 1),
      radius: 1.0,
      colors: [kAccent.withAlpha(30), kAccent.withAlpha(8), Colors.transparent],
      stops: const [0, 0.4, 0.8],
    ).createShader(Offset.zero & s);
    c.drawRect(Offset.zero & s, Paint()..shader = nebula);
  }

  void _drawStars(Canvas c, Size s) {
    final rand = math.Random(137);
    for (int i = 0; i < 90; i++) {
      final x = rand.nextDouble() * s.width;
      final y = rand.nextDouble() * s.height;
      final phase = rand.nextDouble() * 2 * math.pi;
      final brightness = ((math.sin(time * 0.8 + phase) + 1) / 2 * 0.6 + 0.2);
      final radius = 0.3 + rand.nextDouble() * 1.0;
      final alpha = (brightness * 200).toInt().clamp(20, 200);
      c.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = _kObsStar.withAlpha(alpha),
      );
    }
  }

  void _drawOrbitRings(Canvas c, double cx, double cy, double maxR) {
    final ringCount = (count < 5) ? count : 5;

    for (int r = 0; r < ringCount; r++) {
      final ringR = maxR * (0.18 + r * 0.22);
      final isActive = selected != null && selected! % 5 == r;

      c.save();
      c.translate(cx, cy);
      c.scale(1, 0.65);

      if (isActive) {
        final glowPaint = Paint()
          ..color = kAccent.withAlpha(25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        c.drawOval(
          Rect.fromCircle(center: Offset.zero, radius: ringR),
          glowPaint,
        );
      }

      final alpha = isActive ? 100 : (50 - r * 6).clamp(10, 50);
      final width = isActive ? 1.5 : 0.6;

      c.drawOval(
        Rect.fromCircle(center: Offset.zero, radius: ringR),
        Paint()
          ..color = _kWarmGlow.withAlpha(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width,
      );

      if (isActive) {
        for (int i = 0; i < 360; i += 20) {
          final a = i * math.pi / 180;
          final tickR = ringR * 0.97;
          final tickR2 = ringR * 1.03;
          c.drawLine(
            Offset(tickR * math.cos(a), tickR * math.sin(a)),
            Offset(tickR2 * math.cos(a), tickR2 * math.sin(a)),
            Paint()
              ..color = _kWarmGlow.withAlpha(80)
              ..strokeWidth = 0.8,
          );
        }
      }

      c.restore();
    }
  }

  void _drawConstellations(Canvas c, double cx, double cy, double maxR) {
    final ringCount = (count < 5) ? count : 5;

    for (int r = 0; r < ringCount; r++) {
      final ringR = maxR * (0.18 + r * 0.22);
      final speed = 0.08 + r * 0.025;
      final ringIndices = <int>[];
      for (int i = r; i < count; i += 5) {
        ringIndices.add(i);
      }
      if (ringIndices.length < 2) continue;

      final positions = <Offset>[];
      for (final i in ringIndices) {
        final phase = (i * 2.4) % (2 * math.pi);
        final angle = phase + rotation + time * speed;
        positions.add(
          Offset(
            cx + ringR * math.cos(angle),
            cy + ringR * 0.65 * math.sin(angle),
          ),
        );
      }

      bool anySelected = ringIndices.any((i) => selected == i);

      for (int j = 0; j < positions.length; j++) {
        final next = (j + 1) % positions.length;
        final isAdjacentToSelected =
            selected != null &&
            (ringIndices[j] == selected || ringIndices[next] == selected);

        final alpha = isAdjacentToSelected ? 60 : (anySelected ? 15 : 25);

        final path = Path()
          ..moveTo(positions[j].dx, positions[j].dy)
          ..lineTo(positions[next].dx, positions[next].dy);

        c.drawPath(
          path,
          Paint()
            ..color = _kWarmGlow.withAlpha(alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isAdjacentToSelected ? 1.2 : 0.5,
        );

        if (isAdjacentToSelected) {
          final dashGap = 4.0;
          final totalLength = (positions[j] - positions[next]).distance;
          final dashes = (totalLength / dashGap).floor();
          if (dashes > 1) {
            final step = 1.0 / dashes;
            for (int d = 0; d < dashes; d += 2) {
              final t1 = d * step;
              final t2 = (d + 1) * step;
              final p1 = Offset.lerp(positions[j], positions[next], t1)!;
              final p2 = Offset.lerp(positions[j], positions[next], t2)!;
              c.drawLine(
                p1,
                p2,
                Paint()
                  ..color = _kWarmGlow.withAlpha(50)
                  ..strokeWidth = 0.8,
              );
            }
          }
        }
      }
    }
  }

  void _drawCenter(Canvas c, double cx, double cy) {
    final pulse = (math.sin(time * 1.2) + 1) / 2;

    c.drawCircle(
      Offset(cx, cy),
      20 + pulse * 12,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                kAccent.withAlpha((15 + pulse * 25).toInt()),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(cx, cy), radius: 32 + pulse * 12),
            )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    c.drawCircle(
      Offset(cx, cy),
      3 + pulse * 2,
      Paint()..color = _kWarmGlow.withAlpha(180 + (pulse * 75).toInt()),
    );

    c.drawCircle(
      Offset(cx, cy),
      7 + pulse * 3,
      Paint()
        ..color = _kWarmGlow.withAlpha(60 + (pulse * 40).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    c.drawCircle(
      Offset(cx, cy),
      12 + pulse * 5,
      Paint()
        ..color = _kWarmGlow.withAlpha(20 + (pulse * 25).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant _OrreryPainter old) => true;
}

class _OrreryNode extends StatelessWidget {
  final HorologicalInstrumentModel entry;
  final bool isSelected;
  final double depth;

  const _OrreryNode({
    required this.entry,
    required this.isSelected,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = getInstrumentColor(entry.instrumentType);
    final baseSize = 28.0 + depth * 8;

    return Container(
      width: baseSize + 20,
      height: baseSize + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: typeColor.withAlpha(
          ((isSelected ? 25 : 10) * depth).toInt().clamp(5, 25),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? typeColor : typeColor.withAlpha(180),
              border: Border.all(
                color: _kObsStar.withAlpha(isSelected ? 80 : 40),
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withAlpha(
                    (30 + (depth * 50)).toInt().clamp(30, 80),
                  ),
                  blurRadius: depth * 10 + 4,
                  spreadRadius: depth * 1.5,
                ),
              ],
            ),
            child: Icon(
              _iconForType(entry.instrumentType),
              color: _kObsStar,
              size: baseSize * 0.45,
            ),
          ),
        ],
      ),
    );
  }
}
