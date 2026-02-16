import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'personal_info_screen.dart';
import 'education_screen.dart';
import 'experience_screen.dart';
import 'preview_cv_screen.dart';

class CvHomeScreen extends StatelessWidget {
  const CvHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Logged in: ${user?.email ?? user?.uid ?? 'Guest'}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen())),
            child: const Text('Personal Info'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationScreen())),
            child: const Text('Education'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExperienceScreen())),
            child: const Text('Experience'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreviewCvScreen())),
            child: const Text('Preview CV'),
          ),
        ],
      ),
    );
  }
}
