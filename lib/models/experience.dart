import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class Experience extends BaseModel {
  final String company;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final String? location;
  final bool? currentlyWorking;

  Experience({
    String? id,
    required this.company,
    required this.role,
    required this.startDate,
    this.endDate,
    this.description,
    this.location,
    this.currentlyWorking = false,
  }) : super(id: id);

  Map<String, dynamic> toJson() => {
        'company': company,
        'role': role,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
        'location': location,
        'currentlyWorking': currentlyWorking,
      };

  /// Firestore-friendly map alias - converts DateTime to Timestamp
  Map<String, dynamic> toMap() => {
        'company': company,
        'role': role,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'description': description,
        'location': location,
        'currentlyWorking': currentlyWorking,
      };

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = toJson();
    map.removeWhere((key, value) => value == null);
    return map;
  }

  factory Experience.fromJsonFactory(Map<String, dynamic> json, {String? docId}) {
    return Experience(
      id: docId ?? json['id'] as String?,
      company: json['company'] as String? ?? '',
      role: json['role'] as String? ?? '',
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate(),
      description: json['description'] as String?,
      location: json['location'] as String?,
      currentlyWorking: json['currentlyWorking'] as bool? ?? false,
    );
  }

  /// Factory constructor for Firestore document
  factory Experience.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Experience(
      id: doc.id,
      company: data['company'] ?? '',
      role: data['role'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      description: data['description'],
      location: data['location'],
      currentlyWorking: data['currentlyWorking'] ?? false,
    );
  }

  /// Factory constructor from map with id
  factory Experience.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Experience(
      id: docId ?? map['id'],
      company: map['company'] ?? '',
      role: map['role'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      description: map['description'],
      location: map['location'],
      currentlyWorking: map['currentlyWorking'] ?? false,
    );
  }

  Experience copyWith({
    String? id,
    String? company,
    String? role,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? location,
    bool? currentlyWorking,
  }) =>
      Experience(
        id: id ?? this.id,
        company: company ?? this.company,
        role: role ?? this.role,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        description: description ?? this.description,
        location: location ?? this.location,
        currentlyWorking: currentlyWorking ?? this.currentlyWorking,
      );
}
