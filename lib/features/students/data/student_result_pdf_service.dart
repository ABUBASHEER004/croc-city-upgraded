
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StudentResultPdfService {
  StudentResultPdfService({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  static const PdfColor _navy =
      PdfColor.fromInt(0xFF0B1F3A);

  static const PdfColor _teal =
      PdfColor.fromInt(0xFF087F8C);

  static const PdfColor _gold =
      PdfColor.fromInt(0xFFD9A441);

  static const PdfColor _ink =
      PdfColor.fromInt(0xFF172033);

  static const PdfColor _muted =
      PdfColor.fromInt(0xFF667085);

  static const PdfColor _soft =
      PdfColor.fromInt(0xFFF4F7FA);

  Future<Uint8List> buildPdf({
    required String studentName,
    required String studentId,
    required String className,
    required String term,
    required String session,
    required List<Map<String, dynamic>> subjects,
    String photoUrl = '',
  }) async {
    final doc = pw.Document(
      author: 'Croc-City Football Academy',
      title:
          'Croc-City Football Academy Student Academic Report - '
          '$studentName',
    );

    final total = subjects.fold<double>(
      0,
      (sum, item) => sum + _number(item['score']),
    );

    final average = subjects.isEmpty
        ? 0.0
        : total / subjects.length;

    final logo = await _assetImage(
      'assets/images/logo.jpg',
    );

    final portrait = await _networkImage(photoUrl);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(
          34,
          30,
          34,
          34,
        ),
        header: (_) => _header(logo),
        footer: (context) => _footer(context),
        build: (_) => <pw.Widget>[
          pw.SizedBox(height: 14),

          _identityCard(
            name: studentName,
            id: studentId,
            className: className,
            term: term,
            session: session,
            portrait: portrait,
          ),

          pw.SizedBox(height: 18),

          _sectionTitle(
            'ACADEMIC PERFORMANCE',
          ),

          pw.SizedBox(height: 8),

          _summaryCards(
            average,
            subjects.length,
          ),

          pw.SizedBox(height: 16),

          pw.TableHelper.fromTextArray(
            headers: const <String>[
              'SUBJECT',
              'SCORE',
              'GRADE',
              'TEACHER REMARK',
            ],
            data: subjects
                .map<List<String>>(
                  (item) => <String>[
                    item['subject']?.toString() ?? '',
                    _number(item['score'])
                        .toStringAsFixed(0),
                    item['grade']?.toString() ??
                        _grade(
                          _number(item['score']),
                        ),
                    item['remark']?.toString() ?? '',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
            ),
            headerDecoration:
                const pw.BoxDecoration(
              color: _navy,
            ),
            rowDecoration:
                const pw.BoxDecoration(
              color: PdfColors.white,
            ),
            oddRowDecoration:
                const pw.BoxDecoration(
              color: _soft,
            ),
            cellStyle: const pw.TextStyle(
              color: _ink,
              fontSize: 11,
            ),
            cellPadding:
                const pw.EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 8,
            ),
            border: pw.TableBorder.all(
              color: PdfColor.fromInt(
                0xFFE1E7EF,
              ),
              width: .6,
            ),
            columnWidths: const <
                int,
                pw.TableColumnWidth
            >{
              0: pw.FlexColumnWidth(2.0),
              1: pw.FlexColumnWidth(.7),
              2: pw.FlexColumnWidth(.7),
              3: pw.FlexColumnWidth(2.4),
            },
          ),

          pw.SizedBox(height: 18),

          _gradingNote(),

          pw.SizedBox(height: 18),

          _officialNote(),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _header(
    pw.ImageProvider? logo,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(
        bottom: 10,
      ),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: _gold,
            width: 2,
          ),
        ),
      ),
      child: pw.Row(
        children: <pw.Widget>[
          if (logo != null)
            pw.Container(
              width: 44,
              height: 44,
              margin: const pw.EdgeInsets.only(
                right: 10,
              ),
              child: pw.Image(
                logo,
                fit: pw.BoxFit.contain,
              ),
            ),

          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  'CROC-CITY FOOTBALL ACADEMY',
                  style: pw.TextStyle(
                    fontSize: 21,
                    fontWeight:
                        pw.FontWeight.bold,
                    color: _navy,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'OFFICIAL STUDENT ACADEMIC REPORT',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight:
                        pw.FontWeight.bold,
                    color: _teal,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
          ),

          pw.Text(
            'ACADEMIC\nRECORD',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _muted,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _identityCard({
    required String name,
    required String id,
    required String className,
    required String term,
    required String session,
    required pw.ImageProvider? portrait,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: _soft,
        borderRadius:
            pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: PdfColor.fromInt(
            0xFFDDE5EE,
          ),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.center,
        children: <pw.Widget>[
          pw.Container(
            width: 76,
            height: 76,
            decoration: pw.BoxDecoration(
              color: _navy,
              borderRadius:
                  pw.BorderRadius.circular(38),
              border: pw.Border.all(
                color: _gold,
                width: 3,
              ),
            ),
            child: portrait != null
                ? pw.ClipOval(
                    child: pw.Image(
                      portrait,
                      fit: pw.BoxFit.cover,
                    ),
                  )
                : pw.Center(
                    child: pw.Text(
                      _initials(name),
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                  ),
          ),

          pw.SizedBox(width: 14),

          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  name,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight:
                        pw.FontWeight.bold,
                    color: _navy,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Row(
                  children: <pw.Widget>[
                    _meta(
                      'Student ID',
                      id,
                    ),
                    _meta(
                      'Class',
                      className.isEmpty
                          ? 'Not specified'
                          : className,
                    ),
                  ],
                ),

                pw.SizedBox(height: 6),

                pw.Row(
                  children: <pw.Widget>[
                    _meta(
                      'Term',
                      term,
                    ),
                    _meta(
                      'Session',
                      session,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _meta(
    String label,
    String value,
  ) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            label.toUpperCase(),
            style: const pw.TextStyle(
              fontSize: 11,
              color: _muted,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value.isEmpty ? '-' : value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight:
                  pw.FontWeight.bold,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryCards(
    double average,
    int count,
  ) {
    return pw.Row(
      children: <pw.Widget>[
        _stat(
          'AVERAGE',
          '${average.toStringAsFixed(1)}%',
          _teal,
        ),

        pw.SizedBox(width: 8),

        _stat(
          'SUBJECTS',
          '$count',
          _navy,
        ),

        pw.SizedBox(width: 8),

        _stat(
          'OVERALL GRADE',
          _grade(average),
          _gold,
        ),
      ],
    );
  }

  pw.Widget _stat(
    String label,
    String value,
    PdfColor accent,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius:
              pw.BorderRadius.circular(9),
          border: pw.Border.all(
            color: PdfColor.fromInt(
              0xFFE1E7EF,
            ),
          ),
        ),
        child: pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Container(
              width: 22,
              height: 3,
              color: accent,
            ),

            pw.SizedBox(height: 7),

            pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 11,
                color: _muted,
              ),
            ),

            pw.SizedBox(height: 3),

            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight:
                    pw.FontWeight.bold,
                color: _navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _sectionTitle(
    String text,
  ) {
    return pw.Row(
      children: <pw.Widget>[
        pw.Container(
          width: 4,
          height: 17,
          color: _gold,
        ),
        pw.SizedBox(width: 7),
        pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight:
                pw.FontWeight.bold,
            color: _navy,
            letterSpacing: .8,
          ),
        ),
      ],
    );
  }

  pw.Widget _gradingNote() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(
          0xFFFFFBF2,
        ),
        borderRadius:
            pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: PdfColor.fromInt(
            0xFFF0DFB5,
          ),
        ),
      ),
      child: pw.RichText(
        text: pw.TextSpan(
          children: <pw.TextSpan>[
            pw.TextSpan(
              text: 'Grading guide  ',
              style: pw.TextStyle(
                fontWeight:
                    pw.FontWeight.bold,
                color: _navy,
                fontSize: 11,
              ),
            ),
            const pw.TextSpan(
              text:
                  'A = 70-100   B = 60-69   C = 50-59   '
                  'D = 45-49   E = 40-44   F = below 40',
              style: pw.TextStyle(
                color: _muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
pw.Widget _officialNote() {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: _navy,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: <pw.Widget>[
        // Gold circle with "OK"
        pw.Container(
          width: 30,
          height: 30,
          decoration: pw.BoxDecoration(
            color: _gold,
            borderRadius: pw.BorderRadius.circular(15),
          ),
          child: pw.Center(
            child: pw.Text(
              'OK',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: _navy,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),

        pw.SizedBox(width: 10),

        pw.Expanded(
          child: pw.Text(
            'This document is an official digital academic '
            'record issued by Croc-City Football Academy. '
            'Please retain it for your records.',
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontSize: 11,
              lineSpacing: 1.3,
            ),
          ),
        ),
      ],
    ),
  );
}


  pw.Widget _footer(
    pw.Context context,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(
        top: 8,
      ),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Text(
            'Croc-City Football Academy • '
            'Confidential student record',
            style: const pw.TextStyle(
              fontSize: 11,
              color: _muted,
            ),
          ),

          pw.Spacer(),

          pw.Text(
            'Page ${context.pageNumber} '
            'of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 11,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Future<pw.ImageProvider?> _assetImage(
    String path,
  ) async {
    try {
      final data = await rootBundle.load(path);

      return pw.MemoryImage(
        data.buffer.asUint8List(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<pw.ImageProvider?> _networkImage(
    String url,
  ) async {
    if (url.trim().isEmpty) {
      return null;
    }

    try {
      return await networkImage(
        url.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  String _initials(
    String name,
  ) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
        )
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    return parts
        .take(2)
        .map(
          (part) => part[0].toUpperCase(),
        )
        .join();
  }

  Future<String> publishPdf({
    required String resultId,
    required String studentId,
    required Uint8List bytes,
  }) async {
    final ref = _storage
        .ref()
        .child('student_results')
        .child(studentId)
        .child('$resultId.pdf');

    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'application/pdf',
      ),
    );

    return ref.getDownloadURL();
  }

  Future<void> preview(
    Uint8List bytes,
  ) {
    return Printing.layoutPdf(
      onLayout: (_) async => bytes,
    );
  }

  Future<void> saveOrShare(
    Uint8List bytes,
    String filename,
  ) {
    return Printing.sharePdf(
      bytes: bytes,
      filename: filename,
    );
  }

  double _number(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _grade(
    double score,
  ) {
    if (score >= 70) {
      return 'A';
    }

    if (score >= 60) {
      return 'B';
    }

    if (score >= 50) {
      return 'C';
    }

    if (score >= 45) {
      return 'D';
    }

    if (score >= 40) {
      return 'E';
    }

    return 'F';
  }
}

