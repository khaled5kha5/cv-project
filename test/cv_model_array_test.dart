import 'package:flutter_test/flutter_test.dart';
import 'package:cv_project1/models/cv_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('CV Model Array Serialization Tests', () {
    test('CV.toMap() should serialize arrays correctly', () {
      // Create a CV with all arrays populated
      final cv = CV(
        name: 'Test CV',
        fullName: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        location: 'New York',
        role: 'Software Developer',
        summary: 'Experienced developer',
        styleTemplate: 'Modern',
        experiences: [
          Experience(
            company: 'Tech Corp',
            role: 'Developer',
            startDate: DateTime(2020, 1, 1),
            endDate: DateTime(2021, 12, 31),
            description: 'Built amazing apps',
          ),
        ],
        educations: [
          Education(
            school: 'University',
            degree: 'BS Computer Science',
            startDate: DateTime(2016, 9, 1),
            endDate: DateTime(2020, 6, 1),
          ),
        ],
        skills: [
          Skill(name: 'Flutter', level: 'Expert'),
          Skill(name: 'Dart', level: 'Expert'),
        ],
        projects: [
          Project(
            title: 'Awesome App',
            description: 'A great app',
            link: 'https://example.com',
            technologies: ['Flutter', 'Firebase'],
          ),
        ],
      );

      // Convert to map
      final map = cv.toMap();

      // Verify all fields are present
      expect(map['name'], 'Test CV');
      expect(map['fullName'], 'John Doe');
      expect(map['email'], 'john@example.com');
      expect(map['phone'], '+1234567890');
      expect(map['location'], 'New York');
      expect(map['role'], 'Software Developer');
      expect(map['summary'], 'Experienced developer');
      expect(map['styleTemplate'], 'Modern');

      // Verify arrays are serialized
      expect(map['experiences'], isA<List>());
      expect(map['educations'], isA<List>());
      expect(map['skills'], isA<List>());
      expect(map['projects'], isA<List>());

      // Verify array lengths
      expect((map['experiences'] as List).length, 1);
      expect((map['educations'] as List).length, 1);
      expect((map['skills'] as List).length, 2);
      expect((map['projects'] as List).length, 1);

      // Verify experience data
      final expMap = (map['experiences'] as List)[0] as Map<String, dynamic>;
      expect(expMap['company'], 'Tech Corp');
      expect(expMap['role'], 'Developer');
      expect(expMap['description'], 'Built amazing apps');

      // Verify education data
      final eduMap = (map['educations'] as List)[0] as Map<String, dynamic>;
      expect(eduMap['school'], 'University');
      expect(eduMap['degree'], 'BS Computer Science');

      // Verify skills data
      final skillMaps = (map['skills'] as List).cast<Map<String, dynamic>>();
      expect(skillMaps[0]['name'], 'Flutter');
      expect(skillMaps[0]['level'], 'Expert');
      expect(skillMaps[1]['name'], 'Dart');

      // Verify project data
      final projMap = (map['projects'] as List)[0] as Map<String, dynamic>;
      expect(projMap['title'], 'Awesome App');
      expect(projMap['description'], 'A great app');
      expect(projMap['link'], 'https://example.com');
      expect(projMap['technologies'], ['Flutter', 'Firebase']);
    });

    test('CV.fromMap() should deserialize arrays correctly', () {
      // Create a map similar to what Firestore would return
      final map = {
        'name': 'Test CV',
        'fullName': 'Jane Smith',
        'email': 'jane@example.com',
        'phone': '+9876543210',
        'location': 'San Francisco',
        'role': 'Designer',
        'summary': 'Creative designer',
        'styleTemplate': 'Minimal',
        'experiences': [
          {
            'company': 'Design Studio',
            'role': 'UI Designer',
            'startDate': Timestamp.fromDate(DateTime(2019, 1, 1)),
            'endDate': Timestamp.fromDate(DateTime(2021, 12, 31)),
            'description': 'Designed beautiful interfaces',
            'location': 'Remote',
            'currentlyWorking': false,
          },
        ],
        'educations': [
          {
            'school': 'Art School',
            'degree': 'BFA Design',
            'startDate': Timestamp.fromDate(DateTime(2015, 9, 1)),
            'endDate': Timestamp.fromDate(DateTime(2019, 6, 1)),
            'fieldOfStudy': 'Visual Design',
            'grade': 'A',
          },
        ],
        'skills': [
          {'name': 'Figma', 'level': 'Expert'},
          {'name': 'Adobe XD', 'level': 'Advanced'},
        ],
        'projects': [
          {
            'title': 'Portfolio Site',
            'description': 'Personal portfolio',
            'link': 'https://portfolio.com',
            'technologies': ['HTML', 'CSS', 'JS'],
            'createdDate': Timestamp.fromDate(DateTime(2020, 6, 1)),
          },
        ],
        'createdAt': Timestamp.fromDate(DateTime(2020, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2021, 12, 31)),
      };

      // Deserialize from map
      final cv = CV.fromMap(map, docId: 'test-cv-id');

      // Verify basic fields
      expect(cv.id, 'test-cv-id');
      expect(cv.name, 'Test CV');
      expect(cv.fullName, 'Jane Smith');
      expect(cv.email, 'jane@example.com');
      expect(cv.phone, '+9876543210');
      expect(cv.location, 'San Francisco');
      expect(cv.role, 'Designer');
      expect(cv.summary, 'Creative designer');
      expect(cv.styleTemplate, 'Minimal');

      // Verify arrays are deserialized
      expect(cv.experiences, isNotNull);
      expect(cv.educations, isNotNull);
      expect(cv.skills, isNotNull);
      expect(cv.projects, isNotNull);

      // Verify array lengths
      expect(cv.experiences!.length, 1);
      expect(cv.educations!.length, 1);
      expect(cv.skills!.length, 2);
      expect(cv.projects!.length, 1);

      // Verify experience object
      final exp = cv.experiences![0];
      expect(exp.company, 'Design Studio');
      expect(exp.role, 'UI Designer');
      expect(exp.description, 'Designed beautiful interfaces');
      expect(exp.location, 'Remote');

      // Verify education object
      final edu = cv.educations![0];
      expect(edu.school, 'Art School');
      expect(edu.degree, 'BFA Design');
      expect(edu.fieldOfStudy, 'Visual Design');
      expect(edu.grade, 'A');

      // Verify skills objects
      expect(cv.skills![0].name, 'Figma');
      expect(cv.skills![0].level, 'Expert');
      expect(cv.skills![1].name, 'Adobe XD');
      expect(cv.skills![1].level, 'Advanced');

      // Verify project object
      final proj = cv.projects![0];
      expect(proj.title, 'Portfolio Site');
      expect(proj.description, 'Personal portfolio');
      expect(proj.link, 'https://portfolio.com');
      expect(proj.technologies, ['HTML', 'CSS', 'JS']);

      // Verify timestamps
      expect(cv.createdAt, isNotNull);
      expect(cv.updatedAt, isNotNull);
    });

    test('CV with null arrays should serialize correctly', () {
      final cv = CV(
        name: 'Simple CV',
        fullName: 'Bob Smith',
      );

      final map = cv.toMap();

      expect(map['name'], 'Simple CV');
      expect(map['fullName'], 'Bob Smith');
      expect(map['experiences'], isNull);
      expect(map['educations'], isNull);
      expect(map['skills'], isNull);
      expect(map['projects'], isNull);
    });

    test('CV with empty arrays should serialize correctly', () {
      final cv = CV(
        name: 'Empty Arrays CV',
        experiences: [],
        educations: [],
        skills: [],
        projects: [],
      );

      final map = cv.toMap();

      expect(map['experiences'], isEmpty);
      expect(map['educations'], isEmpty);
      expect(map['skills'], isEmpty);
      expect(map['projects'], isEmpty);
    });
  });
}
