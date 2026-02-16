class Skill {
  final String id;
  final String name;
  final String? level; // e.g., Beginner, Intermediate, Expert

  Skill({required this.id, required this.name, this.level});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'level': level,
      };

  factory Skill.fromMap(Map<String, dynamic> json) => Skill(
        id: json['id'] as String,
        name: json['name'] as String,
        level: json['level'] as String?,
      );
}
