import 'package:flutter/material.dart';

/// DermaVision+ visual theme — crisp white & blue palette.
/// Chosen for strong contrast under bright projector/auditorium lighting.
class AppTheme {
  AppTheme._();

  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const primaryLight = Color(0xFF42A5F5);
  static const accent = Color(0xFFDCEEFF);
  static const accentSoft = Color(0xFFEFF7FF);
  static const bg = Color(0xFFF7FBFF);
  static const textPrimary = Color(0xFF10223B);
  static const textMuted = Color(0xFF5B6B79);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
  );

  static const gradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
  );

  static const cardShadow = [
    BoxShadow(
      color: Color(0x1A1565C0),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const softShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const supportedDiseases = [
    'Acne',
    'Actinic Keratosis',
    'Benign Tumors',
    'Bullous',
    'Candidiasis',
    'Drug Eruption',
    'Eczema',
    'Infestations/Bites',
    'Lichen',
    'Lupus',
    'Moles',
    'Psoriasis',
    'Rosacea',
    'Seborrheic Keratoses',
    'Skin Cancer',
    'Sun/Sunlight Damage',
    'Tinea',
    'Unknown/Normal',
    'Vascular Tumors',
    'Vasculitis',
    'Vitiligo',
    'Warts',
  ];

  static int get diseaseCount => supportedDiseases.length;

  static IconData iconFor(String disease) {
    switch (disease) {
      case 'Acne':
        return Icons.face_retouching_natural_rounded;
      case 'Actinic Keratosis':
        return Icons.wb_sunny_rounded;
      case 'Benign Tumors':
        return Icons.bubble_chart_rounded;
      case 'Bullous':
        return Icons.water_drop_rounded;
      case 'Candidiasis':
        return Icons.coronavirus_rounded;
      case 'Drug Eruption':
        return Icons.medication_rounded;
      case 'Eczema':
        return Icons.dry_rounded;
      case 'Infestations/Bites':
        return Icons.bug_report_rounded;
      case 'Lichen':
        return Icons.grain_rounded;
      case 'Lupus':
        return Icons.brightness_7_rounded;
      case 'Moles':
        return Icons.circle_rounded;
      case 'Psoriasis':
        return Icons.layers_rounded;
      case 'Rosacea':
        return Icons.face_rounded;
      case 'Seborrheic Keratoses':
        return Icons.texture_rounded;
      case 'Skin Cancer':
        return Icons.warning_amber_rounded;
      case 'Sun/Sunlight Damage':
        return Icons.light_mode_rounded;
      case 'Tinea':
        return Icons.all_inclusive_rounded;
      case 'Unknown/Normal':
        return Icons.check_circle_outline_rounded;
      case 'Vascular Tumors':
        return Icons.bloodtype_rounded;
      case 'Vasculitis':
        return Icons.monitor_heart_rounded;
      case 'Vitiligo':
        return Icons.contrast_rounded;
      case 'Warts':
        return Icons.scatter_plot_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  static Color chipColor(int index) {
    const palette = [
      Color(0xFF1E88E5),
      Color(0xFF0097A7),
      Color(0xFF3949AB),
      Color(0xFF0277BD),
      Color(0xFF00ACC1),
      Color(0xFF5C6BC0),
    ];
    return palette[index % palette.length];
  }
}
