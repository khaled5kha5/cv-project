
import 'package:cv_project1/providers/cv_builder_provider.dart';
import 'package:cv_project1/models/cv_model.dart';
import 'package:cv_project1/screens/cv/previewTap_template.dart';
import 'package:cv_project1/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CvBuilderScreen extends StatefulWidget {
  final String? cvId;
  const CvBuilderScreen({super.key, this.cvId});

  @override
  State<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends State<CvBuilderScreen> with TickerProviderStateMixin{

  late TabController _tabController;

  final _nameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _roleController = TextEditingController();
  final _summaryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<CvBuilderProvider>().initialize(
          cvId: widget.cvId,
          nameController: _nameController,
          fullNameController: _fullNameController,
          emailController: _emailController,
          phoneController: _phoneController,
          locationController: _locationController,
          roleController: _roleController,
          summaryController: _summaryController,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading CV: $e')));
      }
    });
  }

  Future<void> _saveCV() async {
    final cvProvider = context.read<CvBuilderProvider>();

    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required personal information before saving.')),
      );
      return;
    }

    try {
      await cvProvider.saveCv(
        cvId: widget.cvId,
        cvNameController: _nameController,
        fullNameController: _fullNameController,
        emailController: _emailController,
        phoneController: _phoneController,
        locationController: _locationController,
        roleController: _roleController,
        summaryController: _summaryController,
      );

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
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    try {
      await context.read<CvBuilderProvider>().uploadProfileImage();

      if (!mounted) return;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvProvider = context.watch<CvBuilderProvider>();

    if (cvProvider.isLoading && widget.cvId != null) {
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
            Tab(icon: Icon(Icons.person)),
            Tab(icon: Icon(Icons.school)),
            Tab(icon: Icon(Icons.work)),
            Tab(icon: Icon(Icons.code)),
            Tab(icon: Icon(Icons.star)),
            Tab(icon: Icon(Icons.preview)),
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
            onPressed: cvProvider.isLoading ? null : _saveCV,
            icon: cvProvider.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
            label: Text(cvProvider.isLoading ? 'Saving...' : 'Save CV'),
          ),
        ),
      ),
    );
  }

  // ==================== Personal Info Tab ====================
  Widget _buildPersonalInfoTab() {
    final cvProvider = context.watch<CvBuilderProvider>();
    final accentColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundImage: cvProvider.profileImageUrl != null && cvProvider.profileImageUrl!.isNotEmpty
                      ? NetworkImage(cvProvider.profileImageUrl!)
                      : null,
                  child: (cvProvider.profileImageUrl == null || cvProvider.profileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: cvProvider.isUploadingImage ? null : _pickAndUploadProfileImage,
                  icon: cvProvider.isUploadingImage
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_library_outlined),
                  label: Text(cvProvider.isUploadingImage ? 'Uploading...' : 'Upload Picture'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),
                      side: BorderSide(color: accentColor),
                    ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            style: TextStyle(backgroundColor: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),),
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
            style: TextStyle(backgroundColor: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),),
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
            style: TextStyle(backgroundColor: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),),
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
            style: TextStyle(backgroundColor: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),),
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
            style: TextStyle(backgroundColor: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),),
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
            style: TextStyle(backgroundColor: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),),
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
            style: TextStyle(backgroundColor: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),),
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
      ),
    );
  }

  // ==================== Education Tab ====================
  Widget _buildEducationTab() {
    final cvProvider = context.watch<CvBuilderProvider>();
    final accentColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Education',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          const SizedBox(height: 24),
          if (cvProvider.educationList.isEmpty)
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
              itemCount: cvProvider.educationList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final edu = cvProvider.educationList[index];
                return Card(
                  color: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),
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
                                  Text(edu.university, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(edu.degree, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                  Text(edu.fieldOfStudy, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            
                            IconButton(icon: Icon(Icons.edit, color: AppTheme.accent), onPressed: () => _showEducationDialog(edu)),
                            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => cvProvider.removeEducation(index)),
                          ],
                        ),
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
      ),
      
        
      
    );
  }

  void _showEducationDialog(Education? education) {
    final universityCtrl = TextEditingController(text: education?.university ?? '');
    final degreeCtrl = TextEditingController(text: education?.degree ?? '');
    final fieldCtrl = TextEditingController(text: education?.fieldOfStudy ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(education == null ? 'Add Education' : 'Edit Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: universityCtrl,
                decoration: InputDecoration(labelText: 'University', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
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
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final edu = Education(
                id: education?.id ?? UniqueKey().toString(),
                university: universityCtrl.text,
                degree: degreeCtrl.text,
                fieldOfStudy: fieldCtrl.text,
              );
              context.read<CvBuilderProvider>().upsertEducation(education, edu);
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
    final cvProvider = context.watch<CvBuilderProvider>();
    final accentColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Work Experience',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          const SizedBox(height: 24),
          if (cvProvider.experienceList.isEmpty)
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
              itemCount: cvProvider.experienceList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final exp = cvProvider.experienceList[index];
                return Card(
                  color: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),
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
                                  Text(exp.position, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(exp.company, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                  Text(exp.duration, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            
                            IconButton(icon: const Icon(Icons.edit, color: AppTheme.accent), onPressed: () => _showExperienceDialog(exp)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => cvProvider.removeExperience(index)),
                          ],
                        ),
                        
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
      ),
    );
  }

  void _showExperienceDialog(Experience? experience) {
    final companyCtrl = TextEditingController(text: experience?.company ?? '');
    final positionCtrl = TextEditingController(text: experience?.position ?? '');
    final durationCtrl = TextEditingController(text: experience?.duration ?? '');

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
                controller: positionCtrl,
                decoration: InputDecoration(labelText: 'Job Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationCtrl,
                decoration: InputDecoration(labelText: 'Duration', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final exp = Experience(
                id: experience?.id ?? UniqueKey().toString(),
                company: companyCtrl.text,
                position: positionCtrl.text,
                duration: durationCtrl.text,
              );
              context.read<CvBuilderProvider>().upsertExperience(experience, exp);
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
    final cvProvider = context.watch<CvBuilderProvider>();
    final accentColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Projects',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          const SizedBox(height: 24),
          if (cvProvider.projectList.isEmpty)
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
              itemCount: cvProvider.projectList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final project = cvProvider.projectList[index];
                return Card(
                  color: accentColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.2),
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
                            
                            IconButton(icon: const Icon(Icons.edit, color: AppTheme.accent), onPressed: () => _showProjectDialog(project)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => cvProvider.removeProject(index)),
                          ],
                        ),
                          if (project.description != null && project.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(project.description!, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          ],
                        
                          Text(project.link, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                        
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
              if (linkCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid URL for the project link')),
                );
                return;
              }

              final newProject = Project(
                id: project?.id ?? UniqueKey().toString(),
                title: titleCtrl.text.trim(),
                description: descriptionCtrl.text.trim().isEmpty ? null : descriptionCtrl.text.trim(),
                link: linkCtrl.text.trim(),
              );

              context.read<CvBuilderProvider>().upsertProject(project, newProject);
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
    final cvProvider = context.watch<CvBuilderProvider>();
    final accentColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Skills',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          const SizedBox(height: 24),
          if (cvProvider.skillList.isEmpty)
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
              children: cvProvider.skillList.map((skill) {
                return InkWell(
                  onTap: () => _showSkillDialog(skill),
                  child: Chip(
                    label: Text(skill.name),
                    avatar: Icon(Icons.star, size: 18),
                    onDeleted: () => cvProvider.removeSkill(cvProvider.skillList.indexOf(skill)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    deleteIconColor: Colors.red,
                    backgroundColor: accentColor.withOpacity(0.1),
                    side: BorderSide(color: accentColor.withOpacity(0.2)),
                  ),
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
    ),
    );
  }

  void _showSkillDialog(Skill? skill) {
    final nameCtrl = TextEditingController(text: skill?.name ?? '');
    String selectedLevel = skill?.proficiency ?? 'Intermediate';

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
                id: skill?.id ?? UniqueKey().toString(),
                name: nameCtrl.text,
                proficiency: selectedLevel,
              );
              context.read<CvBuilderProvider>().upsertSkill(skill, newSkill);
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
    final cvProvider = context.watch<CvBuilderProvider>();
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final sectionBg = isDark
        ? Colors.white.withOpacity(0.05)
        : Theme.of(context).colorScheme.surfaceContainerLow;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _previewSection(
            title: 'Choose CV Template',
            color: sectionBg,
            child: templateSelector(cvProvider, context),
          ),
          const SizedBox(height: 16),
          _previewSection(
            title: 'Choose CV Color Scheme',
            color: sectionBg,
            child: colorSelector(cvProvider),
          ),
          const SizedBox(height: 16),
          _previewSection(
            title: 'CV Preview',
            color: sectionBg,
            child: cvPaper(buildLayout(cvProvider), context),
          ),
        ],
      ),
    );
  }
}
Widget _previewSection({
    required String title,
    required Color color,
    required Widget child,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: color.computeLuminance() > 0.5 ? Colors.white : Colors.black)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );