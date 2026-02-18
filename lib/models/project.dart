import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class Project extends BaseModel {
  final String title;
  final String? description;
  final String? link;
  final List<String>? technologies;
  final DateTime? createdDate;

  Project({
    String? id,
    required this.title,
    this.description,
    this.link,
    this.technologies,
    this.createdDate,
  }) : super(id: id);

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'link': link,
        'technologies': technologies,
        'createdDate': createdDate,
      };

  /// Firestore-friendly map alias - converts DateTime to Timestamp
  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'link': link,
        'technologies': technologies,
        'createdDate': createdDate != null ? Timestamp.fromDate(createdDate!) : null,
      };

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = toJson();
    map.removeWhere((key, value) => value == null);
    return map;
  }

  factory Project.fromJsonFactory(Map<String, dynamic> json, {String? docId}) {
    return Project(
      id: docId ?? json['id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      link: json['link'] as String?,
      technologies: List<String>.from(json['technologies'] as List? ?? []),
      createdDate: (json['createdDate'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor for Firestore document
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      link: data['link'],
      technologies: List<String>.from(data['technologies'] as List? ?? []),
      createdDate: (data['createdDate'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor from map with id
  factory Project.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Project(
      id: docId ?? map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      link: map['link'],
      technologies: List<String>.from(map['technologies'] as List? ?? []),
      createdDate: (map['createdDate'] as Timestamp?)?.toDate(),
    );
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? link,
    List<String>? technologies,
    DateTime? createdDate,
  }) =>
      Project(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        link: link ?? this.link,
        technologies: technologies ?? this.technologies,
        createdDate: createdDate ?? this.createdDate,
      );
}
