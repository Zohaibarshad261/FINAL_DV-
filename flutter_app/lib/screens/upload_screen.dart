import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_theme.dart';
import '../services/inference_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_header_bar.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _analyzing = false;
  String? _error;
  String _statusText = 'Analyzing...';
  final _auth = AuthService();
  final _picker = ImagePicker();

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source);
    if (xfile == null) return;
    setState(() {
      _selectedImage = File(xfile.path);
      _error = null;
    });
  }

  Future<void> _analyze() async {
    if (_selectedImage == null) {
      setState(() => _error = 'Please select an image first.');
      return;
    }
    final uid = _auth.userId;
    if (uid == null) {
      setState(() => _error = 'You must be logged in.');
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
      _statusText = 'Running AI analysis...';
    });

    try {
      // Step 1: Server-side inference (FastAPI + PyTorch)
      final result = await InferenceService.predict(_selectedImage!);

      if (mounted) setState(() => _statusText = 'Uploading image...');

      // Step 2: Upload image to Supabase Storage
      final bytes = await _selectedImage!.readAsBytes();
      final fileName = '$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('skin-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: false),
          );
      final imageUrl = Supabase.instance.client.storage
          .from('skin-images')
          .getPublicUrl(fileName);

      if (mounted) setState(() => _statusText = 'Saving report...');

      // Step 3: Save report directly to Supabase
      final confidence = (result['confidence'] as num).toDouble();
      final severityLevel =
          confidence >= 80 ? 'high' : confidence >= 50 ? 'medium' : 'low';

      await Supabase.instance.client.from('reports').insert({
        'user_id': uid,
        'disease_name': result['disease'],
        'confidence': confidence,
        'severity_level': severityLevel,
        'symptoms': result['symptoms'],
        'precautions': result['precautions'],
        'image_url': imageUrl,
      });

      if (mounted) {
        Navigator.pushNamed(context, '/result', arguments: result);
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: const BrandedAppBar(title: 'Scan Skin'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showSourceSheet(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppTheme.accentSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 38,
                                color: AppTheme.primary),
                          ),
                          const SizedBox(height: 16),
                          const Text('Tap to upload image',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 4),
                          const Text('JPG, PNG supported',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.file(_selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _sourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBED),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFE63946), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: Color(0xFFE63946), fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            _analyzing
                ? Column(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          height: 54,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppTheme.gradient,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                ),
                                const SizedBox(width: 10),
                                Text(_statusText,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: _selectedImage != null ? _analyze : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 54),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Analyze Image',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _sourceButton(
          {required IconData icon,
          required String label,
          required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primary, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E))),
            ],
          ),
        ),
      );

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _modalOption(Icons.camera_alt_rounded, 'Camera',
                () => _pickImage(ImageSource.camera)),
            _modalOption(Icons.photo_library_outlined, 'Gallery',
                () => _pickImage(ImageSource.gallery)),
          ],
        ),
      ),
    );
  }

  Widget _modalOption(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.accentSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 32),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E))),
          ],
        ),
      );
}
