class Doctor {
  final String name;
  final String address;
  final double rating;
  final String distance;
  final String mapsUrl;
  final double lat;
  final double lng;

  const Doctor({
    required this.name,
    required this.address,
    required this.rating,
    required this.distance,
    required this.mapsUrl,
    required this.lat,
    required this.lng,
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
    );
  }
}
