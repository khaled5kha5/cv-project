import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cv_project1/models/cv.dart';
import 'package:cv_project1/models/education.dart';
import 'package:cv_project1/models/experience.dart';
import 'package:cv_project1/models/project.dart';
import 'package:cv_project1/models/skill.dart';
import 'package:cv_project1/services/cv_service.dart';
import 'package:cv_project1/services/storage_service.dart';

class CVBuilderScreen extends StatefulWidget {
  final String? cvId; // For editing existing CV

  const CVBuilderScreen({Key? key, this.cvId}) : super(key: key);

  @override
  State<CVBuilderScreen> createState() => _CVBuilderScreenState();
}

class _CVBuilderScreenState extends State<CVBuilderScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  CV? _cv;

  // Personal Info Controllers
  final _nameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _roleController = TextEditingController();
  final _summaryController = TextEditingController();

  // Education and Experience lists
  List<Education> _educations = [];
  List<Experience> _experiences = [];
  List<Project> _projects = [];
  List<Skill> _skills = [];
  final List<String> _cvStyles = const ['Classic', 'Modern', 'Minimal'];
  String _selectedStyle = 'Classic';
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadCVIfEditing();
  }

  Future<void> _loadCVIfEditing() async {
    if (widget.cvId != null) {
      setState(() => _isLoading = true);
      try {
        final cv = await CVService.instance.getCV(widget.cvId!);
        if (cv != null) {
          setState(() {
            _cv = cv;
            _nameController.text = cv.name;
            _fullNameController.text = cv.fullName ?? '';
            _emailController.text = cv.email ?? '';
            _phoneController.text = cv.phone ?? '';
            _locationController.text = cv.location ?? '';
            _roleController.text = cv.role ?? '';
            _summaryController.text = cv.summary ?? '';
            _educations = cv.educations ?? [];
            _experiences = cv.experiences ?? [];
            _projects = cv.projects ?? [];
            _skills = cv.skills ?? [];
            _selectedStyle = cv.styleTemplate ?? 'Classic';
            _profileImageUrl = cv.profileImage;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading CV: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveCV() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required personal information before saving.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final cv = CV(
        id: _cv?.id,
        name: _nameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        role: _roleController.text.trim(),
        summary: _summaryController.text.trim(),
        profileImage: _profileImageUrl,
        styleTemplate: _selectedStyle,
        educations: _educations,
        experiences: _experiences,
        projects: _projects,
        skills: _skills,
      );

      if (widget.cvId != null) {
        print('Updating CV with ID: ${widget.cvId}');
        await CVService.instance.updateCVInfo(widget.cvId!, cv);
      } else {
        print('Creating new CV');
        final newId = await CVService.instance.createCV(cv);
        print('CV created with ID: $newId');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV saved successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e, stackTrace) {
      print('Error saving CV: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before uploading a picture.')),
      );
      return;
    }

    final picker = ImagePicker();
    final selected = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (selected == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final bytes = await selected.readAsBytes();
      final extension = selected.name.contains('.')
          ? selected.name.split('.').last
          : 'jpg';

      final uploadedUrl = await StorageService.instance.uploadProfileImage(
        userId: user.uid,
        bytes: bytes,
        fileExtension: extension,
      );

      if (!mounted) return;
      setState(() {
        _profileImageUrl = uploadedUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Picture uploaded successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _roleController.dispose();
    _summaryController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.cvId != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('CV Builder')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Builder'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Personal Info', icon: Icon(Icons.person)),
            Tab(text: 'Education', icon: Icon(Icons.school)),
            Tab(text: 'Experience', icon: Icon(Icons.work)),
            Tab(text: 'Projects', icon: Icon(Icons.code)),
            Tab(text: 'Skills', icon: Icon(Icons.star)),
            Tab(text: 'Preview', icon: Icon(Icons.preview)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPersonalInfoTab(),
            _buildEducationTab(),
            _buildExperienceTab(),
            _buildProjectsTab(),
            _buildSkillsTab(),
            _buildPreviewTab(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveCV,
            icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
            label: Text(_isLoading ? 'Saving...' : 'Save CV'),
          ),
        ),
      ),
    );
  }

  // ==================== Personal Info Tab ====================
  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isUploadingImage ? null : _pickAndUploadProfileImage,
                  icon: _isUploadingImage
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_library_outlined),
                  label: Text(_isUploadingImage ? 'Uploading...' : 'Upload Picture'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'CV Name',
              prefixIcon: const Icon(Icons.label_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'e.g., "Senior Developer CV"',
            ),
            validator: (v) => v?.isEmpty ?? true ? 'CV name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Full name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v!)) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Phone is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Location is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _roleController,
            decoration: InputDecoration(
              labelText: 'Professional Role',
              prefixIcon: const Icon(Icons.work_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'e.g., "Senior Software Engineer"',
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Professional role is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _summaryController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Professional Summary',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              alignLabelWithHint: true,
            ),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Summary is required';
              if ((v?.length ?? 0) < 20) return 'Summary should be at least 20 characters';
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ==================== Education Tab ====================
  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Education',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (_educations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No education added yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _educations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final edu = _educations[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(edu.degree, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(edu.school, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _educations.removeAt(index))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${edu.startDate.year} - ${edu.endDate?.year ?? "Present"}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showEducationDialog(null),
            icon: const Icon(Icons.add),
            label: const Text('Add Education'),
          ),
        ],
      ),
    );
  }

  void _showEducationDialog(Education? education) {
    final schoolCtrl = TextEditingController(text: education?.school ?? '');
    final degreeCtrl = TextEditingController(text: education?.degree ?? '');
    final fieldCtrl = TextEditingController(text: education?.fieldOfStudy ?? '');
    DateTime startDate = education?.startDate ?? DateTime.now();
    DateTime? endDate = education?.endDate;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(education == null ? 'Add Education' : 'Edit Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: schoolCtrl,
                decoration: InputDecoration(labelText: 'School/University', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: degreeCtrl,
                decoration: InputDecoration(labelText: 'Degree', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fieldCtrl,
                decoration: InputDecoration(labelText: 'Field of Study', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 12),
              Text('Start Date: ${startDate.year}-${startDate.month.toString().padLeft(2, '0')}'),
              const SizedBox(height: 12),
              Text('End Date: ${endDate?.year.toString() ?? "Present"}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final edu = Education(
                id: education?.id,
                school: schoolCtrl.text,
                degree: degreeCtrl.text,
                startDate: startDate,
                endDate: endDate,
                fieldOfStudy: fieldCtrl.text,
              );
              setState(() {
                if (education == null) {
                  _educations.add(edu);
                } else {
                  final idx = _educations.indexOf(education);
                  _educations[idx] = edu;
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ==================== Experience Tab ====================
  Widget _buildExperienceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Work Experience',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (_experiences.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No experience added yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _experiences.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final exp = _experiences[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exp.role, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(exp.company, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _experiences.removeAt(index))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${exp.startDate.year} - ${exp.endDate?.year ?? "Present"}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showExperienceDialog(null),
            icon: const Icon(Icons.add),
            label: const Text('Add Experience'),
          ),
        ],
      ),
    );
  }

  void _showExperienceDialog(Experience? experience) {
    final companyCtrl = TextEditingController(text: experience?.company ?? '');
    final roleCtrl = TextEditingController(text: experience?.role ?? '');
    final descCtrl = TextEditingController(text: experience?.description ?? '');
    DateTime startDate = experience?.startDate ?? DateTime.now();
    DateTime? endDate = experience?.endDate;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(experience == null ? 'Add Experience' : 'Edit Experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: companyCtrl,
                decoration: InputDecoration(labelText: 'Company', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleCtrl,
                decoration: InputDecoration(labelText: 'Job Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 12),
              Text('Start Date: ${startDate.year}-${startDate.month.toString().padLeft(2, '0')}'),
              const SizedBox(height: 12),
              Text('End Date: ${endDate?.year.toString() ?? "Present"}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final exp = Experience(
                id: experience?.id,
                company: companyCtrl.text,
                role: roleCtrl.text,
                startDate: startDate,
                endDate: endDate,
                description: descCtrl.text,
              );
              setState(() {
                if (experience == null) {
                  _experiences.add(exp);
                } else {
                  final idx = _experiences.indexOf(experience);
                  _experiences[idx] = exp;
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ==================== Projects Tab ====================
  Widget _buildProjectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Projects',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (_projects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No project added yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final project = _projects[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                project.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _projects.removeAt(index))),
                          ],
                        ),
                        if (project.description != null && project.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(project.description!, style: Theme.of(context).textTheme.bodySmall),
                        ],
                        if (project.link != null && project.link!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(project.link!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showProjectDialog(null),
            icon: const Icon(Icons.add),
            label: const Text('Add Project'),
          ),
        ],
      ),
    );
  }

  void _showProjectDialog(Project? project) {
    final titleCtrl = TextEditingController(text: project?.title ?? '');
    final descriptionCtrl = TextEditingController(text: project?.description ?? '');
    final linkCtrl = TextEditingController(text: project?.link ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(project == null ? 'Add Project' : 'Edit Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: 'Project Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: linkCtrl,
                decoration: InputDecoration(labelText: 'Project Link', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project title is required')),
                );
                return;
              }

              final newProject = Project(
                id: project?.id,
                title: titleCtrl.text.trim(),
                description: descriptionCtrl.text.trim().isEmpty ? null : descriptionCtrl.text.trim(),
                link: linkCtrl.text.trim().isEmpty ? null : linkCtrl.text.trim(),
              );

              setState(() {
                if (project == null) {
                  _projects.add(newProject);
                } else {
                  final idx = _projects.indexOf(project);
                  _projects[idx] = newProject;
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ==================== Skills Tab ====================
  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Skills',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (_skills.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No skills added yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Chip(
                  label: Text(skill.name),
                  avatar: Icon(Icons.star, size: 18),
                  onDeleted: () => setState(() => _skills.remove(skill)),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showSkillDialog(null),
            icon: const Icon(Icons.add),
            label: const Text('Add Skill'),
          ),
        ],
      ),
    );
  }

  void _showSkillDialog(Skill? skill) {
    final nameCtrl = TextEditingController(text: skill?.name ?? '');
    String selectedLevel = skill?.level ?? 'Intermediate';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(skill == null ? 'Add Skill' : 'Edit Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: 'Skill Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedLevel,
              decoration: InputDecoration(labelText: 'Level', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              items: ['Beginner', 'Intermediate', 'Advanced', 'Expert'].map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
              onChanged: (val) => selectedLevel = val ?? 'Intermediate',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final newSkill = Skill(
                id: skill?.id,
                name: nameCtrl.text,
                level: selectedLevel,
              );
              setState(() {
                if (skill == null) {
                  _skills.add(newSkill);
                } else {
                  final idx = _skills.indexOf(skill);
                  _skills[idx] = newSkill;
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ==================== Preview Tab ====================
  Widget _buildPreviewTab() {
    final bool isModern = _selectedStyle == 'Modern';
    final bool isMinimal = _selectedStyle == 'Minimal';

    final headerColor = isModern
        ? Theme.of(context).primaryColor
        : isMinimal
            ? Colors.transparent
            : Theme.of(context).primaryColor.withOpacity(0.1);

    final headerTextColor = isModern ? Colors.white : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose CV Style', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cvStyles.map((styleName) {
              return ChoiceChip(
                label: Text(styleName),
                selected: _selectedStyle == styleName,
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _selectedStyle = styleName;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.circular(12),
              border: isMinimal ? Border.all(color: Colors.grey.shade300) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) ...[
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(_profileImageUrl!),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  _fullNameController.text.isEmpty ? 'Your Name' : _fullNameController.text,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: headerTextColor),
                ),
                Text(
                  _roleController.text.isEmpty ? 'Professional Role' : _roleController.text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: isModern ? Colors.white70 : Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Text(
                  _locationController.text.isEmpty ? 'Location' : _locationController.text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isModern ? Colors.white70 : null),
                ),
                Text(
                  _emailController.text.isEmpty ? 'email@example.com' : _emailController.text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isModern ? Colors.white70 : null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Summary
          if (_summaryController.text.isNotEmpty) ...[
            Text('Professional Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_summaryController.text, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
          ],
          // Experience
          if (_experiences.isNotEmpty) ...[
            Text('Experience', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._experiences.map((exp) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exp.role, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(exp.company, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  if (exp.description != null) ...[
                    const SizedBox(height: 4),
                    Text(exp.description!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          // Education
          if (_educations.isNotEmpty) ...[
            Text('Education', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._educations.map((edu) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(edu.degree, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(edu.school, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          // Skills
          if (_skills.isNotEmpty) ...[
            Text('Skills', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) => Chip(label: Text(skill.name))).toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Projects
          if (_projects.isNotEmpty) ...[
            Text('Projects', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._projects.map((project) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  if (project.description != null && project.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(project.description!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  if (project.link != null && project.link!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(project.link!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  ],
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}
