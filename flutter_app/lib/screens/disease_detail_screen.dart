import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../app_theme.dart';
import '../widgets/app_header_bar.dart';

/// Overview page for a single condition — shown when a disease is tapped
/// anywhere in the app (chip, preview grid, or "view all" sheet).
class DiseaseDetailScreen extends StatefulWidget {
  final String name;
  final int index;

  const DiseaseDetailScreen({super.key, required this.name, required this.index});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  Map<String, dynamic>? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final raw = await rootBundle.loadString('assets/disease_info.json');
      final map = json.decode(raw) as Map<String, dynamic>;
      setState(() {
        _info = map[widget.name] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<String> _split(String? s) =>
      (s ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.chipColor(widget.index);
    final icon = AppTheme.iconFor(widget.name);
    final overview = _info?['overview'] as String? ??
        'Detailed information about this condition is not available yet.';
    final symptoms = _split(_info?['symptoms'] as String?);
    final precautions = _split(_info?['precautions'] as String?);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: BrandedAppBar(title: widget.name),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerBanner(color, icon),
                  const SizedBox(height: 20),
                  _visualReferenceRow(color, icon),
                  const SizedBox(height: 20),
                  _sectionCard(
                    title: 'Overview',
                    icon: Icons.info_outline_rounded,
                    color: color,
                    child: Text(
                      overview,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.6,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (symptoms.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _chipCard(
                      title: 'Symptoms',
                      icon: Icons.sick_outlined,
                      color: color,
                      chips: symptoms,
                    ),
                  ],
                  if (precautions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _chipCard(
                      title: 'Precautions',
                      icon: Icons.shield_outlined,
                      color: color,
                      chips: precautions,
                    ),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/chatbot',
                        arguments: {'disease': widget.name}),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary, width: 2),
                      minimumSize: const Size(double.infinity, 54),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Ask AI Chatbot',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _headerBanner(Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Condition overview',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _slug(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  List<String> _imagePaths() {
    final slug = _slug(widget.name);
    return [
      'assets/images/diseases/${slug}_1.jpg',
      'assets/images/diseases/${slug}_2.jpg',
    ];
  }

  /// Two reference photo cards; falls back to an icon tile if an image
  /// hasn't been supplied for this condition yet.
  Widget _visualReferenceRow(Color color, IconData icon) {
    Widget fallback() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.08)],
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 34),
        );

    Widget card(String path) => Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: color.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback(),
              ),
            ),
          ),
        );

    final paths = _imagePaths();
    return Row(
      children: [
        card(paths[0]),
        const SizedBox(width: 12),
        card(paths[1]),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );

  Widget _chipCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> chips,
  }) =>
      _sectionCard(
        title: title,
        icon: icon,
        color: color,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips
              .map((chip) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(chip,
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500)),
                  ))
              .toList(),
        ),
      );
}
