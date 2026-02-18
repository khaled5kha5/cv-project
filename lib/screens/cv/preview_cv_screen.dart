import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_project1/services/cv_service.dart';
import 'package:cv_project1/models/cv.dart';

class PreviewCvScreen extends StatelessWidget {
  final String? cvId;

  const PreviewCvScreen({Key? key, this.cvId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cvId == null) {
      return _placeholder(context);
    }

    return FutureBuilder<CV?>(
      future: CVService.instance.getCV(cvId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(title: const Text('CV Preview')), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(appBar: AppBar(title: const Text('CV Preview')), body: Center(child: Text('Error: ${snapshot.error}')));
        }

        final cv = snapshot.data;
        if (cv == null) {
          return Scaffold(appBar: AppBar(title: const Text('CV Preview')), body: const Center(child: Text('CV not found')));
        }

        final selectedStyle = cv.styleTemplate ?? 'Classic';
        final isModern = selectedStyle == 'Modern';
        final isMinimal = selectedStyle == 'Minimal';
        final headerColor = isModern
            ? Theme.of(context).primaryColor
            : isMinimal
                ? Colors.transparent
                : Theme.of(context).primaryColor.withOpacity(0.1);
        final headerTextColor = isModern ? Colors.white : null;
        final screenBg = isMinimal ? Colors.white : Colors.grey[50];

        return Scaffold(
          appBar: AppBar(
            title: const Text('CV Preview'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download feature coming soon')));
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share feature coming soon')));
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: screenBg,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Style: $selectedStyle',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: headerColor,
                          borderRadius: BorderRadius.circular(16),
                          border: isMinimal ? Border.all(color: Colors.grey.shade300) : null,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: isModern
                                      ? Colors.white24
                                      : Theme.of(context).primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 48,
                                    color: isModern ? Colors.white : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                cv.fullName ?? cv.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: headerTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cv.role ?? '',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isModern ? Colors.white70 : Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                children: [
                                  if (cv.email != null) _buildContactInfo(Icons.email, cv.email!, isModern: isModern),
                                  if (cv.phone != null) _buildContactInfo(Icons.phone, cv.phone!, isModern: isModern),
                                  if (cv.location != null) _buildContactInfo(Icons.location_on, cv.location!, isModern: isModern),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (cv.summary != null && cv.summary!.isNotEmpty) ...[
                        _buildSection(context, title: 'Professional Summary', icon: Icons.description, isModern: isModern, isMinimal: isMinimal),
                        const SizedBox(height: 8),
                        Text(cv.summary!, style: Theme.of(context).textTheme.bodyMedium!),
                        const SizedBox(height: 16),
                      ],

                      // Experiences (from subcollection)
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: CVService.instance.getCVExperiences(cv.id ?? ''),
                        builder: (context, expSnap) {
                          final exps = expSnap.data ?? [];
                          if (exps.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(context, title: 'Experience', icon: Icons.work, isModern: isModern, isMinimal: isMinimal),
                              const SizedBox(height: 8),
                              ...exps.map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildExperienceItem(
                                      context,
                                      title: e['role'] ?? '',
                                      company: e['company'] ?? '',
                                      date: _formatDates(e['startDate'], e['endDate']),
                                      description: e['description'] ?? '',
                                      isModern: isModern,
                                    ),
                                  )),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),

                      // Educations
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: CVService.instance.getCVEducations(cv.id ?? ''),
                        builder: (context, eduSnap) {
                          final eds = eduSnap.data ?? [];
                          if (eds.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(context, title: 'Education', icon: Icons.school, isModern: isModern, isMinimal: isMinimal),
                              const SizedBox(height: 8),
                              ...eds.map((ed) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildEducationItem(
                                      context,
                                      school: ed['school'] ?? '',
                                      degree: ed['degree'] ?? '',
                                      date: _formatDates(ed['startDate'], ed['endDate']),
                                      isModern: isModern,
                                    ),
                                  )),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),

                      // Skills
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: CVService.instance.getCVSkills(cv.id ?? ''),
                        builder: (context, skillSnap) {
                          final skills = skillSnap.data ?? [];
                          if (skills.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(context, title: 'Skills', icon: Icons.star, isModern: isModern, isMinimal: isMinimal),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: skills
                                    .map((s) => _buildSkillChip(context, s['name'] ?? '', isModern: isModern, isMinimal: isMinimal))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),

                      // Projects
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: CVService.instance.getCVProjects(cv.id ?? ''),
                        builder: (context, projectSnap) {
                          final projects = projectSnap.data ?? [];
                          if (projects.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(context, title: 'Projects', icon: Icons.code, isModern: isModern, isMinimal: isMinimal),
                              const SizedBox(height: 8),
                              ...projects.map((project) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildProjectItem(
                                      context,
                                      title: project['title'] ?? '',
                                      description: project['description'] ?? '',
                                      link: project['link'] ?? '',
                                      isModern: isModern,
                                    ),
                                  )),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDates(dynamic start, dynamic end) {
    DateTime? s;
    DateTime? e;
    
    if (start is Timestamp) {
      s = start.toDate();
    } else if (start is DateTime) {
      s = start;
    }
    
    if (end is Timestamp) {
      e = end.toDate();
    } else if (end is DateTime) {
      e = end;
    }
    
    final sText = s != null ? '${s.year}' : '';
    final eText = e != null ? '${e.year}' : 'Present';
    return '$sText - $eText';
  }

  Widget _placeholder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CV Preview')),
      body: const Center(child: Text('No CV selected')),
    );
  }

  Widget _buildContactInfo(IconData icon, String text, {bool isModern = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isModern ? Colors.white70 : Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: isModern ? Colors.white70 : Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    bool isModern = false,
    bool isMinimal = false,
  }) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isModern ? Theme.of(context).primaryColor : (isMinimal ? Colors.grey.shade400 : Theme.of(context).primaryColor),
            width: isMinimal ? 1 : 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(
    BuildContext context, {
    required String title,
    required String company,
    required String date,
    required String description,
    bool isModern = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          company,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isModern ? Theme.of(context).primaryColor.withOpacity(0.9) : Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEducationItem(
    BuildContext context, {
    required String school,
    required String degree,
    required String date,
    bool isModern = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              school,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          degree,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isModern ? Theme.of(context).primaryColor.withOpacity(0.9) : Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(BuildContext context, String skill, {bool isModern = false, bool isMinimal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isModern
            ? Theme.of(context).primaryColor.withOpacity(0.12)
            : isMinimal
                ? Colors.transparent
                : Colors.grey[200],
        border: isMinimal ? Border.all(color: Colors.grey.shade400) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        skill,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildProjectItem(
    BuildContext context, {
    required String title,
    required String description,
    required String link,
    bool isModern = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (link.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            link,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isModern ? Theme.of(context).primaryColor.withOpacity(0.9) : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ],
    );
  }
}
