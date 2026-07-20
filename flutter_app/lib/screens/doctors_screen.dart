import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/doctor.dart';
import '../app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/app_header_bar.dart';

class DoctorsScreen extends StatefulWidget {
  final String disease;
  const DoctorsScreen({super.key, required this.disease});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<Doctor> _doctors = [];
  bool _loading = true;
  String? _error;
  Position? _position;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() { _loading = true; _error = null; });

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _error = AppLocalizations.of(context).locationPermissionDeniedError;
          _loading = false;
        });
        return;
      }

      _position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      final doctors = await ApiService.findDoctors(
        disease: widget.disease,
        lat: _position!.latitude,
        lng: _position!.longitude,
      );

      setState(() { _doctors = doctors; _loading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _openMaps(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).couldNotOpenMapsError)),
        );
      }
    }
  }

  List<Marker> get _markers {
    final markers = <Marker>[];

    // User location marker
    if (_position != null) {
      markers.add(Marker(
        point: LatLng(_position!.latitude, _position!.longitude),
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B6E6E),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B6E6E).withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ));
    }

    // Doctor markers
    for (final doc in _doctors) {
      if (doc.lat == 0.0 && doc.lng == 0.0) continue;
      markers.add(Marker(
        point: LatLng(doc.lat, doc.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _openMaps(doc.mapsUrl),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE63946),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: Colors.white, size: 18),
          ),
        ),
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: BrandedAppBar(
        title: l10n.nearbyDoctorsTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
            onPressed: _fetchDoctors,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF0B6E6E)),
                  const SizedBox(height: 14),
                  Text(l10n.findingDoctorsNearYou,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                ],
              ))
          : _error != null
              ? _errorState(l10n)
              : Column(
                  children: [
                    // OpenStreetMap tile map
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.38,
                      child: _position == null
                          ? Center(
                              child: Text(l10n.locationUnavailable,
                                  style: const TextStyle(color: Color(0xFF6B7280))))
                          : FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(
                                    _position!.latitude, _position!.longitude),
                                initialZoom: 13.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.dermavision.plus',
                                ),
                                MarkerLayer(markers: _markers),
                              ],
                            ),
                    ),

                    // Results summary bar
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Color(0xFF0B6E6E), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            l10n.doctorsFoundNearby(_doctors.length),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A2E)),
                          ),
                          const Spacer(),
                          Text(l10n.pakistanDoctorsDirectory,
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),

                    // Doctor cards
                    Expanded(
                      child: _doctors.isEmpty
                          ? _emptyState(l10n)
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _doctors.length,
                              itemBuilder: (_, i) =>
                                  _doctorCard(_doctors[i], l10n),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _doctorCard(Doctor doc, AppLocalizations l10n) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8EDDC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.local_hospital_outlined,
                      color: Color(0xFF0B6E6E), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E))),
                      if (doc.qualification.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(doc.qualification,
                            style: const TextStyle(
                                fontSize: 11.5, color: Color(0xFF6B7280)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 3),
                      Text(doc.address,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statChip(
                  icon: Icons.near_me_rounded,
                  text: doc.distance,
                  color: const Color(0xFF2DC653),
                  bg: const Color(0xFFE8F8F0),
                ),
                if (doc.rating > 0)
                  _statChip(
                    icon: Icons.star_rounded,
                    text: doc.rating.toStringAsFixed(1),
                    color: const Color(0xFFF4A261),
                    bg: const Color(0xFFFFF3E8),
                  ),
                if (doc.experienceYears > 0)
                  _statChip(
                    icon: Icons.work_history_outlined,
                    text: l10n.yearsExpLabel(
                        doc.experienceYears.toStringAsFixed(0)),
                    color: AppTheme.primary,
                    bg: AppTheme.accentSoft,
                  ),
                if (doc.feePkr > 0)
                  _statChip(
                    icon: Icons.payments_outlined,
                    text: l10n.feeLabel(doc.feePkr.toStringAsFixed(0)),
                    color: const Color(0xFF0B6E6E),
                    bg: const Color(0xFFE8F8F0),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (doc.profileUrl.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openMaps(doc.profileUrl),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0B6E6E),
                        side: const BorderSide(color: Color(0xFF0B6E6E)),
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.person_outline_rounded, size: 16),
                      label: Text(l10n.viewProfile,
                          style: const TextStyle(fontSize: 12.5)),
                    ),
                  ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _openMaps(doc.mapsUrl),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B6E6E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_outlined,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _statChip({
    required IconData icon,
    required String text,
    required Color color,
    required Color bg,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(text,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _emptyState(AppLocalizations l10n) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 60, color: Color(0xFF6B7280)),
              const SizedBox(height: 16),
              Text(l10n.noDoctorsFoundTitle,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 6),
              Text(l10n.noDoctorsFoundMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _fetchDoctors, child: Text(l10n.searchAgain)),
            ],
          ),
        ),
      );

  Widget _errorState(AppLocalizations l10n) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_outlined,
                  size: 60, color: Color(0xFF6B7280)),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _fetchDoctors, child: Text(l10n.tryAgain)),
            ],
          ),
        ),
      );
}
