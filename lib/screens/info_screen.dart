import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_chronometer_balance/models/archive_item_model.dart';
import 'package:the_chronometer_balance/providers/image_provider.dart';
import 'package:the_chronometer_balance/providers/project_provider.dart';
import 'package:the_chronometer_balance/utils/const.dart';

class InfoScreen extends ConsumerStatefulWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends ConsumerState<InfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bloomController;

  @override
  void initState() {
    super.initState();
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _bloomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectProv = ref.watch(projectProvider);
    if (widget.index < 0 || widget.index >= projectProv.entries.length) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Text(
            'INSTRUMENT NOT FOUND',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    final entry = projectProv.entries[widget.index];
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeroImage(imagePath, entry)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildIdentitySection(entry),
                SizedBox(height: 24.h),
                _buildSpecCard(entry),
                SizedBox(height: 24.h),
                if (entry.provenance.isNotEmpty)
                  _buildDetailCard('CUSTODY', entry.provenance),
                if (entry.provenance.isNotEmpty) SizedBox(height: 16.h),
                if (entry.markingsAndStamps.isNotEmpty)
                  _buildDetailCard(
                    'SIGNATURES',
                    entry.markingsAndStamps,
                    isMono: true,
                  ),
                if (entry.markingsAndStamps.isNotEmpty) SizedBox(height: 16.h),
                if (entry.includedAccessories.isNotEmpty)
                  _buildDetailCard('APPURTENANCES', entry.includedAccessories),
                if (entry.includedAccessories.isNotEmpty)
                  SizedBox(height: 16.h),
                if (entry.notes.isNotEmpty)
                  _buildDetailCard('OBSERVATIONS', entry.notes),
                SizedBox(height: 24.h),
                _buildActionsRow(projectProv, entry),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(String? imagePath, HorologicalInstrumentModel entry) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 380.h,
          color: kCardSurface,
          child:
              imagePath != null &&
                  entry.photoPath.isNotEmpty &&
                  File(imagePath).existsSync()
              ? Image.file(File(imagePath), fit: BoxFit.cover)
              : Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: kOutline,
                    size: 52.sp,
                  ),
                ),
        ),
        Positioned(
          top: 48.h,
          left: 20.w,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: kCardSurface.withAlpha(220),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kOutline),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: kPrimaryText,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kBackground.withAlpha(0), kBackground],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentitySection(HorologicalInstrumentModel entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: kAccent.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.instrumentType.label,
                style: GoogleFonts.sourceSans3(
                  color: kAccent,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: kWalnut.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.countryOfOrigin.label,
                style: GoogleFonts.ibmPlexMono(color: kWalnut, fontSize: 11.sp),
              ),
            ),
            const Spacer(),
            if (entry.precisionRating.isNotEmpty)
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kOutline),
                  ),
                  child: Text(
                    '\u00B1 ${entry.precisionRating}',
                    style: GoogleFonts.ibmPlexMono(
                      color: kPrimaryText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          entry.manufacturerAndMaker.isEmpty
              ? 'Unknown Maker'
              : entry.manufacturerAndMaker,
          style: GoogleFonts.libreBaskerville(
            color: kPrimaryText,
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Text(
          entry.temporalIdentifier.isEmpty
              ? 'UNCATALOGUED'
              : entry.temporalIdentifier,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 12.sp,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecCard(HorologicalInstrumentModel entry) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        children: [
          _specRow('State', entry.conditionState.label),
          _divider(),
          _specRow(
            'Period',
            entry.eraOfProduction.isEmpty ? 'Unknown' : entry.eraOfProduction,
          ),
          _divider(),
          _specRow('Architecture', entry.operatingPrinciple.label),
          _divider(),
          _specRow(
            'Composition',
            entry.materials.isEmpty ? 'Not specified' : entry.materials,
          ),
          _divider(),
          _specRow(
            'Profile',
            entry.dimensionsAndWeight.isEmpty
                ? 'Not recorded'
                : entry.dimensionsAndWeight,
          ),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 11.sp,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.sourceSans3(
                color: kPrimaryText,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: kOutline, thickness: 1, height: 1);

  Widget _buildDetailCard(String title, String content, {bool isMono = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 11.sp,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            content,
            style: isMono
                ? GoogleFonts.ibmPlexMono(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    height: 1.6,
                  )
                : GoogleFonts.sourceSans3(
                    color: kPrimaryText,
                    fontSize: 16.sp,
                    height: 1.6,
                    fontWeight: FontWeight.w300,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(
    ProjectNotifier projectProv,
    HorologicalInstrumentModel entry,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              projectProv.fillInput(ref, widget.index);
              Navigator.pushNamed(
                context,
                '/add_screen',
                arguments: {'isEdit': true, 'currentIndex': widget.index},
              );
            },
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: kCardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kOutline),
              ),
              child: Center(
                child: Text(
                  'EDIT',
                  style: GoogleFonts.ibmPlexMono(
                    color: kPrimaryText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () => _showDeleteDialog(projectProv),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: kCardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kError.withAlpha(100)),
              ),
              child: Center(
                child: Text(
                  'DELETE',
                  style: GoogleFonts.ibmPlexMono(
                    color: kError,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(ProjectNotifier projectProv) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: kCardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: kOutline),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove Instrument?',
                style: GoogleFonts.sourceSans3(
                  color: kPrimaryText,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'This will permanently delete this record from the balance.',
                style: GoogleFonts.sourceSans3(
                  color: kSecondaryText,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      projectProv.deleteEntry(widget.index);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: kError,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'DELETE',
                        style: GoogleFonts.ibmPlexMono(
                          color: kCardSurface,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
