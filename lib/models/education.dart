import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class Education extends BaseModel {
  final String school;
  final String degree;
  final DateTime startDate;
  final DateTime? endDate;
  final String? fieldOfStudy;
  final String? grade;

  Education({
    String? id,
    required this.school,
    required this.degree,
    required this.startDate,
    this.endDate,
    this.fieldOfStudy,
    this.grade,
  }) : super(id: id);

  Map<String, dynamic> toJson() => {
        'school': school,
        'degree': degree,
        'startDate': startDate,
        'endDate': endDate,
        'fieldOfStudy': fieldOfStudy,
        'grade': grade,
      };

  /// Firestore-friendly map alias - converts DateTime to Timestamp
  Map<String, dynamic> toMap() => {
        'school': school,
        'degree': degree,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'fieldOfStudy': fieldOfStudy,
        'grade': grade,
      };

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = toJson();
    map.removeWhere((key, value) => value == null);
    return map;
  }

  factory Education.fromJsonFactory(Map<String, dynamic> json, {String? docId}) {
    return Education(
      id: docId ?? json['id'] as String?,
      school: json['school'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate(),
      fieldOfStudy: json['fieldOfStudy'] as String?,
      grade: json['grade'] as String?,
    );
  }

  /// Factory constructor for Firestore document
  factory Education.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Education(
      id: doc.id,
      school: data['school'] ?? '',
      degree: data['degree'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      fieldOfStudy: data['fieldOfStudy'],
      grade: data['grade'],
    );
  }

  /// Factory constructor from map with id
  factory Education.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Education(
      id: docId ?? map['id'],
      school: map['school'] ?? '',
      degree: map['degree'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      fieldOfStudy: map['fieldOfStudy'],
      grade: map['grade'],
    );
  }

  Education copyWith({
    String? id,
    String? school,
    String? degree,
    DateTime? startDate,
    DateTime? endDate,
    String? fieldOfStudy,
    String? grade,
  }) =>
      Education(
        id: id ?? this.id,
        school: school ?? this.school,
        degree: degree ?? this.degree,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
        grade: grade ?? this.grade,
      );
}
