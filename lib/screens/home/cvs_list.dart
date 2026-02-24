import 'package:cv_project1/models/cv_model.dart';
import 'package:cv_project1/screens/cv/cv_builder_screen.dart';
import 'package:cv_project1/screens/cv/previewCv_screen.dart';
import 'package:cv_project1/services/cv_service.dart';
import 'package:flutter/material.dart';


class CvsListScreen extends StatefulWidget {
  const CvsListScreen({super.key});

  @override
  State<CvsListScreen> createState() => _CvsListScreenState();
}

class _CvsListScreenState extends State<CvsListScreen> {
  final CvService _cvService = CvService();

  Color _schemeColor(BuildContext context, CvModel cv) {
    final fallback = Theme.of(context).colorScheme.primary;
    final hex = cv.colorScheme;
    if (hex == null || hex.isEmpty) return fallback;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return fallback;
    return Color(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CVs List'),
        
      ),
      body: StreamBuilder<List<CvModel>>(
        stream: _cvService.getCvsStream(), 
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text('No CVs yet', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the button below to add your first CV',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
        }
        final cvs = snapshot.data ?? [];
        final onSurface = Theme.of(context).colorScheme.onSurface;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: cvs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cv = cvs[index];
            final schemeColor = _schemeColor(context, cv);
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Card(
              elevation: isDark ? 0 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreviewCvScreen(cvId: cv.id)),
                ),
                onLongPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CvBuilderScreen(cvId: cv.id)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: schemeColor.withOpacity(isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: cv.profileImage != null
                            ? CircleAvatar(
                                backgroundColor:
                                    schemeColor.withOpacity(isDark ? 0.4 : 0.8),
                                backgroundImage: NetworkImage(cv.profileImage!),
                              )
                            : Icon(
                                Icons.description_outlined,
                                color: schemeColor,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cv.cvname,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cv.fullname ?? 'No name provided',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    schemeColor.withOpacity(isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cv.styleTemplate ?? 'Classic',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: schemeColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: onSurface.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CvBuilderScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add CV'),

      ),
    );
  }
}