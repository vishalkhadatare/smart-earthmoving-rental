import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/firestore_equipment_model.dart';
import '../../home/models/equipment_model.dart';
import '../../home/widgets/equipment_image.dart';
import '../../provider/screens/provider_registration_screen.dart';
import '../services/equipment_service.dart';

/// Owner-facing equipment detail screen with Edit / Delete actions.
class OwnerEquipmentDetailScreen extends StatefulWidget {
  final FirestoreEquipmentModel equipment;
  const OwnerEquipmentDetailScreen({super.key, required this.equipment});

  @override
  State<OwnerEquipmentDetailScreen> createState() =>
      _OwnerEquipmentDetailScreenState();
}

class _OwnerEquipmentDetailScreenState
    extends State<OwnerEquipmentDetailScreen> {
  static const _accent = Color(0xFFFF6B00);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _green = Color(0xFF00C853);
  static const _fieldBg = Color(0xFFF5F5F8);
  static const _border = Color(0xFFEEEEF2);

  late FirestoreEquipmentModel _eq;
  bool _isEditing = false;
  bool _isLoading = false;

  // Controllers
  late TextEditingController _brandCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _capacityCtrl;
  late TextEditingController _hourlyRateCtrl;
  late TextEditingController _dailyRateCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _ownerNameCtrl;
  late TextEditingController _ownerPhoneCtrl;
  late MachineType _selectedType;
  String? _selectedDistrict;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _eq = widget.equipment;
    _initControllers();
  }

  void _initControllers() {
    _brandCtrl = TextEditingController(text: _eq.brand);
    _modelCtrl = TextEditingController(text: _eq.model);
    _capacityCtrl = TextEditingController(text: _eq.capacity);
    _hourlyRateCtrl = TextEditingController(
      text: _eq.hourlyRate.toStringAsFixed(0),
    );
    _dailyRateCtrl = TextEditingController(
      text: _eq.dailyRate > 0 ? _eq.dailyRate.toStringAsFixed(0) : '',
    );
    _descCtrl = TextEditingController(text: _eq.description);
    _ownerNameCtrl = TextEditingController(text: _eq.providerName);
    _ownerPhoneCtrl = TextEditingController(text: _eq.ownerPhone);
    _selectedType = _eq.machineType;
    _selectedDistrict = _eq.district.isNotEmpty ? _eq.district : null;
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
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────
  // UPDATE
  // ──────────────────────────────────────────────────────────────
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDistrict == null) {
      _toast('Please select a district');
      return;
    }

    setState(() => _isLoading = true);
    final prov = context.read<EquipmentProvider>();

    final updated = _eq.copyWith(
      machineType: _selectedType,
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      capacity: _capacityCtrl.text.trim(),
      hourlyRate:
          double.tryParse(_hourlyRateCtrl.text.trim()) ?? _eq.hourlyRate,
      dailyRate: double.tryParse(_dailyRateCtrl.text.trim()) ?? 0,
      district: _selectedDistrict!,
      description: _descCtrl.text.trim(),
      providerName: _ownerNameCtrl.text.trim(),
      ownerPhone: _ownerPhoneCtrl.text.trim(),
    );

    final ok = await prov.updateEquipment(updated);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      setState(() {
        _eq = updated;
        _isEditing = false;
      });
      _toast('Equipment updated successfully!', success: true);
    } else {
      _toast(prov.errorMessage ?? 'Update failed');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // DELETE
  // ──────────────────────────────────────────────────────────────
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Equipment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${_eq.brand} ${_eq.machineType.value}"? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    final prov = context.read<EquipmentProvider>();
    final ok = await prov.deleteEquipment(_eq.id);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      Navigator.pop(context, true); // return true to signal deletion
    } else {
      _toast(prov.errorMessage ?? 'Delete failed');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // TOGGLE AVAILABILITY
  // ──────────────────────────────────────────────────────────────
  Future<void> _toggleAvailability() async {
    final newStatus = !_eq.availabilityStatus;
    final prov = context.read<EquipmentProvider>();
    await prov.toggleAvailability(_eq.id, newStatus);
    if (!mounted) return;
    setState(() {
      _eq = _eq.copyWith(availabilityStatus: newStatus);
    });
    _toast(
      newStatus
          ? 'Equipment marked as available'
          : 'Equipment marked as unavailable',
      success: true,
    );
  }

  void _toast(String m, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: success ? _green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final uiModel = EquipmentModel.fromFirestoreModel(_eq);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: _dark),
          onPressed: () {
            if (_isEditing) {
              setState(() => _isEditing = false);
              _initControllers();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _isEditing ? 'Edit Equipment' : 'Equipment Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: _dark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (v) {
                switch (v) {
                  case 'edit':
                    setState(() => _isEditing = true);
                    break;
                  case 'toggle':
                    _toggleAvailability();
                    break;
                  case 'delete':
                    _confirmDelete();
                    break;
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded, size: 20, color: _accent),
                      const SizedBox(width: 10),
                      Text('Edit', style: GoogleFonts.poppins(fontSize: 14)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        _eq.availabilityStatus
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _eq.availabilityStatus
                            ? 'Mark Unavailable'
                            : 'Mark Available',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_rounded,
                        size: 20,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : _isEditing
          ? _buildEditForm()
          : _buildDetailView(uiModel),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // DETAIL VIEW (read-only)
  // ──────────────────────────────────────────────────────────────
  Widget _buildDetailView(EquipmentModel e) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image carousel
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: 220,
              color: const Color(0xFFF3F3F3),
              child: e.hasNetworkImages
                  ? PageView.builder(
                      itemCount: e.imageUrls.length,
                      itemBuilder: (_, i) => Image.network(
                        e.imageUrls[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => EquipmentImage(
                          imageUrls: const [],
                          fallbackAsset: e.imageAsset,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 220,
                        ),
                      ),
                    )
                  : EquipmentImage(
                      imageUrls: const [],
                      fallbackAsset: e.imageAsset,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 220,
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _eq.availabilityStatus
                      ? _green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _eq.availabilityStatus ? 'Available' : 'Unavailable',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _eq.availabilityStatus ? _green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _eq.machineType.value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name & model
          Text(
            e.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Model: ${e.model}',
            style: GoogleFonts.poppins(fontSize: 14, color: _sub),
          ),
          const SizedBox(height: 20),

          // Price cards
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  'Hourly Rate',
                  '₹${_eq.hourlyRate.toStringAsFixed(0)}/hr',
                  _accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoCard(
                  'Daily Rate',
                  _eq.dailyRate > 0
                      ? '₹${_eq.dailyRate.toStringAsFixed(0)}/day'
                      : 'N/A',
                  const Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details section
          _sectionTitle('Details'),
          const SizedBox(height: 10),
          _detailRow(Icons.location_on_outlined, 'District', _eq.district),
          if (_eq.capacity.isNotEmpty)
            _detailRow(Icons.speed_rounded, 'Capacity', _eq.capacity),
          if (_eq.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _eq.description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: _sub,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Owner info
          _sectionTitle('Owner Info'),
          const SizedBox(height: 10),
          _detailRow(
            Icons.person_outline_rounded,
            'Name',
            _eq.providerName.isNotEmpty ? _eq.providerName : 'Not set',
          ),
          _detailRow(
            Icons.phone_outlined,
            'Phone',
            _eq.ownerPhone.isNotEmpty ? _eq.ownerPhone : 'Not set',
          ),
          const SizedBox(height: 30),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side: const BorderSide(color: _accent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleAvailability,
                  icon: Icon(
                    _eq.availabilityStatus
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _eq.availabilityStatus ? 'Disable' : 'Enable',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueGrey,
                    side: const BorderSide(color: Colors.blueGrey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: Text(
                'Delete Equipment',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: _sub)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: _dark,
    ),
  );

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _accent),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _dark,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13, color: _sub),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // EDIT FORM
  // ──────────────────────────────────────────────────────────────
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Machine Type
            _label('Machine Type *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<MachineType>(
              initialValue: _selectedType,
              decoration: _dropdownDecoration('Select Machine Type'),
              items: MachineType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.value)))
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

            // Owner Details
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

            // Save / Cancel buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _isEditing = false);
                      _initControllers();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _sub,
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _accent.withValues(alpha: 0.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ──── Shared widgets ──────────────────────────────────────────

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
