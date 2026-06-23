import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/report.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  List<Report> _recentReports = [];
  bool _loadingReports = true;

  final List<String> _tips = [
    'Apply broad-spectrum SPF 30+ every day.',
    'Check your skin monthly for new or changing moles.',
    'Stay hydrated — skin reflects your water intake.',
    'Avoid tanning beds; UV exposure accelerates aging.',
    'See a dermatologist annually for a full skin check.',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentReports();
  }

  Future<void> _loadRecentReports() async {
    final uid = _auth.userId;
    if (uid == null) {
      if (mounted) setState(() => _loadingReports = false);
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('reports')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(3);
      final reports = (data as List).map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) {
        setState(() {
          _recentReports = reports;
          _loadingReports = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingReports = false);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _userName() {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    return meta?['full_name']?.toString().split(' ').first ?? 'there';
  }

  // Bottom nav pushes named routes; home tab stays in place
  void _onNavTap(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/upload').then((_) => _loadRecentReports());
        break;
      case 2:
        Navigator.pushNamed(context, '/reports');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(child: _homeTab()),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _homeTab() {
    final tip = _tips[DateTime.now().day % _tips.length];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B6E6E), Color(0xFF1A9E9E)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B6E6E).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, ${_userName()} 👋',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  '💡 Tip: $tip',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Scan CTA
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, '/upload').then((_) => _loadRecentReports()),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8EDDC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 36, color: Color(0xFF0B6E6E)),
                  ),
                  const SizedBox(height: 14),
                  const Text('Scan Your Skin',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  const Text('Upload a photo for AI analysis',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Recent reports
          const Text('Recent Diagnoses',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          if (_loadingReports)
            const Center(
                child: CircularProgressIndicator(color: Color(0xFF0B6E6E)))
          else if (_recentReports.isEmpty)
            _emptyReports()
          else
            ..._recentReports.map(_buildMiniReportCard),
        ],
      ),
    );
  }

  Widget _emptyReports() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Center(
          child: Text(
            'No diagnoses yet.\nTap "Scan Your Skin" to start.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ),
      );

  Widget _buildMiniReportCard(Report r) {
    final color = r.severityLevel == 'high'
        ? const Color(0xFFE63946)
        : r.severityLevel == 'medium'
            ? const Color(0xFFF4A261)
            : const Color(0xFF2DC653);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.diseaseName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                Text(
                  '${r.confidence.toStringAsFixed(1)}% confidence · '
                  '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }

  Widget _bottomNav() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: _onNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF0B6E6E),
          unselectedItemColor: const Color(0xFF6B7280),
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                activeIcon: Icon(Icons.camera_alt_rounded),
                label: 'Upload'),
            BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                activeIcon: Icon(Icons.article_rounded),
                label: 'Reports'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile'),
          ],
        ),
      );
}
