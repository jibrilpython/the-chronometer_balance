import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_chronometer_balance/common/photo_bottom_sheet.dart';
import 'package:the_chronometer_balance/enum/my_enums.dart';
import 'package:the_chronometer_balance/providers/image_provider.dart';
import 'package:the_chronometer_balance/providers/input_provider.dart';
import 'package:the_chronometer_balance/providers/project_provider.dart';
import 'package:the_chronometer_balance/utils/const.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late TextEditingController _idCtrl;
  late TextEditingController _makerCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _precisionCtrl;
  late TextEditingController _materialsCtrl;
  late TextEditingController _dimCtrl;
  late TextEditingController _accCtrl;
  late TextEditingController _markCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(inputProvider);
    _idCtrl = TextEditingController(text: p.temporalIdentifier);
    _makerCtrl = TextEditingController(text: p.manufacturerAndMaker);
    _eraCtrl = TextEditingController(text: p.eraOfProduction);
    _precisionCtrl = TextEditingController(text: p.precisionRating);
    _materialsCtrl = TextEditingController(text: p.materials);
    _dimCtrl = TextEditingController(text: p.dimensionsAndWeight);
    _accCtrl = TextEditingController(text: p.includedAccessories);
    _markCtrl = TextEditingController(text: p.markingsAndStamps);
    _provCtrl = TextEditingController(text: p.provenance);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    for (final c in [
      _idCtrl, _makerCtrl, _eraCtrl, _precisionCtrl,
      _materialsCtrl, _dimCtrl, _accCtrl, _markCtrl,
      _provCtrl, _notesCtrl, _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() async {
    final p = ref.read(inputProvider);
    if (p.temporalIdentifier.trim().isEmpty ||
        p.manufacturerAndMaker.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Folio and Maker are required.',
            style: GoogleFonts.sourceSans3(color: kCardSurface),
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 600));

    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: kSecondaryText, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.isEdit ? 'Edit Register Entry' : 'New Register Entry'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
        children: [
          _buildPhotoModule(),
          SizedBox(height: 28.h),
          _sectionHeader('REGISTRATION'),
          _buildModule([
            _field(
              label: 'Register Folio',
              ctrl: _idCtrl,
              hint: 'TCB-DENT-1890-LONDON-022',
              onChanged: (v) => ref.read(inputProvider).temporalIdentifier = v,
            ),
            _field(
              label: 'Maker & Workshop',
              ctrl: _makerCtrl,
              hint: 'E. Dent & Co.',
              onChanged: (v) => ref.read(inputProvider).manufacturerAndMaker = v,
            ),
            _buildInstrumentTypePicker(),
            SizedBox(height: 16.h),
            _buildCountryPicker(),
          ]),
          SizedBox(height: 28.h),
          _sectionHeader('SPECIFICATIONS'),
          _buildModule([
            _field(
              label: 'Rate Accuracy',
              ctrl: _precisionCtrl,
              hint: '0.1 s/day',
              isMono: true,
              onChanged: (v) => ref.read(inputProvider).precisionRating = v,
            ),
            _buildOperatingPrinciplePicker(),
            SizedBox(height: 16.h),
            _field(
              label: 'Period of Manufacture',
              ctrl: _eraCtrl,
              hint: '1890s',
              isMono: true,
              inputFormatters: [const _EraInputFormatter()],
              onChanged: (v) => ref.read(inputProvider).eraOfProduction = v,
            ),
            _field(
              label: 'Material Composition',
              ctrl: _materialsCtrl,
              hint: 'Hardened steel, polished brass',
              onChanged: (v) => ref.read(inputProvider).materials = v,
            ),
            _field(
              label: 'Physical Dimensions',
              ctrl: _dimCtrl,
              hint: '12" x 8" x 6", 4.5 kg',
              isMono: true,
              onChanged: (v) => ref.read(inputProvider).dimensionsAndWeight = v,
            ),
          ]),
          SizedBox(height: 28.h),
          _sectionHeader('CONDITION & HISTORY'),
          _buildModule([
            _buildConditionPicker(),
            SizedBox(height: 16.h),
            _field(
              label: 'Accompanying Pieces',
              ctrl: _accCtrl,
              hint: 'Original wooden case, calibration weights',
              maxLines: 2,
              onChanged: (v) => ref.read(inputProvider).includedAccessories = v,
            ),
            _field(
              label: 'Marks & Signatures',
              ctrl: _markCtrl,
              hint: 'Royal Navy broad arrow, observatory marks',
              isMono: true,
              maxLines: 2,
              onChanged: (v) => ref.read(inputProvider).markingsAndStamps = v,
            ),
            _field(
              label: 'Chain of Custody',
              ctrl: _provCtrl,
              hint: 'Greenwich Observatory, HMS Victory',
              maxLines: 2,
              onChanged: (v) => ref.read(inputProvider).provenance = v,
            ),
            _field(
              label: 'Observations',
              ctrl: _notesCtrl,
              hint: 'Archival observations...',
              maxLines: 3,
              onChanged: (v) => ref.read(inputProvider).notes = v,
            ),
            _field(
              label: 'Subject Keywords',
              ctrl: _tagsCtrl,
              hint: 'observatory, naval, brass',
              isMono: true,
              onChanged: (v) => ref.read(inputProvider).tags =
                  v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            ),
          ]),
          SizedBox(height: 40.h),
          GestureDetector(
            onTap: _save,
            child: Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(kRadiusStandard),
              ),
              child: Center(
                child: Text(
                  widget.isEdit ? 'SAVE CHANGES' : 'COMMIT TO LEDGER',
                  style: GoogleFonts.ibmPlexMono(
                    color: kCardSurface,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoModule() {
    final imageProv = ref.watch(imageProvider);
    final displayPath = imageProv.getImagePath(imageProv.resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: kCardSurface,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: kOutline),
        ),
        clipBehavior: Clip.antiAlias,
        child: displayPath != null && File(displayPath).existsSync()
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(displayPath), fit: BoxFit.cover),
                  Positioned(
                    right: 8.w,
                    top: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: kCardSurface.withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit_rounded, color: kPrimaryText, size: 16.sp),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: kSecondaryText, size: 36.sp),
                  SizedBox(height: 8.h),
                  Text('Capture Plate',
                      style: GoogleFonts.sourceSans3(
                          color: kPrimaryText, fontSize: 15.sp)),
                  Text('Instrument documentation recommended',
                      style: GoogleFonts.sourceSans3(
                          color: kSecondaryText, fontSize: 11.sp)),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: 2.w),
      child: Text(title,
          style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildModule(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    bool isMono = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.sourceSans3(
                  color: kSecondaryText,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            style: isMono
                ? GoogleFonts.ibmPlexMono(color: kPrimaryText, fontSize: 13.sp)
                : GoogleFonts.sourceSans3(color: kPrimaryText, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder:
                  UnderlineInputBorder(borderSide: const BorderSide(color: kAccent)),
              contentPadding: EdgeInsets.symmetric(vertical: 6.h),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstrumentTypePicker() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instrument Class',
            style: GoogleFonts.sourceSans3(
                color: kSecondaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w, runSpacing: 6.h,
          children: InstrumentType.values.map((t) => GestureDetector(
            onTap: () => p.instrumentType = t,
            child: AnimatedContainer(
              duration: kTransitionDuration,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: p.instrumentType == t ? kAccent.withAlpha(20) : kBackground,
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(
                    color: p.instrumentType == t ? kAccent : kOutline),
              ),
              child: Text(t.label,
                  style: GoogleFonts.sourceSans3(
                      color: p.instrumentType == t ? kAccent : kSecondaryText,
                      fontSize: 11.sp)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCountryPicker() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('National Guild',
            style: GoogleFonts.sourceSans3(
                color: kSecondaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w, runSpacing: 6.h,
          children: CountryOfOrigin.values.map((c) => GestureDetector(
            onTap: () => p.countryOfOrigin = c,
            child: AnimatedContainer(
              duration: kTransitionDuration,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: p.countryOfOrigin == c ? kWalnut.withAlpha(20) : kBackground,
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(
                    color: p.countryOfOrigin == c ? kWalnut : kOutline),
              ),
              child: Text(c.label,
                  style: GoogleFonts.sourceSans3(
                      color: p.countryOfOrigin == c ? kWalnut : kSecondaryText,
                      fontSize: 11.sp)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildOperatingPrinciplePicker() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Movement Architecture',
            style: GoogleFonts.sourceSans3(
                color: kSecondaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w, runSpacing: 6.h,
          children: OperatingPrinciple.values.map((o) => GestureDetector(
            onTap: () => p.operatingPrinciple = o,
            child: AnimatedContainer(
              duration: kTransitionDuration,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: p.operatingPrinciple == o ? kAccent.withAlpha(20) : kBackground,
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(
                    color: p.operatingPrinciple == o ? kAccent : kOutline),
              ),
              child: Text(o.label,
                  style: GoogleFonts.sourceSans3(
                      color: p.operatingPrinciple == o ? kAccent : kSecondaryText,
                      fontSize: 11.sp)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildConditionPicker() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preservation State',
            style: GoogleFonts.sourceSans3(
                color: kSecondaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w, runSpacing: 6.h,
          children: ConditionState.values.map((s) => GestureDetector(
            onTap: () => p.conditionState = s,
            child: AnimatedContainer(
              duration: kTransitionDuration,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: p.conditionState == s
                    ? getConditionColor(s).withAlpha(20)
                    : kBackground,
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(
                    color: p.conditionState == s ? getConditionColor(s) : kOutline),
              ),
              child: Text(s.label,
                  style: GoogleFonts.sourceSans3(
                      color: p.conditionState == s ? kPrimaryText : kSecondaryText,
                      fontSize: 11.sp)),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _EraInputFormatter extends TextInputFormatter {
  const _EraInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (!RegExp(r'^[\ds]*$').hasMatch(text)) return oldValue;

    final digits = text.replaceAll('s', '');
    if (digits.length > 4) return oldValue;

    if (text.contains('s') && !text.endsWith('s')) return oldValue;

    if ('s'.allMatches(text).length > 1) return oldValue;

    return newValue;
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kCardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusStandard),
        side: const BorderSide(color: kOutline),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                color: kAccent, strokeWidth: 2),
            ),
            SizedBox(height: 16.h),
            Text('RECORDING INSTRUMENT...',
                style: GoogleFonts.ibmPlexMono(
                    color: kPrimaryText,
                    fontSize: 10.sp,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
