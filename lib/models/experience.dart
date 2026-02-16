class Experience {
  final String id;
  final String company;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  Experience({
    required this.id,
    required this.company,
    required this.role,
    required this.startDate,
    this.endDate,
    this.description,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'company': company,
        'role': role,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'description': description,
      };

  factory Experience.fromMap(Map<String, dynamic> json) => Experience(
        id: json['id'] as String,
        company: json['company'] as String,
        role: json['role'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
        description: json['description'] as String?,
      );
}
