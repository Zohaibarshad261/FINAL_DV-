import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
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
      setState(() { _error = 'Not logged in.'; _loading = false; });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: const Color(0xFF1A1A2E)),
        title: const Text('My Reports',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0B6E6E)),
            onPressed: _load,
          )
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0B6E6E)))
          : _error != null
              ? _errorState()
              : _reports.isEmpty
                  ? _emptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: const Color(0xFF0B6E6E),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (_, i) => _reportCard(_reports[i]),
                      ),
                    ),
    );
  }

  Widget _reportCard(Report report) {
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
          '${report.confidence.toStringAsFixed(1)}% confidence · '
          '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
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
          _expandedRow('Symptoms', report.symptoms),
          const SizedBox(height: 8),
          _expandedRow('Precautions', report.precautions),
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

  Widget _emptyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_outlined, size: 64, color: Color(0xFF6B7280)),
            const SizedBox(height: 14),
            const Text('No reports yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 6),
            const Text('Your diagnoses will appear here.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/upload'),
              child: const Text('Scan Now'),
            ),
          ],
        ),
      );

  Widget _errorState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Color(0xFFE63946)),
            const SizedBox(height: 14),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
}
