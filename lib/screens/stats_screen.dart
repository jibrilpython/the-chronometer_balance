import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_chronometer_balance/enum/my_enums.dart';
import 'package:the_chronometer_balance/models/archive_item_model.dart';
import 'package:the_chronometer_balance/providers/project_provider.dart';
import 'package:the_chronometer_balance/utils/const.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _countUp;

  String? _filterCondition;
  String? _filterClass;
  String? _filterOrigin;
  String? _filterMaker;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _countUp = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _filterCondition = null;
      _filterClass = null;
      _filterOrigin = null;
      _filterMaker = null;
    });
  }

  List<HorologicalInstrumentModel> _filtered(
    List<HorologicalInstrumentModel> all,
  ) {
    return all.where((e) {
      if (_filterCondition != null &&
          e.conditionState.label != _filterCondition) {
        return false;
      }
      if (_filterClass != null && e.instrumentType.label != _filterClass) {
        return false;
      }
      if (_filterOrigin != null && e.countryOfOrigin.label != _filterOrigin) {
        return false;
      }
      if (_filterMaker != null && e.manufacturerAndMaker != _filterMaker) {
        return false;
      }
      return true;
    }).toList();
  }

  bool get _hasActiveFilter =>
      _filterCondition != null ||
      _filterClass != null ||
      _filterOrigin != null ||
      _filterMaker != null;

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(projectProvider).entries;
    final displayEntries = _hasActiveFilter
        ? _filtered(allEntries)
        : allEntries;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(allEntries.length),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
            sliver: allEntries.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _emptyState(),
                  )
                : SliverList(
                    delegate: SliverChildListDelegate([
                      _OverviewHero(entries: allEntries, countUp: _countUp),
                      if (_hasActiveFilter) ...[
                        SizedBox(height: 16.h),
                        _ActiveFilterBar(
                          condition: _filterCondition,
                          instrumentClass: _filterClass,
                          origin: _filterOrigin,
                          maker: _filterMaker,
                          onClear: _clearFilters,
                          resultCount: displayEntries.length,
                        ),
                        SizedBox(height: 16.h),
                      ] else
                        SizedBox(height: 28.h),
                      _PreservationSpectrum(
                        entries: allEntries,
                        selected: _filterCondition,
                        onSelect: (label) => setState(() {
                          _filterCondition = _filterCondition == label
                              ? null
                              : label;
                        }),
                      ),
                      SizedBox(height: 20.h),
                      _ClassBreakdown(
                        entries: allEntries,
                        selected: _filterClass,
                        onSelect: (label) => setState(() {
                          _filterClass = _filterClass == label ? null : label;
                        }),
                      ),
                      SizedBox(height: 20.h),
                      _OriginBreakdown(
                        entries: allEntries,
                        selected: _filterOrigin,
                        onSelect: (label) => setState(() {
                          _filterOrigin = _filterOrigin == label ? null : label;
                        }),
                      ),
                      SizedBox(height: 20.h),
                      _MakerRanking(
                        entries: allEntries,
                        selected: _filterMaker,
                        onSelect: (maker) => setState(() {
                          _filterMaker = _filterMaker == maker ? null : maker;
                        }),
                      ),
                      if (_hasActiveFilter && displayEntries.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        _FilteredPreview(entries: displayEntries),
                      ],
                    ]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stats',
              style: GoogleFonts.libreBaskerville(
                color: kPrimaryText,
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'COLLECTION METRICS',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 11.sp,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        'No instruments in this balance.',
        style: GoogleFonts.ibmPlexMono(color: kSecondaryText, fontSize: 13.sp),
      ),
    );
  }
}

class _ActiveFilterBar extends StatelessWidget {
  final String? condition;
  final String? instrumentClass;
  final String? origin;
  final String? maker;
  final VoidCallback onClear;
  final int resultCount;

  const _ActiveFilterBar({
    this.condition,
    this.instrumentClass,
    this.origin,
    this.maker,
    required this.onClear,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (condition != null) _filterChip(condition!, kAccent),
      if (instrumentClass != null) _filterChip(instrumentClass!, kWalnut),
      if (origin != null) _filterChip(origin!, kPrimaryText),
      if (maker != null) _filterChip(maker!, kSecondaryText),
    ];

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: kActiveBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccent.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_rounded,
            color: kAccent.withAlpha(180),
            size: 14.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...chips,
                  SizedBox(width: 6.w),
                  Text(
                    '$resultCount result${resultCount == 1 ? '' : 's'}',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: kCardSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kOutline),
              ),
              child: Icon(
                Icons.close_rounded,
                color: kSecondaryText,
                size: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
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
      ),
    );
  }
}

class _FilteredPreview extends ConsumerWidget {
  final List<HorologicalInstrumentModel> entries;
  const _FilteredPreview({required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(projectProvider).entries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Text(
            'MATCHING ENTRIES',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...entries.map((e) => _MiniEntryCard(entry: e, all: all)),
      ],
    );
  }
}

class _MiniEntryCard extends StatelessWidget {
  final HorologicalInstrumentModel entry;
  final List<HorologicalInstrumentModel> all;
  const _MiniEntryCard({required this.entry, required this.all});

  @override
  Widget build(BuildContext context) {
    final typeColor = getInstrumentColor(entry.instrumentType);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final idx = all.indexOf(entry);
        if (idx >= 0) {
          Navigator.pushNamed(
            context,
            '/info_screen',
            arguments: {'index': idx},
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.fromLTRB(12.w, 12.w, 16.w, 12.w),
        decoration: BoxDecoration(
          color: kCardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kOutline),
        ),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: typeColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.manufacturerAndMaker.isEmpty
                        ? 'Unknown Maker'
                        : entry.manufacturerAndMaker,
                    style: GoogleFonts.sourceSans3(
                      color: kPrimaryText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.temporalIdentifier.isEmpty
                        ? 'UNCATALOGUED'
                        : entry.temporalIdentifier,
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: kSecondaryText,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewHero extends StatelessWidget {
  final List<HorologicalInstrumentModel> entries;
  final Animation<double> countUp;
  const _OverviewHero({required this.entries, required this.countUp});

  String _eraSpan() {
    final years = <int>[];
    for (final e in entries) {
      final digits = e.eraOfProduction.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 4) {
        years.add(int.tryParse(digits.substring(0, 4)) ?? 0);
      }
    }
    if (years.isEmpty) return '---';
    final min = years.reduce((a, b) => a < b ? a : b);
    final max = years.reduce((a, b) => a > b ? a : b);
    if (min == max) return '$min';
    return '$min\u2013$max';
  }

  @override
  Widget build(BuildContext context) {
    final makerCount = entries
        .map((e) => e.manufacturerAndMaker)
        .where((m) => m.isNotEmpty)
        .toSet()
        .length;
    final total = entries.length;
    final eraText = _eraSpan();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutline),
        boxShadow: [
          BoxShadow(
            color: kPrimaryText.withAlpha(8),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: countUp,
            builder: (context, _) {
              final display = (countUp.value * total).round();
              return Text(
                '$display',
                style: GoogleFonts.libreBaskerville(
                  color: kAccent,
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              );
            },
          ),
          SizedBox(height: 4.h),
          Text(
            'INSTRUMENTS IN COLLECTION',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: kOutline.withAlpha(80), height: 1),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.handyman_outlined,
                      color: kPrimaryText.withAlpha(100),
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '$makerCount',
                      style: GoogleFonts.libreBaskerville(
                        color: kPrimaryText,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'workshop${makerCount == 1 ? '' : 's'}',
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 24.h, color: kOutline.withAlpha(80)),
              SizedBox(width: 16.w),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      color: kWalnut.withAlpha(150),
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          eraText,
                          style: GoogleFonts.libreBaskerville(
                            color: kWalnut,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'period',
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutline),
        boxShadow: [
          BoxShadow(
            color: kPrimaryText.withAlpha(6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _PreservationSpectrum extends StatelessWidget {
  final List<HorologicalInstrumentModel> entries;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _PreservationSpectrum({
    required this.entries,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <ConditionState, int>{};
    for (final e in entries) {
      counts[e.conditionState] = (counts[e.conditionState] ?? 0) + 1;
    }

    final total = entries.length;
    final states = ConditionState.values
        .where((s) => (counts[s] ?? 0) > 0)
        .toList();
    if (states.isEmpty) {
      return _SectionCard(
        title: 'PRESERVATION SPECTRUM',
        child: Text(
          'No condition data recorded.',
          style: GoogleFonts.sourceSans3(
            color: kSecondaryText,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return _SectionCard(
      title: 'PRESERVATION SPECTRUM',
      child: Column(
        children: [
          _spectrumBar(states, counts, total),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: states.map((state) {
              final count = counts[state] ?? 0;
              final isSelected = selected == state.label;
              final color = getConditionColor(state);
              return GestureDetector(
                onTap: () => onSelect(state.label),
                child: AnimatedContainer(
                  duration: kTransitionDuration,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(20) : kBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : kOutline,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        state.label,
                        style: GoogleFonts.sourceSans3(
                          color: isSelected ? kPrimaryText : kSecondaryText,
                          fontSize: 12.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$count',
                        style: GoogleFonts.ibmPlexMono(
                          color: isSelected ? color : kSecondaryText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (selected != null) ...[SizedBox(height: 12.h), _filterHint()],
        ],
      ),
    );
  }

  Widget _spectrumBar(
    List<ConditionState> states,
    Map<ConditionState, int> counts,
    int total,
  ) {
    return Container(
      height: 28.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kPrimaryText.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: states.map((state) {
          final count = counts[state] ?? 0;
          final pct = total > 0 ? count / total : 0.0;
          final color = getConditionColor(state);
          return Expanded(
            flex: (pct * 100).round().clamp(1, 100),
            child: Container(
              color: color,
              child: Center(
                child: pct > 0.08
                    ? Text(
                        '${(pct * 100).toInt()}%',
                        style: GoogleFonts.ibmPlexMono(
                          color: kCardSurface,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _filterHint() {
    return Row(
      children: [
        Icon(
          Icons.touch_app_rounded,
          color: kAccent.withAlpha(120),
          size: 12.sp,
        ),
        SizedBox(width: 6.w),
        Text(
          'Tap another chip to refine, or tap again to clear',
          style: GoogleFonts.ibmPlexMono(color: kSecondaryText, fontSize: 9.sp),
        ),
      ],
    );
  }
}

class _ClassBreakdown extends StatelessWidget {
  final List<HorologicalInstrumentModel> entries;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _ClassBreakdown({
    required this.entries,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <InstrumentType, int>{};
    for (final e in entries) {
      counts[e.instrumentType] = (counts[e.instrumentType] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isEmpty ? 1 : sorted.first.value;

    return _SectionCard(
      title: 'INSTRUMENT CLASS',
      child: Column(
        children: [
          ...sorted.map((e) {
            final pct = e.value / maxVal;
            final isSelected = selected == e.key.label;
            final color = getInstrumentColor(e.key);
            return GestureDetector(
              onTap: () => onSelect(e.key.label),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: kOutline.withAlpha(60),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SizedBox(
                      width: 130.w,
                      child: Text(
                        e.key.label,
                        style: GoogleFonts.sourceSans3(
                          color: isSelected
                              ? kPrimaryText
                              : kPrimaryText.withAlpha(180),
                          fontSize: 14.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 8.h,
                          color: kOutline,
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: pct,
                            child: Container(
                              color: isSelected
                                  ? color
                                  : kAccent.withAlpha(120),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SizedBox(
                      width: 24.w,
                      child: Text(
                        '${e.value}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.ibmPlexMono(
                          color: isSelected ? kPrimaryText : kSecondaryText,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OriginBreakdown extends StatelessWidget {
  final List<HorologicalInstrumentModel> entries;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _OriginBreakdown({
    required this.entries,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <CountryOfOrigin, int>{};
    for (final e in entries) {
      counts[e.countryOfOrigin] = (counts[e.countryOfOrigin] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isEmpty ? 1 : sorted.first.value;

    return _SectionCard(
      title: 'NATIONAL GUILD',
      child: Column(
        children: [
          ...sorted.map((e) {
            final pct = e.value / maxVal;
            final isSelected = selected == e.key.label;
            return GestureDetector(
              onTap: () => onSelect(e.key.label),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: kOutline.withAlpha(60),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90.w,
                      child: Text(
                        e.key.label,
                        style: GoogleFonts.sourceSans3(
                          color: isSelected
                              ? kPrimaryText
                              : kPrimaryText.withAlpha(180),
                          fontSize: 14.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 8.h,
                          color: kOutline,
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: pct,
                            child: Container(
                              color: isSelected
                                  ? kWalnut
                                  : kWalnut.withAlpha(120),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SizedBox(
                      width: 24.w,
                      child: Text(
                        '${e.value}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.ibmPlexMono(
                          color: isSelected ? kPrimaryText : kSecondaryText,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MakerRanking extends StatelessWidget {
  final List<HorologicalInstrumentModel> entries;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _MakerRanking({
    required this.entries,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final e in entries) {
      if (e.manufacturerAndMaker.isNotEmpty) {
        counts[e.manufacturerAndMaker] =
            (counts[e.manufacturerAndMaker] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) {
      return _SectionCard(
        title: 'LEADING WORKSHOPS',
        child: Text(
          'No maker data recorded.',
          style: GoogleFonts.sourceSans3(
            color: kSecondaryText,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value;

    return _SectionCard(
      title: 'LEADING WORKSHOPS',
      child: Column(
        children: List.generate(math.min(sorted.length, 8), (i) {
          final e = sorted[i];
          final pct = e.value / maxVal;
          final isSelected = selected == e.key;
          return GestureDetector(
            onTap: () => onSelect(e.key),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kOutline.withAlpha(60), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20.w,
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText.withAlpha(120),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.key,
                      style: GoogleFonts.sourceSans3(
                        color: isSelected
                            ? kPrimaryText
                            : kPrimaryText.withAlpha(180),
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      width: 60.w,
                      height: 8.h,
                      color: kOutline,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          color: isSelected ? kAccent : kAccent.withAlpha(120),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 24.w,
                    child: Text(
                      '${e.value}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.ibmPlexMono(
                        color: isSelected ? kPrimaryText : kSecondaryText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
