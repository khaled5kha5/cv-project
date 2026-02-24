class Experience {
  String id;
  String company;
  String position;
  String duration;

  Experience({
    required this.id,
    required this.company,
    required this.position,
    required this.duration,
  });
  

  factory Experience.fromFirestore(Map<String, dynamic> data) {
    return Experience(
      id: data['id'],
      company: data['company'],
      position: data['position'],
      duration: data['duration'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'duration': duration,
    };
  }
}


class Education {
  String id;
  String university;
  String degree;
  String fieldOfStudy;

  Education({
    required this.id,
    required this.university,
    required this.degree,
    required this.fieldOfStudy,
  });

  factory Education.fromFirestore(Map<String, dynamic> data) {
    return Education(
      id: data['id'],
      university: data['university'],
      degree: data['degree'],
      fieldOfStudy: data['fieldOfStudy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'university': university,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
    };
  }
}


class Project {
  String id;
  String title;
  String? description;
  String link;

  Project({
    required this.id,
    required this.title,
    this.description,
    required this.link,
  });

  factory Project.fromFirestore(Map<String, dynamic> data) {
    return Project(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      link: data['link'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'link': link,
    };
  }
}

class Skill {
  String id;
  String name;
  String proficiency;

  Skill({
    required this.id,
    required this.name,
    required this.proficiency,
  });

  factory Skill.fromFirestore(Map<String, dynamic> data) {
    return Skill(
      id: data['id'],
      name: data['name'],
      proficiency: data['proficiency'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'proficiency': proficiency,
    };
  }
}



class CvModel {
  String? id;
  String cvname;
  String? fullname;
  String? email;
  String? phone;
  final String? location;
  final String? summary;
  final String? role;
  final String? profileImage;
  List<Education>? educations;
  List<Experience>? experiences;
  List<Project>? projects;
  List<Skill>? skills;
  final String? styleTemplate;
  final String? colorScheme;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CvModel({
    this.id,
    required this.cvname,
    required this.fullname,
    required this.email,
    required this.phone,
    this.location,
    this.summary,
    this.role,
    this.profileImage,
    this.educations,
    this.experiences,
    this.projects,
    this.skills,
    this.styleTemplate,
    this.colorScheme,
    this.createdAt,
    this.updatedAt,
  });

  factory CvModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CvModel(
      id: id,
      cvname: data['cvname'],
      fullname: data['fullname'],
      email: data['email'],
      phone: data['phone'],
      location: data['location'],
      summary: data['summary'],
      role: data['role'],
      profileImage: data['profileImage'],
      educations: (data['educations'] as List<dynamic>?)
              ?.map((e) => Education.fromFirestore(e))
              .toList(),
      experiences: (data['experiences'] as List<dynamic>?)
              ?.map((e) => Experience.fromFirestore(e))
              .toList(),
      projects: (data['projects'] as List<dynamic>?)
              ?.map((e) => Project.fromFirestore(e))
              .toList(),
      skills: (data['skills'] as List<dynamic>?)
              ?.map((e) => Skill.fromFirestore(e))
              .toList(),
      styleTemplate: data['styleTemplate'],
      colorScheme: data['colorScheme'],
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cvname': cvname,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'location': location,
      'summary': summary,
      'role': role,
      'profileImage': profileImage,
      'educations': educations?.map((e) => e.toFirestore()).toList(),
      'experiences': experiences?.map((e) => e.toFirestore()).toList(),
      'projects': projects?.map((e) => e.toFirestore()).toList(),
      'skills': skills?.map((e) => e.toFirestore()).toList(),
      'styleTemplate': styleTemplate,
      'colorScheme': colorScheme,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

