class Project {
  final String id;
  final String title;
  final String? description;
  final String? link;

  Project({required this.id, required this.title, this.description, this.link});

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'link': link,
      };

  factory Project.fromMap(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        link: json['link'] as String?,
      );
}
