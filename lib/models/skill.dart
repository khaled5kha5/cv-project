import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class Skill extends BaseModel {
  final String name;
  final String? level; // e.g., Beginner, Intermediate, Expert

  Skill({
    String? id,
    required this.name,
    this.level,
  }) : super(id: id);

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level,
      };

  /// Firestore-friendly map alias
  Map<String, dynamic> toMap() => toJson();

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = toJson();
    map.removeWhere((key, value) => value == null);
    return map;
  }

  factory Skill.fromJsonFactory(Map<String, dynamic> json, {String? docId}) {
    return Skill(
      id: docId ?? json['id'] as String?,
      name: json['name'] as String? ?? '',
      level: json['level'] as String?,
    );
  }

  /// Factory constructor for Firestore document
  factory Skill.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Skill(
      id: doc.id,
      name: data['name'] ?? '',
      level: data['level'],
    );
  }

  /// Factory constructor from map with id
  factory Skill.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Skill(
      id: docId ?? map['id'],
      name: map['name'] ?? '',
      level: map['level'],
    );
  }

  Skill copyWith({
    String? id,
    String? name,
    String? level,
  }) =>
      Skill(
        id: id ?? this.id,
        name: name ?? this.name,
        level: level ?? this.level,
      );
}
