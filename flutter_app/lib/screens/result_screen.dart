import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ResultScreen({super.key, required this.data});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;

  late String _symptoms;
  late String _precautions;
  bool _translating = false;

  String get disease => widget.data['disease'] as String? ?? 'Unknown';
  double get confidence => (widget.data['confidence'] as num?)?.toDouble() ?? 0;
  List<Map<String, dynamic>> get topPredictions =>
      (widget.data['topPredictions'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ??
      [];

  List<String> get rawLogits =>
      (widget.data['rawLogits'] as List?)?.cast<String>() ?? [];

  Color get severityColor {
    if (confidence >= 80) return const Color(0xFFE63946);
    if (confidence >= 50) return const Color(0xFFF4A261);
    return const Color(0xFF2DC653);
  }

  @override
  void initState() {
    super.initState();
    _symptoms = widget.data['symptoms'] as String? ?? '';
    _precautions = widget.data['precautions'] as String? ?? '';
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut);
    _ringCtrl.forward();
    if (!LanguageService.isEnglish) _translateContent();
  }

  Future<void> _translateContent() async {
    setState(() => _translating = true);
    try {
      final lang = LanguageService.language.value;
      final s = await ApiService.translate(text: _symptoms, targetLanguage: lang);
      final p = await ApiService.translate(text: _precautions, targetLanguage: lang);
      if (mounted) setState(() { _symptoms = s; _precautions = p; });
    } catch (_) {}
    if (mounted) setState(() => _translating = false);
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  List<String> _split(String s) =>
      s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: const Color(0xFF1A1A2E)),
        title: const Text('Diagnosis Result',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Confidence ring card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _ringAnim,
                    builder: (_, __) => CustomPaint(
                      size: const Size(160, 160),
                      painter: _RingPainter(
                        progress: _ringAnim.value * (confidence / 100),
                        color: severityColor,
                      ),
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(confidence * _ringAnim.value).toStringAsFixed(0)}%',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: severityColor),
                              ),
                              const Text('confidence',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(disease,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      confidence >= 80
                          ? 'High Severity'
                          : confidence >= 50
                              ? 'Medium Severity'
                              : 'Low Severity',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: severityColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Symptoms
            _translating
                ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: Color(0xFF0B6E6E)),
                  ))
                : _infoCard(
                    title: 'Symptoms',
                    icon: Icons.sick_outlined,
                    chips: _split(_symptoms),
                    chipColor: const Color(0xFFFFEBED),
                    chipTextColor: const Color(0xFFE63946),
                  ),
            const SizedBox(height: 16),

            // Precautions
            if (!_translating)
              _infoCard(
                title: 'Precautions',
                icon: Icons.shield_outlined,
                chips: _split(_precautions),
                chipColor: const Color(0xFFE8F8F0),
                chipTextColor: const Color(0xFF2DC653),
              ),
            const SizedBox(height: 16),

            // Top-5 predictions (debug)
            if (topPredictions.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            color: Color(0xFF0B6E6E), size: 20),
                        SizedBox(width: 8),
                        Text('Top Predictions',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...topPredictions.map((p) {
                      final label = p['label'] as String;
                      final conf = (p['confidence'] as num).toDouble();
                      final isTop = label == disease;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(label,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isTop
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isTop
                                          ? const Color(0xFF0B6E6E)
                                          : const Color(0xFF6B7280))),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: conf / 100,
                                  minHeight: 6,
                                  backgroundColor:
                                      const Color(0xFFE5E7EB),
                                  valueColor: AlwaysStoppedAnimation(
                                      isTop
                                          ? const Color(0xFF0B6E6E)
                                          : const Color(0xFF9CA3AF)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 44,
                              child: Text('${conf.toStringAsFixed(1)}%',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isTop
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isTop
                                          ? const Color(0xFF0B6E6E)
                                          : const Color(0xFF6B7280))),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Raw logits debug card
            if (rawLogits.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Raw Logits (copy to compare with Python)',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00FF99))),
                    const SizedBox(height: 10),
                    ...rawLogits.map((line) => Text(
                          line,
                          style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Colors.white70),
                        )),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // CTA buttons
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF0B6E6E), Color(0xFF1A9E9E)]),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/doctors',
                    arguments: {'disease': disease}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.location_on_outlined,
                    color: Colors.white),
                label: const Text('Find Nearby Doctors',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/chatbot',
                  arguments: {'disease': disease}),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0B6E6E),
                side: const BorderSide(color: Color(0xFF0B6E6E), width: 2),
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

  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<String> chips,
    required Color chipColor,
    required Color chipTextColor,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0B6E6E), size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E))),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map((chip) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: chipColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(chip,
                            style: TextStyle(
                                fontSize: 12,
                                color: chipTextColor,
                                fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 14;
    const strokeWidth = 12.0;

    // Background track
    final trackPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
