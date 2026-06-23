import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  String _selectedLanguage = 'en';

  final Map<String, String> _languages = {
    'en': 'English',
    'ur': 'Urdu',
    'hi': 'Hindi',
  };

  String _initials() {
    final name = Supabase.instance.client.auth.currentUser
            ?.userMetadata?['full_name']
            ?.toString() ??
        '';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _name() =>
      Supabase.instance.client.auth.currentUser?.userMetadata?['full_name']
          ?.toString() ??
      'User';

  String _email() =>
      Supabase.instance.client.auth.currentUser?.email ?? '';

  void _changeLanguage(String code) {
    setState(() => _selectedLanguage = code);
    LanguageService.language.value = code;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Language set to ${_languages[code]}'),
        backgroundColor: const Color(0xFF0B6E6E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style:
                TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        content:
            const Text('Are you sure you want to sign out?',
                style: TextStyle(color: Color(0xFF6B7280))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF6B7280)))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out',
                  style: TextStyle(
                      color: Color(0xFFE63946),
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );

    if (confirmed == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
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
        title: const Text('Profile',
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
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF0B6E6E), Color(0xFF1A9E9E)]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(_initials(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 14),
            Text(_name(),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text(_email(),
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 32),

            // Settings card
            Container(
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
                children: [
                  _settingsTile(
                    icon: Icons.person_outline,
                    title: 'Full Name',
                    trailing: Text(_name(),
                        style: const TextStyle(
                            color: Color(0xFF6B7280), fontSize: 13)),
                  ),
                  _divider(),
                  _settingsTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    trailing: Text(_email(),
                        style: const TextStyle(
                            color: Color(0xFF6B7280), fontSize: 13)),
                  ),
                  _divider(),
                  _settingsTile(
                    icon: Icons.translate_outlined,
                    title: 'Language',
                    trailing: _languageSelector(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE63946),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0B6E6E), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E))),
            ),
            trailing,
          ],
        ),
      );

  Widget _divider() =>
      const Divider(height: 1, color: Color(0xFFF0F4F8), indent: 54);

  Widget _languageSelector() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _languages.entries.map((e) {
            final active = e.key == _selectedLanguage;
            return GestureDetector(
              onTap: () => _changeLanguage(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:
                      active ? const Color(0xFF0B6E6E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            active ? Colors.white : const Color(0xFF6B7280))),
              ),
            );
          }).toList(),
        ),
      );
}
