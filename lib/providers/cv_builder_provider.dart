
import 'package:cv_project1/models/cv_model.dart';
import 'package:cv_project1/services/cv_service.dart';
import 'package:cv_project1/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CvBuilderProvider extends ChangeNotifier {
  final _cvService = CvService();
  final _storageService = StorageService();
  bool _isLoading = false;
  bool _isUploadingImage = false;
  CvModel? _cv;

  List<Education> _educationList = [];
  List<Experience> _experienceList = [];
  List<Project> _projectList = [];
  List<Skill> _skillList = [];

  String? _profileImageUrl;

  List<String> _styleTemplates = ['classic', 'modern', 'creative'];

  String? _styleTemplate = 'classic';

  

  List<ColorScheme> _colorSchemes = [
    ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    ColorScheme.fromSeed(seedColor: Colors.blueGrey),
    ColorScheme.fromSeed(seedColor: Colors.teal),
  ];

  ColorScheme? _selectedColorScheme;

  bool get isLoading => _isLoading;
  bool get isUploadingImage => _isUploadingImage;
  CvModel? get cv => _cv;
  List<Education> get educationList => _educationList;
  List<Experience> get experienceList => _experienceList;
  List<Project> get projectList => _projectList;
  List<Skill> get skillList => _skillList;
  String? get profileImageUrl => _profileImageUrl;
  List<String> get styleTemplates => _styleTemplates;
  String? get styleTemplate => _styleTemplate;
  List<ColorScheme> get colorSchemes => _colorSchemes;
  ColorScheme? get selectedColorScheme => _selectedColorScheme;

  void loadFromModel(CvModel cv) {
    if (_cv?.id == cv.id) return;
    _cv = cv;
    _educationList = cv.educations ?? [];
    _experienceList = cv.experiences ?? [];
    _projectList = cv.projects ?? [];
    _skillList = cv.skills ?? [];
    _profileImageUrl = cv.profileImage;
    _styleTemplate = cv.styleTemplate ?? 'classic';
    _selectedColorScheme = cv.colorScheme != null
        ? _colorSchemes.firstWhere(
            (scheme) =>
                scheme.primary.value.toRadixString(16) == cv.colorScheme,
            orElse: () => ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          )
        : ColorScheme.fromSeed(seedColor: Colors.deepPurple);
    notifyListeners();
  }
  
  void resetState() {
    _isLoading = false;
    _isUploadingImage = false;
    _cv = null;
    _educationList = [];
    _experienceList = [];
    _projectList = [];
    _skillList = [];
    _profileImageUrl = null;
    _styleTemplate = 'classic';
    _selectedColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
  }

  Future<void> initialize({
    String? cvId,
    required TextEditingController nameController,
    required TextEditingController fullNameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController locationController,
    required TextEditingController roleController,
    required TextEditingController summaryController,
  }) async {
    resetState();
    nameController.clear();
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    locationController.clear();
    roleController.clear();
    summaryController.clear();
    notifyListeners();

    if (cvId != null) {
      await loadCv(
        cvId: cvId,
        nameController: nameController,
        fullNameController: fullNameController,
        emailController: emailController,
        phoneController: phoneController,
        locationController: locationController,
        roleController: roleController,
        summaryController: summaryController,
      );
    }

  }

  Future<void> loadCv({
    required String? cvId,
    required TextEditingController nameController,
    required TextEditingController fullNameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController locationController,
    required TextEditingController roleController,
    required TextEditingController summaryController,
  }) async {
    if (cvId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final cv = await _cvService.getCvByIdOnce(cvId);
      if (cv == null) {
        throw Exception('CV not found');
      }
      _cv = cv;
      nameController.text = cv.cvname;
      fullNameController.text = cv.fullname ?? '';
      emailController.text = cv.email ?? '';
      phoneController.text = cv.phone ?? '';
      locationController.text = cv.location ?? '';
      roleController.text = cv.role ?? '';
      summaryController.text = cv.summary ?? '';
      _educationList = cv.educations ?? [];
      _experienceList = cv.experiences ?? [];
      _projectList = cv.projects ?? [];
      _skillList = cv.skills ?? [];
      _profileImageUrl = cv.profileImage ?? '';
      _styleTemplate = cv.styleTemplate ?? 'classic';
      _selectedColorScheme = cv.colorScheme != null
          ? _colorSchemes.firstWhere(
              (scheme) => scheme.primary.value.toRadixString(16) == cv.colorScheme,
              orElse: () => ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            )
          : ColorScheme.fromSeed(seedColor: Colors.deepPurple);
    } catch (e) {
      throw Exception('Error loading CV: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> saveCv({
    required String? cvId,
    required TextEditingController cvNameController,
    required TextEditingController fullNameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController locationController,
    required TextEditingController roleController,
    required TextEditingController summaryController,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final cv = CvModel(
        id: _cv?.id,
        cvname: cvNameController.text.trim(),
        fullname: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        location: locationController.text.trim(),
        role: roleController.text.trim(),
        summary: summaryController.text.trim(),
        profileImage: _profileImageUrl,
        educations: _educationList,
        experiences: _experienceList,
        projects: _projectList,
        skills: _skillList,
        styleTemplate: _styleTemplate,
        colorScheme: _selectedColorScheme?.primary.value.toRadixString(16),
      );


      if (cvId == null) {
        await _cvService.addCv(cv);
      } else {
        await _cvService.updateCv(cv);
      }
    } catch (e) {
      throw Exception('Error saving CV: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return; 
    }
    _isUploadingImage = true;
    notifyListeners();
    try {
      final bytes = await pickedFile.readAsBytes();
      final extension = pickedFile.name.contains('.') ? pickedFile.name.split('.').last : 'jpg';

      final uploadedUrl = await _storageService.uploadphoto(
        userId: user.uid,
        fileBytes: bytes,
        fileExtension: extension,);

      _profileImageUrl = uploadedUrl;
      notifyListeners();

    } catch (e) {
      print('Error uploading profile image: $e');
      _isUploadingImage = false;
      notifyListeners();
      rethrow;
    }
  }


  void removeEducation(int index) {
    _educationList.removeAt(index);
    notifyListeners();
  }

  void removeExperience(int index) {
    _experienceList.removeAt(index);
    notifyListeners();
  }

  void removeProject(int index) {
    _projectList.removeAt(index);
    notifyListeners();
  }

  void removeSkill(int index) {
    _skillList.removeAt(index);
    notifyListeners();
  }

  void upsertEducation(Education? oldValue, Education newValue) {
    if (oldValue == null) {
      _educationList.add(newValue);
    } else {
      final index = _educationList.indexOf(oldValue);
      _educationList[index] = newValue;
    }
    notifyListeners();
  }

  void upsertExperience(Experience? oldValue, Experience newValue) {
    if (oldValue == null) {
      _experienceList.add(newValue);
    } else {
      final index = _experienceList.indexOf(oldValue);
      _experienceList[index] = newValue;
    }
    notifyListeners();
  }

  void upsertProject(Project? oldValue, Project newValue) {
    if (oldValue == null) {
      _projectList.add(newValue);
    } else {
      final index = _projectList.indexOf(oldValue);
      _projectList[index] = newValue;
    }
    notifyListeners();
  }

  void upsertSkill(Skill? oldValue, Skill newValue) {
    if (oldValue == null) {
      _skillList.add(newValue);
    } else {
      final index = _skillList.indexOf(oldValue);
      _skillList[index] = newValue;
    }
    notifyListeners();
  }

  void setStyleTemplate(String styleTemplate) {
    _styleTemplate = styleTemplate;
    notifyListeners();
  }

  void setSelectedColorScheme(ColorScheme colorScheme) {
    _selectedColorScheme = colorScheme;
    notifyListeners();
  }


}