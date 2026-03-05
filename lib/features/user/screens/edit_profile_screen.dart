import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/services/cloudinary_service.dart';
import '../../../core/utils/safe_state.dart';

import '../models/user_profile_model.dart';
import '../providers/user_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends SafeState<EditProfileScreen> {
  // styling constants copied from profile page so edit screen matches
  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _accent = Color(0xFF3B82F6);
  static const Color _card = Colors.white;

  final _formKey = GlobalKey<FormState>();
  // contractor details
  String _contractorType = 'Civil Contractor';
  String _contractorClass = 'Class A';
  final _yearsExpCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  // basic information
  final _fullNameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _photoUrl;

  // image picker state
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  // helper for initial letter avatar (copied from user_shell)
  Widget _initial(String name) => Center(
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'U',
      style: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: _accent,
      ),
    ),
  );

  String? _originalPhone;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Delay loading until after first frame to avoid rebuild during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<UserProfileProvider>();
      prov.loadProfile();
    });
  }

  @override
  void dispose() {
    _yearsExpCtrl.dispose();
    _licenseCtrl.dispose();
    _gstCtrl.dispose();
    _fullNameCtrl.dispose();
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _populateFields(UserProfileModel? profile) {
    if (profile == null) return;
    _contractorType = profile.contractorType.isNotEmpty
        ? profile.contractorType
        : _contractorType;
    _contractorClass = profile.contractorClass.isNotEmpty
        ? profile.contractorClass
        : _contractorClass;
    _yearsExpCtrl.text = profile.yearsExperience.toString();
    _licenseCtrl.text = profile.licenseNumber;
    _gstCtrl.text = profile.gstNumber;
    _fullNameCtrl.text = profile.fullName;
    _companyCtrl.text = profile.companyName;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.mobileNumber;
    _originalPhone = profile.mobileNumber;
    _photoUrl = profile.photoUrl;
    // if there's an existing url we don't have a local file
    _pickedImage = null;
  }

  Future<bool> _verifyPhone(String newPhone) async {
    final completer = Completer<bool>();
    String? verificationId;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: newPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await FirebaseAuth.instance.currentUser?.updatePhoneNumber(
            credential,
          );
          completer.complete(true);
        } catch (e) {
          completer.complete(false);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.complete(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone verification failed: ${e.message}')),
          );
        }
      },
      codeSent: (String vid, int? _) async {
        verificationId = vid;
        final sms = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            final otpCtrl = TextEditingController();
            return AlertDialog(
              title: const Text('Enter OTP'),
              content: TextField(
                controller: otpCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '6-digit code'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, otpCtrl.text.trim());
                  },
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
        if (sms == null || sms.isEmpty) {
          completer.complete(false);
          return;
        }
        try {
          final cred = PhoneAuthProvider.credential(
            verificationId: verificationId!,
            smsCode: sms,
          );
          await FirebaseAuth.instance.currentUser?.updatePhoneNumber(cred);
          completer.complete(true);
        } catch (e) {
          completer.complete(false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP verification failed')),
            );
          }
        }
      },
      codeAutoRetrievalTimeout: (String vid) {
        verificationId = vid;
      },
    );

    return completer.future;
  }

  // -------- photo helpers --------
  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _pickedImage = image;
        _photoUrl = null;
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
      setState(() {
        _pickedImage = photo;
        _photoUrl = null;
      });
    }
  }

  Future<void> _pickFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final f = result.files.first;
      if (f.path != null) {
        setState(() {
          _pickedImage = XFile(f.path!, name: f.name);
          _photoUrl = null;
        });
      }
    }
  }

  void _showPhotoOptions() {
    // hide keyboard/ remove focus before opening picker sheet
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            // always allow file picker so users can browse storage on any platform
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Files'),
              onTap: () {
                Navigator.pop(context);
                _pickFromFiles();
              },
            ),
          ],
        ),
      ),
    );
  }

  // this returns the avatar widget used in the gradient header
  Widget _avatarWidget(String? name) {
    if (_pickedImage != null) {
      return Image.file(
        File(_pickedImage!.path),
        fit: BoxFit.cover,
        width: 90,
        height: 90,
      );
    } else if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return Image.network(
        _photoUrl!,
        fit: BoxFit.cover,
        width: 90,
        height: 90,
        errorBuilder: (_, __, ___) => _initial(name ?? ''),
      );
    } else {
      return _initial(name ?? '');
    }
  }

  // header containing avatar and upload control, styled like Profile page
  Widget _buildHeader(String name, String? email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPhotoOptions,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(child: _avatarWidget(name)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, size: 16, color: _accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (name.isNotEmpty)
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) setState(() => _isSubmitting = true);

    // phone update
    if (_originalPhone != null && _phoneCtrl.text.trim() != _originalPhone) {
      final ok = await _verifyPhone(_phoneCtrl.text.trim());
      if (!ok) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }
    }

    // if user picked a new image, upload it first
    if (_pickedImage != null) {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final url = await CloudinaryService.instance.uploadImage(
          _pickedImage!,
          folder: 'profiles/$uid',
        );
        _photoUrl = url;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
        }
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }
    }

    final auth = context.read<AuthProvider>();

    final profile = UserProfileModel(
      uid: FirebaseAuth.instance.currentUser?.uid ?? '',
      contractorType: _contractorType,
      contractorClass: _contractorClass,
      yearsExperience: int.tryParse(_yearsExpCtrl.text.trim()) ?? 0,
      licenseNumber: _licenseCtrl.text.trim(),
      gstNumber: _gstCtrl.text.trim(),
      fullName: _fullNameCtrl.text.trim(),
      companyName: _companyCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      mobileNumber: _phoneCtrl.text.trim(),
      photoUrl: _photoUrl,
    );

    final updated = await context.read<UserProfileProvider>().updateProfile(
      profile,
    );

    if (updated) {
      // also update auth basic
      await auth.updateUserProfile(
        name: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        photoUrl: _photoUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
      // no need to call setState after pop
      return;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<UserProfileProvider>().errorMessage ??
                  'Update failed',
            ),
          ),
        );
      }
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProfileProvider>();
    if (userProv.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // populate once
    if (userProv.profile != null && _fullNameCtrl.text.isEmpty) {
      _populateFields(userProv.profile);
    }

    // grab user info for header
    final auth = Provider.of<AuthProvider>(context);
    final name = _fullNameCtrl.text.isNotEmpty
        ? _fullNameCtrl.text
        : auth.userName;
    final email = _emailCtrl.text.isNotEmpty ? _emailCtrl.text : auth.userEmail;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(name, email),
                  const SizedBox(height: 24),
                  Card(
                    color: _card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Contractor Details',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _contractorType,
                              decoration: const InputDecoration(
                                labelText: 'Contractor Type',
                              ),
                              items:
                                  [
                                        'Civil Contractor',
                                        'Infrastructure Contractor',
                                        'Road Contractor',
                                        'Residential Builder',
                                      ]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) =>
                                  setState(() => _contractorType = v!),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _contractorClass,
                              decoration: const InputDecoration(
                                labelText: 'Contractor Class',
                              ),
                              items:
                                  ['Class A', 'Class B', 'Class C', 'Class D']
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) =>
                                  setState(() => _contractorClass = v!),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _yearsExpCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Years of Experience',
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _licenseCtrl,
                              decoration: const InputDecoration(
                                labelText: 'License Number (optional)',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _gstCtrl,
                              decoration: const InputDecoration(
                                labelText: 'GST Number (optional)',
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Basic Information',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _fullNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _companyCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Company Name',
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                final regex = RegExp(r"^[^@]+@[^@]+\\.[^@]+$");
                                if (!regex.hasMatch(v)) return 'Invalid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Number',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submit,
                                child: _isSubmitting
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('Save Changes'),
                              ),
                            ),
                          ], // inner Column children
                        ), // Column (inner)
                      ), // Form
                    ), // Padding
                  ), // Card
                ], // outer Column children
              ), // Column (outer)
            ), // ConstrainedBox
          ), // Center
        ), // SingleChildScrollView
      ), // SafeArea
    ); // Scaffold
  }
}
