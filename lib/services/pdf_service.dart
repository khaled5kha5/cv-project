import 'dart:typed_data';
import 'package:cv_project1/models/cv_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<Uint8List> generateCvPdf(CvModel cv) async {
    final document = pw.Document();

    final selectedStyle = cv.styleTemplate ?? 'Classic';
    final isModern = selectedStyle == 'Modern';
    final isCreative = selectedStyle == 'Creative';

    final PdfColor primaryColor = isModern
        ? PdfColors.blue700
        : isCreative
            ? PdfColors.grey700
            : PdfColors.blue600;

    final PdfColor headerBackground = isModern
        ? PdfColors.blue700
        : isCreative
            ? PdfColors.white
            : PdfColors.blue50;

    final experiences = cv.experiences ?? const [];
    final educations = cv.educations ?? const [];
    final skills = cv.skills ?? const [];
    final projects = cv.projects ?? const [];

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: headerBackground,
              borderRadius: pw.BorderRadius.circular(10),
              border: isCreative ? pw.Border.all(color: PdfColors.grey300, width: 1) : null,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  (cv.fullname?.isNotEmpty ?? false) ? cv.fullname! : cv.cvname,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: isModern ? PdfColors.white : PdfColors.black,
                  ),
                ),
                if (cv.role?.isNotEmpty ?? false) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    cv.role!,
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: isModern ? PdfColors.white : primaryColor,
                    ),
                  ),
                ],
                pw.SizedBox(height: 10),
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    if (cv.email?.isNotEmpty ?? false) _smallTag(cv.email!, isModern),
                    if (cv.phone?.isNotEmpty ?? false) _smallTag(cv.phone!, isModern),
                    if (cv.location?.isNotEmpty ?? false) _smallTag(cv.location!, isModern),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          if (cv.summary?.isNotEmpty ?? false) ...[
            _sectionTitle('Professional Summary', primaryColor),
            pw.SizedBox(height: 6),
            pw.Text(cv.summary!, style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
            pw.SizedBox(height: 12),
          ],
          if (experiences.isNotEmpty) ...[
            _sectionTitle('Experience', primaryColor),
            pw.SizedBox(height: 6),
            ...experiences.map(
              (experience) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            '${experience.position} • ${experience.company}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    if (experience.duration.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 2),
                        child: pw.Text(experience.duration, style: const pw.TextStyle(fontSize: 10.5)),
                      ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 8),
          ],
          if (educations.isNotEmpty) ...[
            _sectionTitle('Education', primaryColor),
            pw.SizedBox(height: 6),
            ...educations.map(
              (education) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('${education.degree} - ${education.university}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                          if (education.fieldOfStudy.isNotEmpty)
                            pw.Text(education.fieldOfStudy, style: const pw.TextStyle(fontSize: 10.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 8),
          ],
          if (skills.isNotEmpty) ...[
            _sectionTitle('Skills', primaryColor),
            pw.SizedBox(height: 6),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills.map((skill) => _skillChip(skill.name, isModern)).toList(),
            ),
            pw.SizedBox(height: 10),
          ],
          if (projects.isNotEmpty) ...[
            _sectionTitle('Projects', primaryColor),
            pw.SizedBox(height: 6),
            ...projects.map(
              (project) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(project.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    if (project.description?.isNotEmpty ?? false)
                      pw.Text(project.description!, style: const pw.TextStyle(fontSize: 10.5)),
                    if (project.link.isNotEmpty)
                      pw.Text(project.link, style: pw.TextStyle(fontSize: 10, color: PdfColors.blue700)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _sectionTitle(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: color, width: 1.5)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _smallTag(String text, bool isModern) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: isModern ? PdfColors.blue100 : PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9.5,
          color: isModern ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _skillChip(String skill, bool isModern) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: isModern ? PdfColors.blue50 : PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text(skill, style: const pw.TextStyle(fontSize: 9.5)),
    );
  }
}
