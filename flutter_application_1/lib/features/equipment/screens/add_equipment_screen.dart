import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../models/firestore_equipment_model.dart';
import '../../equipment/services/equipment_service.dart';
import '../../provider/screens/provider_registration_screen.dart';

/// Screen for providers to add new equipment/machine
class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _hourlyRateCtrl = TextEditingController();
  final _dailyRateCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  // Specification controllers
  final _companyCtrl = TextEditingController();
  final _soilTypeCtrl = TextEditingController();
  final _depthCtrl = TextEditingController();
  final _enginePowerCtrl = TextEditingController();
  final _bucketCapacityCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _operatingWeightCtrl = TextEditingController();
  MachineType _selectedType = MachineType.excavator;
  String? _selectedDistrict;
  bool _isLoading = false;
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  static const _accent = Color(0xFFFF6B00);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _bg = Color(0xFFFAFAFC);
  static const _fieldBg = Color(0xFFF5F5F8);
  static const _border = Color(0xFFEEEEF2);

  @override
  void initState() {
    super.initState();
    // Pre-fill owner name from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _ownerNameCtrl.text = user.displayName ?? '';
      _ownerPhoneCtrl.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _capacityCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _dailyRateCtrl.dispose();
    _descCtrl.dispose();
    _ownerNameCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _companyCtrl.dispose();
    _soilTypeCtrl.dispose();
    _depthCtrl.dispose();
    _enginePowerCtrl.dispose();
    _bucketCapacityCtrl.dispose();
    _areaCtrl.dispose();
    _operatingWeightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        if (_selectedImages.length > 5) {
          _selectedImages.removeRange(5, _selectedImages.length);
          _toast('Maximum 5 images allowed');
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (photo != null) {
      if (_selectedImages.length >= 5) {
        _toast('Maximum 5 images allowed');
        return;
      }
      setState(() => _selectedImages.add(photo));
    }
  }

  Future<void> _pickFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final remaining = 5 - _selectedImages.length;
      final filesToAdd = result.files.take(remaining);
      setState(() {
        for (final f in filesToAdd) {
          if (f.path != null) {
            _selectedImages.add(XFile(f.path!, name: f.name));
          }
        }
        if (result.files.length > remaining) {
          _toast('Maximum 5 images allowed');
        }
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    debugPrint(
      '📸 Uploading ${_selectedImages.length} images to Cloudinary (folder: equipment/$uid)...',
    );
    // Upload to Cloudinary under equipment/<uid> folder
    final urls = await CloudinaryService.instance.uploadMultiple(
      _selectedImages,
      folder: 'equipment/$uid',
    );
    debugPrint('📸 Cloudinary upload done. URLs: $urls');
    return urls;
  }

  Future<void> _addEquipment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDistrict == null) {
      _toast('Please select a district');
      return;
    }

    setState(() => _isLoading = true);

    // Capture provider reference before async gap
    final equipmentProvider = context.read<EquipmentProvider>();

    try {
      // Upload images to Cloudinary
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        try {
          imageUrls = await _uploadImages();
          debugPrint('✅ Got ${imageUrls.length} image URLs from Cloudinary');
        } catch (e) {
          debugPrint('❌ Image upload failed: $e');
          if (!mounted) return;
          // Show warning but let user decide to continue
          final continueWithout = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Image Upload Failed',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              content: Text(
                'Could not upload images. Would you like to add equipment without photos?\n\nError: $e',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(tr('cancel'), style: GoogleFonts.poppins()),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    tr('continue_without_photos'),
                    style: GoogleFonts.poppins(
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
          if (continueWithout != true) {
            setState(() => _isLoading = false);
            return;
          }
        }
      }

      debugPrint(
        '🔧 Calling equipmentProvider.addEquipment with ${imageUrls.length} images...',
      );
      debugPrint(
        '🔧 providerName: ${_ownerNameCtrl.text.trim()}, phone: ${_ownerPhoneCtrl.text.trim()}',
      );

      final ok = await equipmentProvider.addEquipment(
        machineType: _selectedType,
        brand: _brandCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        capacity: _capacityCtrl.text.trim(),
        hourlyRate: double.tryParse(_hourlyRateCtrl.text.trim()) ?? 0,
        dailyRate: double.tryParse(_dailyRateCtrl.text.trim()) ?? 0,
        district: _selectedDistrict!,
        latitude: 19.0760,
        longitude: 72.8777,
        machineImages: imageUrls,
        description: _descCtrl.text.trim(),
        providerName: _ownerNameCtrl.text.trim(),
        ownerPhone: _ownerPhoneCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        soilType: _soilTypeCtrl.text.trim(),
        depth: _depthCtrl.text.trim(),
        enginePower: _enginePowerCtrl.text.trim(),
        bucketCapacity: _bucketCapacityCtrl.text.trim(),
        area: _areaCtrl.text.trim(),
        operatingWeight: _operatingWeightCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('equipment_added_success')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        _toast(equipmentProvider.errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _toast('Failed to add equipment: $e');
    }
  }

  void _toast(String? m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m ?? 'Something went wrong'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on locale change
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('post_equipment'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── PHOTOS SECTION ───
              _label('Equipment Photos'),
              const SizedBox(height: 4),
              Text(
                'Add up to 5 photos of your equipment',
                style: GoogleFonts.poppins(fontSize: 12, color: _sub),
              ),
              const SizedBox(height: 12),
              _buildImagePicker(),
              const SizedBox(height: 24),

              // Machine Type
              _label('Machine Type *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<MachineType>(
                initialValue: _selectedType,
                decoration: _dropdownDecoration('Select Machine Type'),
                items: MachineType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.value)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
                style: GoogleFonts.poppins(fontSize: 15, color: _dark),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 20),

              // Brand
              _label('Brand *'),
              const SizedBox(height: 8),
              _field(
                ctrl: _brandCtrl,
                hint: 'e.g. CAT, Komatsu, JCB',
                icon: Icons.precision_manufacturing_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Brand is required' : null,
              ),
              const SizedBox(height: 20),

              // Model
              _label('Model *'),
              const SizedBox(height: 8),
              _field(
                ctrl: _modelCtrl,
                hint: 'e.g. 320D2, 3DX Super',
                icon: Icons.numbers_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Model is required' : null,
              ),
              const SizedBox(height: 20),

              // Capacity
              _label('Capacity'),
              const SizedBox(height: 8),
              _field(
                ctrl: _capacityCtrl,
                hint: 'e.g. 20 Ton, 150 HP',
                icon: Icons.speed_rounded,
              ),
              const SizedBox(height: 20),

              // Hourly Rate
              _label('Hourly Rate (₹) *'),
              const SizedBox(height: 8),
              _field(
                ctrl: _hourlyRateCtrl,
                hint: 'e.g. 2500',
                icon: Icons.currency_rupee_rounded,
                kb: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Rate is required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Daily Rate
              _label('Daily Rate (₹)'),
              const SizedBox(height: 8),
              _field(
                ctrl: _dailyRateCtrl,
                hint: 'e.g. 15000',
                icon: Icons.currency_rupee_rounded,
                kb: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // District
              _label('Equipment Location District *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDistrict,
                decoration: _dropdownDecoration('Select District'),
                items: IndianDistricts.districts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDistrict = v),
                validator: (v) => v == null ? 'District is required' : null,
                style: GoogleFonts.poppins(fontSize: 15, color: _dark),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 20),

              // Description
              _label('Description'),
              const SizedBox(height: 8),
              _field(
                ctrl: _descCtrl,
                hint: 'Describe your equipment...',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // ─── SPECIFICATION PARAMETERS ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.settings_outlined,
                          size: 20,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Specification Parameters',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Technical details help users choose the right equipment',
                      style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                    ),
                    const SizedBox(height: 14),
                    _label('Company'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _companyCtrl,
                      hint: 'e.g. Tata, L&T, Volvo',
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 14),
                    _label('Soil Type'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _soilTypeCtrl,
                      hint: 'e.g. Clay, Sandy, Rocky',
                      icon: Icons.landscape_outlined,
                    ),
                    const SizedBox(height: 14),
                    _label('Depth'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _depthCtrl,
                      hint: 'e.g. 6m, 12 feet',
                      icon: Icons.vertical_align_bottom_rounded,
                    ),
                    const SizedBox(height: 14),
                    _label('Engine Power'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _enginePowerCtrl,
                      hint: 'e.g. 120 HP, 90 kW',
                      icon: Icons.bolt_rounded,
                    ),
                    const SizedBox(height: 14),
                    _label('Bucket Capacity'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _bucketCapacityCtrl,
                      hint: 'e.g. 0.9 m³, 1.2 m³',
                      icon: Icons.water_outlined,
                    ),
                    const SizedBox(height: 14),
                    _label('Area'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _areaCtrl,
                      hint: 'e.g. 500 sqft, 2 acres/hr',
                      icon: Icons.crop_square_rounded,
                    ),
                    const SizedBox(height: 14),
                    _label('Operating Weight'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _operatingWeightCtrl,
                      hint: 'e.g. 20 Ton, 8500 kg',
                      icon: Icons.scale_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── OWNER DETAILS SECTION ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accent.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: _accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Owner Details',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This info will be visible to users who view your equipment',
                      style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                    ),
                    const SizedBox(height: 14),
                    _label('Your Name *'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _ownerNameCtrl,
                      hint: 'e.g. Rajesh Kumar',
                      icon: Icons.badge_outlined,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _label('Contact Number *'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _ownerPhoneCtrl,
                      hint: 'e.g. +91 98765 43210',
                      icon: Icons.phone_outlined,
                      kb: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addEquipment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _accent.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Add Equipment',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        // Selected images preview
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                final file = _selectedImages[index];
                return Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: kIsWeb
                            ? FutureBuilder<Uint8List>(
                                future: file.readAsBytes(),
                                builder: (ctx, snap) {
                                  if (!snap.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _accent,
                                      ),
                                    );
                                  }
                                  return Image.memory(
                                    snap.data!,
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 110,
                                  );
                                },
                              )
                            : Image.file(
                                File(file.path),
                                fit: BoxFit.cover,
                                width: 110,
                                height: 110,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 14,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedImages.removeAt(index));
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Cover',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        if (_selectedImages.isNotEmpty) const SizedBox(height: 12),
        // Add photo buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedImages.length >= 5 ? null : _pickImages,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: Text(
                  'Gallery',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accent,
                  side: const BorderSide(color: _accent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedImages.length >= 5 ? null : _takePhoto,
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: Text(
                  'Camera',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accent,
                  side: const BorderSide(color: _accent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedImages.length >= 5 ? null : _pickFromFiles,
                icon: const Icon(Icons.folder_open_outlined, size: 18),
                label: Text(
                  'Files',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accent,
                  side: const BorderSide(color: _accent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_selectedImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${_selectedImages.length}/5 photos selected',
              style: GoogleFonts.poppins(fontSize: 11, color: _sub),
            ),
          ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 14, color: _sub),
    prefixIcon: const Icon(Icons.category_outlined, color: _accent, size: 20),
    filled: true,
    fillColor: _fieldBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _accent, width: 1.5),
    ),
  );

  Widget _label(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _dark,
    ),
  );

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType? kb,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: kb,
    validator: validator,
    maxLines: maxLines,
    style: GoogleFonts.poppins(fontSize: 15, color: _dark),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: _sub.withValues(alpha: 0.5),
      ),
      prefixIcon: Icon(icon, color: _accent, size: 20),
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
  );
}
