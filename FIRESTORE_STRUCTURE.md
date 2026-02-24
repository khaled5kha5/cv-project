# Firestore Structure

## Database Schema

The application now uses the following Firestore structure:

```
users (collection)
 └── {uid} (document)
      ├── email: string
      ├── createdAt: timestamp
      └── cvs (subcollection)
           └── {cvId} (document)
                ├── name: string
                ├── fullName: string
                ├── email: string
                ├── phone: string
                ├── location: string
                ├── role: string
                ├── summary: string
                ├── styleTemplate: string
                ├── profileImage: string
                ├── educations: array [
                │    {
                │      school: string,
                │      degree: string,
                │      startDate: timestamp,
                │      endDate: timestamp,
                │      fieldOfStudy: string,
                │      grade: string
                │    }
                │ ]
                ├── experiences: array [
                │    {
                │      company: string,
                │      role: string,
                │      startDate: timestamp,
                │      endDate: timestamp,
                │      description: string,
                │      location: string,
                │      currentlyWorking: boolean
                │    }
                │ ]
                ├── projects: array [
                │    {
                │      title: string,
                │      description: string,
                │      link: string,
                │      technologies: array[string],
                │      createdDate: timestamp
                │    }
                │ ]
                ├── skills: array [
                │    {
                │      name: string,
                │      level: string
                │    }
                │ ]
                ├── createdAt: timestamp
                └── updatedAt: timestamp
```

## Key Changes

### 1. User Document Creation
- **File**: `lib/services/auth_service.dart`
- When a user registers, a document is automatically created in the `users` collection with their email and creation timestamp.

### 2. CV Data Storage
- **File**: `lib/models/cv.dart`
- CVs now store all related data (experiences, educations, skills, projects) as **arrays within the document** instead of using subcollections.
- The `toMap()` method serializes all arrays properly for Firestore.
- The `fromMap()` factory constructor deserializes the arrays back to model objects.

### 3. Service Layer Simplification
- **File**: `lib/services/cv_service.dart`
- Removed subcollection-related methods:
  - `getCVExperiences()`, `getCVEducations()`, `getCVSkills()`, `getCVProjects()`
  - `deleteExperienceFromCV()`, `deleteEducationFromCV()`, etc.
- Simplified `createCV()` to save everything in one document
- Simplified `updateCVInfo()` to update the entire document including arrays
- `getCV()` now returns complete CV data with all arrays populated

### 4. UI Updates
- **File**: `lib/screens/cv/preview_cv_screen.dart`
- Replaced `StreamBuilder` widgets that listened to subcollections with direct array access from the CV model
- All data (experiences, educations, skills, projects) is now accessed directly from the CV object

## Benefits of This Structure

1. **Simpler Queries**: Fetch all CV data in a single read operation
2. **Atomic Updates**: All CV data is updated together, ensuring consistency
3. **Better Performance**: No need for multiple subcollection queries
4. **Cost Efficient**: Fewer Firestore reads (1 read vs. 5 reads per CV)
5. **Easier Data Management**: All CV-related data is in one document

## Important Notes

- **Document Size Limit**: Firestore has a 1MB limit per document. For CVs with extensive data, this is typically sufficient.
- **Timestamps**: All date fields use Firestore `Timestamp` type and are automatically converted to/from Dart `DateTime`.
- **Server Timestamps**: `createdAt` and `updatedAt` use `FieldValue.serverTimestamp()` for consistency.
- **Backward Compatibility**: Existing CVs with subcollections will need migration to the new format.

## Migration Guide (if needed)

If you have existing data in the old subcollection format, you would need to:

1. Read each CV document
2. Fetch all related subcollections
3. Convert subcollection data to arrays
4. Update the CV document with the arrays
5. Delete the old subcollections

This migration is not included in the current implementation but can be created if needed.
