class Report {
  final String id;
  final String userId;
  final String diseaseName;
  final double confidence;
  final String symptoms;
  final String precautions;
  final String imageUrl;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.userId,
    required this.diseaseName,
    required this.confidence,
    required this.symptoms,
    required this.precautions,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      diseaseName: json['disease_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      symptoms: json['symptoms'] as String? ?? '',
      precautions: json['precautions'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Severity color based on confidence level
  String get severityLevel {
    if (confidence >= 80) return 'high';
    if (confidence >= 50) return 'medium';
    return 'low';
  }
}
