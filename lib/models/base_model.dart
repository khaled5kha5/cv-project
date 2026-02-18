/// Abstract base model class for all Firestore models
abstract class BaseModel {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BaseModel({this.id, this.createdAt, this.updatedAt});

  /// Convert model to a map suitable for Firestore updates (excludes timestamps and null values)
  Map<String, dynamic> toUpdateMap();
}
