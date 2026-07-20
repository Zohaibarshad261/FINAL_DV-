import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/app_header_bar.dart';
import '../models/report.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Report> _reports = [];
  bool _loading = true;
  String? _error;
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final uid = _auth.userId;
    if (uid == null) {
      setState(() {
        _error = AppLocalizations.of(context).notLoggedInError;
        _loading = false;
      });
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('reports')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      final reports = (data as List).map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
      setState(() { _reports = reports; _loading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: BrandedAppBar(
        title: l10n.myReportsTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? _errorState(l10n)
              : _reports.isEmpty
                  ? _emptyState(l10n)
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (_, i) => _reportCard(_reports[i], l10n),
                      ),
                    ),
    );
  }

  Widget _reportCard(Report report, AppLocalizations l10n) {
    final color = report.severityLevel == 'high'
        ? const Color(0xFFE63946)
        : report.severityLevel == 'medium'
            ? const Color(0xFFF4A261)
            : const Color(0xFF2DC653);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        leading: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        title: Text(report.diseaseName,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1A1A2E))),
        subtitle: Text(
          l10n.confidenceWithDate(
            report.confidence.toStringAsFixed(1),
            '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
          ),
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        trailing: report.imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  report.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
                ),
              )
            : const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
        children: [
          _expandedRow(l10n.symptomsLabel, report.symptoms),
          const SizedBox(height: 8),
          _expandedRow(l10n.precautionsLabel, report.precautions),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/chatbot',
                  arguments: {'disease': report.diseaseName}),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary, width: 2),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(l10n.askAiChatbot,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandedRow(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280), height: 1.5)),
        ],
      );

  Widget _emptyState(AppLocalizations l10n) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_outlined, size: 64, color: Color(0xFF6B7280)),
            const SizedBox(height: 14),
            Text(l10n.noReportsYet,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 6),
            Text(l10n.diagnosesWillAppearHere,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/upload'),
              child: Text(l10n.scanNow),
            ),
          ],
        ),
      );

  Widget _errorState(AppLocalizations l10n) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Color(0xFFE63946)),
            const SizedBox(height: 14),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _load, child: Text(l10n.retry)),
          ],
        ),
      );
}
