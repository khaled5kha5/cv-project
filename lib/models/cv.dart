import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';
import 'skill.dart';
import 'education.dart';
import 'experience.dart';
import 'project.dart';

class CV extends BaseModel {
  final String name;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? location;
  final String? summary;
  final String? role;
  final String? profileImage;
  final String? styleTemplate;
  
  final List<Experience>? experiences;
  final List<Education>? educations;
  final List<Skill>? skills;
  final List<Project>? projects;

  CV({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.name,
    this.fullName,
    this.email,
    this.phone,
    this.location,
    this.summary,
    this.role,
    this.profileImage,
    this.styleTemplate,
    this.experiences,
    this.educations,
    this.skills,
    this.projects,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  /// Convert to Firestore-ready map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'summary': summary,
      'role': role,
      'profileImage': profileImage,
      'styleTemplate': styleTemplate,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to map suitable for updates (no timestamps, no nulls)
  @override
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> map = {
      'name': name,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'summary': summary,
      'role': role,
      'profileImage': profileImage,
      'styleTemplate': styleTemplate,
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  /// Factory constructor for Firestore document
  factory CV.fromFirestore(DocumentSnapshot doc) {
    return CV.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
  }

  /// Factory constructor from map
  factory CV.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CV(
      id: docId ?? map['id'],
      name: map['name'] ?? '',
      fullName: map['fullName'],
      email: map['email'],
      phone: map['phone'],
      location: map['location'],
      summary: map['summary'],
      role: map['role'],
      profileImage: map['profileImage'],
      styleTemplate: map['styleTemplate'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  CV copyWith({
    String? id,
    String? name,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? summary,
    String? role,
    String? profileImage,
    String? styleTemplate,
    List<Experience>? experiences,
    List<Education>? educations,
    List<Skill>? skills,
    List<Project>? projects,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CV(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        name: name ?? this.name,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        summary: summary ?? this.summary,
        role: role ?? this.role,
        profileImage: profileImage ?? this.profileImage,
        styleTemplate: styleTemplate ?? this.styleTemplate,
        experiences: experiences ?? this.experiences,
        educations: educations ?? this.educations,
        skills: skills ?? this.skills,
        projects: projects ?? this.projects,
      );
}
