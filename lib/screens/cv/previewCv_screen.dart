import 'package:cv_project1/providers/cv_builder_provider.dart';
import 'package:cv_project1/providers/preview_cv_provider.dart';
import 'package:cv_project1/screens/cv/previewTap_template.dart';
import 'package:cv_project1/services/cv_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewCvScreen extends StatefulWidget {
  final String? cvId;
  const PreviewCvScreen({Key? key, this.cvId}) : super(key: key);

  @override
  State<PreviewCvScreen> createState() => _PreviewCvScreenState();
}

class _PreviewCvScreenState extends State<PreviewCvScreen> {
  final _previewProvider = PreviewCvProvider();
  final _builderProvider = CvBuilderProvider();
  final _cvService = CvService();

  @override
  void initState() {
    super.initState();
    _previewProvider.loadCv(widget.cvId ?? '');
  }

  @override
  void dispose() {
    _previewProvider.dispose();
    _builderProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _previewProvider),
        ChangeNotifierProvider.value(value: _builderProvider),
      ],
      child: Consumer2<PreviewCvProvider, CvBuilderProvider>(
        builder: (context, preview, builder, _) {
          if (preview.cv != null) {
            builder.loadFromModel(preview.cv!);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(preview.cv?.cvname ?? 'Preview CV'),
              actions: [
                if (preview.isBusy)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: preview.cvExists ? preview.downloadCv : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: preview.cvExists ? preview.shareCv : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: preview.cvExists && widget.cvId != null
                        ? () => _confirmDelete(context)
                        : null,
                  ),
                ],
              ],
            ),
            body: _buildBody(context, preview, builder),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PreviewCvProvider preview,
    CvBuilderProvider builder,
  ) {
    if (preview.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (preview.errorMessage != null) {
      return Center(child: Text(preview.errorMessage!));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: templateSelector(builder, context),
          ),
          const SizedBox(height: 16),
          _previewSection(
            title: 'Choose CV Color Scheme',
            color: sectionBg,
            child: colorSelector(builder),
          ),
          const SizedBox(height: 16),
          _previewSection(
            title: 'CV Preview',
            color: sectionBg,
            child: cvPaper(buildLayout(builder), context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete CV'),
        content: const Text(
          'Are you sure you want to delete this CV? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || widget.cvId == null) return;

    await _cvService.deleteCv(widget.cvId!);
    if (mounted) {
      Navigator.of(context).pop();
    }
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
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.computeLuminance() > 0.5 ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
