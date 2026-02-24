import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cv_project1/models/cv_model.dart';
import 'package:cv_project1/services/cv_service.dart';
import 'package:cv_project1/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PreviewCvProvider extends ChangeNotifier {
  final _cvService = CvService();

  CvModel? _cv;
  bool _isLoading = false;
  bool _isBusy = false;
  String? _errorMessage;

  // Getters
  CvModel? get cv => _cv;
  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  bool get cvExists => _cv != null;

  /// Load CV by ID
  Future<void> loadCv(String cvId) async {
    if (cvId.isEmpty) {
      _cv = null;
      _errorMessage = 'No CV selected';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cv = await _cvService.getCvByIdOnce(cvId);
      if (_cv == null) {
        _errorMessage = 'CV not found';
      }
    } catch (e) {
      _errorMessage = 'Error loading CV: $e';
      _cv = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Download CV as PDF
  Future<void> downloadCv() async {
    if (_isBusy || _cv == null) return;

    _isBusy = true;
    notifyListeners();

    try {
      final bytes = await PdfService().generateCvPdf(_cv!);
      await Printing.layoutPdf(
        name: '${_cv!.cvname}.pdf',
        onLayout: (format) async => bytes,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Download failed: $e';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Share CV as PDF
  Future<void> shareCv() async {
    if (_isBusy || _cv == null) return;

    _isBusy = true;
    notifyListeners();

    try {
      final bytes = await PdfService().generateCvPdf(_cv!);
      await Printing.sharePdf(bytes: bytes, filename: '${_cv!.cvname}.pdf');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Share failed: $e';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Format dates from Timestamp or DateTime
  String formatDates(dynamic start, dynamic end) {
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

  /// Clear provider state
  void clear() {
    _cv = null;
    _isLoading = false;
    _isBusy = false;
    _errorMessage = null;
    notifyListeners();
  }
}
