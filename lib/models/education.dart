class Education {
  final String id;
  final String school;
  final String degree;
  final DateTime startDate;
  final DateTime? endDate;

  Education({
    required this.id,
    required this.school,
    required this.degree,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'school': school,
        'degree': degree,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

  factory Education.fromMap(Map<String, dynamic> json) => Education(
        id: json['id'] as String,
        school: json['school'] as String,
        degree: json['degree'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
      );
      
}
