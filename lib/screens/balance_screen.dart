import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_chronometer_balance/enum/my_enums.dart';
import 'package:the_chronometer_balance/models/archive_item_model.dart';
import 'package:the_chronometer_balance/providers/image_provider.dart';
import 'package:the_chronometer_balance/providers/input_provider.dart';
import 'package:the_chronometer_balance/providers/project_provider.dart';
import 'package:the_chronometer_balance/providers/search_provider.dart';
import 'package:the_chronometer_balance/utils/const.dart';

class BalanceScreen extends ConsumerStatefulWidget {
  const BalanceScreen({super.key});

  @override
  ConsumerState<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends ConsumerState<BalanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  InstrumentType? _selectedFilter;
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _searchFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;

    final filteredByType = _selectedFilter == null
        ? allEntries
        : allEntries.where((e) => e.instrumentType == _selectedFilter).toList();
    final entries = searchProv.filteredList(filteredByType);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(allEntries.length),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
              child: Column(
                children: [
                  if (_showSearch) ...[
                    SizedBox(height: 16.h),
                    _buildSearchBar(),
                    SizedBox(height: 16.h),
                  ] else
                    SizedBox(height: 16.h),
                  _buildFilterRow(),
                ],
              ),
            ),
          ),
          entries.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = entries[index];
                      final mainIndex = allEntries.indexOf(entry);
                      return _InstrumentCard(
                        entry: entry,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pushNamed(
                            context,
                            '/info_screen',
                            arguments: {'index': mainIndex},
                          );
                        },
                      );
                    }, childCount: entries.length),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THE',
                      style: GoogleFonts.libreBaskerville(
                        color: kPrimaryText,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'CHRONOMETER',
                      style: GoogleFonts.libreBaskerville(
                        color: kPrimaryText,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'BALANCE',
                      style: GoogleFonts.libreBaskerville(
                        color: kPrimaryText,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w700,
                        height: 0.9,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _iconBtn(
                      _showSearch ? Icons.close_rounded : Icons.search_rounded,
                      onTap: () {
                        setState(() {
                          _showSearch = !_showSearch;
                          if (!_showSearch) {
                            _searchController.clear();
                            ref
                                .read(searchProvider.notifier)
                                .clearSearchQuery();
                            _searchFocus.unfocus();
                          } else {
                            _searchFocus.requestFocus();
                          }
                        });
                      },
                    ),
                    SizedBox(width: 8.w),
                    _iconBtn(
                      Icons.add_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(inputProvider).clearAll();
                        ref.read(imageProvider).clearImage();
                        Navigator.pushNamed(context, '/add_screen');
                      },
                      filled: true,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: kCardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kOutline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${count.toString().padLeft(2, '0')} INSTRUMENTS',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, {VoidCallback? onTap, bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: filled ? kAccent : kCardSurface,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: kOutline),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: kAccent.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: filled ? kCardSurface : kPrimaryText,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    if (!_showSearch) return const SizedBox();
    final isFocused = _searchFocus.hasFocus;
    final borderSide = isFocused
        ? const BorderSide(color: kAccent, width: 1.5)
        : BorderSide(color: kOutline, width: 1.0);
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: borderSide,
    );
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: SizedBox(
        height: 48.h,
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          textAlignVertical: TextAlignVertical.center,
          onChanged: (v) => ref.read(searchProvider.notifier).setSearchQuery(v),
          style: GoogleFonts.sourceSans3(color: kPrimaryText, fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: 'Search by identifier, maker...',
            hintStyle: GoogleFonts.sourceSans3(
              color: kSecondaryText.withAlpha(120),
              fontSize: 16.sp,
            ),
            filled: true,
            fillColor: kCardSurface,
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14.w, right: 8.w),
              child: Icon(
                Icons.search_rounded,
                color: kSecondaryText,
                size: 20.sp,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(searchProvider.notifier).clearSearchQuery();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Icon(
                        Icons.close_rounded,
                        color: kSecondaryText,
                        size: 18.sp,
                      ),
                    ),
                  )
                : null,
            border: outline,
            enabledBorder: outline,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kAccent, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final types = InstrumentType.values;
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _filterChip('All', null),
          ...types.map((t) => _filterChip(t.label, t)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, InstrumentType? type) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = type);
      },
      child: AnimatedContainer(
        duration: kTransitionDuration,
        curve: Curves.easeOut,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : kCardSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isSelected ? kAccent : kOutline, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kAccent.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.sourceSans3(
            color: isSelected ? kCardSurface : kSecondaryText,
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 1.h),
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: kCardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kOutline),
            ),
            child: Icon(
              Icons.balance_outlined,
              color: kSecondaryText.withAlpha(100),
              size: 32.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No instruments in this balance.',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 13.sp,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              ref.read(inputProvider).clearAll();
              ref.read(imageProvider).clearImage();
              Navigator.pushNamed(context, '/add_screen');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'ADD INSTRUMENT',
                style: GoogleFonts.ibmPlexMono(
                  color: kCardSurface,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstrumentCard extends ConsumerWidget {
  final HorologicalInstrumentModel entry;
  final VoidCallback onTap;

  const _InstrumentCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageProv = ref.watch(imageProvider);
    final photoPath = imageProv.getImagePath(entry.photoPath);
    final photoFile = photoPath != null && entry.photoPath.isNotEmpty
        ? File(photoPath)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.fromLTRB(16.w, 16.w, 18.w, 16.w),
        decoration: BoxDecoration(
          color: kCardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kOutline),
          boxShadow: [
            BoxShadow(
              color: kPrimaryText.withAlpha(6),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BalanceArc(condition: entry.conditionState),
            if (photoFile != null && photoFile.existsSync()) ...[
              SizedBox(width: 12.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  photoFile,
                  width: 72.w,
                  height: 72.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                ),
              ),
            ],
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.manufacturerAndMaker.isEmpty
                              ? 'Unknown Maker'
                              : entry.manufacturerAndMaker,
                          style: GoogleFonts.libreBaskerville(
                            color: kPrimaryText,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (entry.eraOfProduction.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Text(
                          entry.eraOfProduction,
                          style: GoogleFonts.libreBaskerville(
                            color: kWalnut,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.temporalIdentifier.isEmpty
                        ? 'UNCATALOGUED'
                        : entry.temporalIdentifier,
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  _Pill(
                    label: entry.countryOfOrigin.label,
                    color: kSecondaryText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexMono(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _BalanceArc extends StatelessWidget {
  final ConditionState condition;

  const _BalanceArc({required this.condition});

  @override
  Widget build(BuildContext context) {
    final isLevel =
        condition == ConditionState.operational ||
        condition == ConditionState.museumQuality;
    return SizedBox(
      width: 24.w,
      height: 60.h,
      child: CustomPaint(painter: _BalanceArcPainter(isLevel: isLevel)),
    );
  }
}

class _BalanceArcPainter extends CustomPainter {
  final bool isLevel;
  _BalanceArcPainter({required this.isLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = kAccent);

    canvas.drawLine(
      Offset(cx, cy + 3),
      Offset(cx, size.height - 2),
      Paint()
        ..color = kOutline.withAlpha(120)
        ..strokeWidth = 1.2,
    );

    final paint = Paint()
      ..color = kPrimaryText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    if (isLevel) {
      canvas.drawLine(Offset(cx - 8, cy - 4.5), Offset(cx, cy), paint);
      canvas.drawLine(Offset(cx + 8, cy + 4.5), Offset(cx, cy), paint);
    } else {
      canvas.drawLine(Offset(cx - 8, cy - 4.5), Offset(cx, cy), paint);
      canvas.drawLine(Offset(cx + 8, cy + 8), Offset(cx, cy + 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BalanceArcPainter oldDelegate) =>
      oldDelegate.isLevel != isLevel;
}
