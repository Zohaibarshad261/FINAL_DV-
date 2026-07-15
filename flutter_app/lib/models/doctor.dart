class Doctor {
  final String name;
  final String address;
  final double rating;
  final String distance;
  final String mapsUrl;
  final double lat;
  final double lng;
  final String specialization;
  final String qualification;
  final double experienceYears;
  final double feePkr;
  final String profileUrl;

  const Doctor({
    required this.name,
    required this.address,
    required this.rating,
    required this.distance,
    required this.mapsUrl,
    required this.lat,
    required this.lng,
    this.specialization = '',
    this.qualification = '',
    this.experienceYears = 0,
    this.feePkr = 0,
    this.profileUrl = '',
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final distNum = (json['distance'] as num?)?.toDouble() ?? 0.0;
    return Doctor(
      name: json['name'] as String,
      address: json['address'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      distance: '${distNum.toStringAsFixed(1)} km',
      mapsUrl: json['maps_url'] as String,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      specialization: json['specialization'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      experienceYears: (json['experience_years'] as num?)?.toDouble() ?? 0,
      feePkr: (json['fee_pkr'] as num?)?.toDouble() ?? 0,
      profileUrl: json['profile_url'] as String? ?? '',
    );
  }
}
