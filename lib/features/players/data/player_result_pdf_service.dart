import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PlayerResultPdfService {
  PlayerResultPdfService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;
  final FirebaseStorage _storage;

  static const _navy = PdfColor.fromInt(0xFF0B1F3A);
  static const _teal = PdfColor.fromInt(0xFF087F8C);
  static const _gold = PdfColor.fromInt(0xFFD9A441);
  static const _ink = PdfColor.fromInt(0xFF172033);
  static const _muted = PdfColor.fromInt(0xFF667085);
  static const _soft = PdfColor.fromInt(0xFFF4F7FA);

  Future<Uint8List> buildPdf({
    required String playerName,
    required String playerId,
    required String registrationNo,
    required String teamName,
    required String position,
    required String term,
    required String session,
    required List<Map<String, dynamic>> assessments,
    required String coachComment,
    String photoUrl = '',
  }) async {
    final doc = pw.Document(author: 'Croc City Football Academy', title: 'Player Performance Report - $playerName');
    final average = assessments.isEmpty ? 0.0 : assessments.fold<double>(0, (sum, item) => sum + _number(item['score'])) / assessments.length;
    final logo = await _assetImage('assets/images/logo.jpg');
    final portrait = await _networkImage(photoUrl);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(34, 30, 34, 34),
      header: (_) => _header(logo),
      footer: (context) => _footer(context),
      build: (_) => [
        pw.SizedBox(height: 14),
        _identityCard(name: playerName, id: playerId, registrationNo: registrationNo, teamName: teamName, position: position, term: term, session: session, portrait: portrait),
        pw.SizedBox(height: 18),
        _sectionTitle('PLAYER DEVELOPMENT PERFORMANCE'),
        pw.SizedBox(height: 8),
        _summaryCards(average, assessments.length),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: const ['ASSESSMENT AREA', 'SCORE', 'GRADE', 'COACH REMARK'],
          data: assessments.map((item) => [item['assessment']?.toString() ?? '', _number(item['score']).toStringAsFixed(0), item['grade']?.toString() ?? _grade(_number(item['score'])), item['remark']?.toString() ?? '']).toList(),
          headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: _navy),
          oddRowDecoration: const pw.BoxDecoration(color: _soft),
          cellStyle: const pw.TextStyle(color: _ink, fontSize: 9),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE1E7EF), width: .6),
          columnWidths: const {0: pw.FlexColumnWidth(1.8), 1: pw.FlexColumnWidth(.7), 2: pw.FlexColumnWidth(.7), 3: pw.FlexColumnWidth(2.6)},
        ),
        if (coachComment.trim().isNotEmpty) ...[
          pw.SizedBox(height: 18),
          _sectionTitle('COACH’S PROFESSIONAL COMMENT'),
          pw.SizedBox(height: 8),
          pw.Container(padding: const pw.EdgeInsets.all(12), decoration: pw.BoxDecoration(color: _soft, borderRadius: pw.BorderRadius.circular(8), border: pw.Border.all(color: PdfColor.fromInt(0xFFDDE5EE))), child: pw.Text(coachComment.trim(), style: const pw.TextStyle(fontSize: 9, color: _ink, lineSpacing: 1.35))),
        ],
        pw.SizedBox(height: 18),
        _gradingNote(),
        pw.SizedBox(height: 18),
        _officialNote(),
      ],
    ));
    return doc.save();
  }

  pw.Widget _header(pw.ImageProvider? logo) => pw.Container(padding: const pw.EdgeInsets.only(bottom: 10), decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _gold, width: 2))), child: pw.Row(children: [
    if (logo != null) pw.Container(width: 44, height: 44, margin: const pw.EdgeInsets.only(right: 10), child: pw.Image(logo, fit: pw.BoxFit.contain)),
    pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text('CROC CITY FOOTBALL ACADEMY', style: pw.TextStyle(fontSize: 16.5, fontWeight: pw.FontWeight.bold, color: _navy)), pw.SizedBox(height: 2), pw.Text('OFFICIAL PLAYER DEVELOPMENT REPORT', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _teal, letterSpacing: .7))])),
    pw.Text('PLAYER\nPROFILE', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _muted, letterSpacing: .5)),
  ]));

  pw.Widget _identityCard({required String name, required String id, required String registrationNo, required String teamName, required String position, required String term, required String session, required pw.ImageProvider? portrait}) => pw.Container(padding: const pw.EdgeInsets.all(15), decoration: pw.BoxDecoration(color: _soft, borderRadius: pw.BorderRadius.circular(12), border: pw.Border.all(color: PdfColor.fromInt(0xFFDDE5EE))), child: pw.Row(children: [
    pw.Container(width: 82, height: 82, decoration: pw.BoxDecoration(color: _navy, borderRadius: pw.BorderRadius.circular(41), border: pw.Border.all(color: _gold, width: 3)), child: portrait != null ? pw.ClipOval(child: pw.Image(portrait, fit: pw.BoxFit.cover)) : pw.Center(child: pw.Text(_initials(name), style: pw.TextStyle(color: PdfColors.white, fontSize: 23, fontWeight: pw.FontWeight.bold)))),
    pw.SizedBox(width: 14), pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _navy)), pw.SizedBox(height: 8), pw.Row(children: [_meta('Registration', registrationNo.isEmpty ? 'Not provided' : registrationNo), _meta('Player ID', id)]), pw.SizedBox(height: 6), pw.Row(children: [_meta('Team', teamName.isEmpty ? 'Not assigned' : teamName), _meta('Position', position.isEmpty ? 'Not provided' : position)]), pw.SizedBox(height: 6), pw.Row(children: [_meta('Term', term), _meta('Session', session)])]))
  ]));

  pw.Widget _meta(String label, String value) => pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(label.toUpperCase(), style: const pw.TextStyle(fontSize: 6.5, color: _muted)), pw.SizedBox(height: 2), pw.Text(value.isEmpty ? '—' : value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _ink))]));
  pw.Widget _summaryCards(double average, int count) => pw.Row(children: [_stat('AVERAGE', '${average.toStringAsFixed(1)}%', _teal), pw.SizedBox(width: 8), _stat('AREAS', '$count', _navy), pw.SizedBox(width: 8), _stat('OVERALL GRADE', _grade(average), _gold)]);
  pw.Widget _stat(String label, String value, PdfColor accent) => pw.Expanded(child: pw.Container(padding: const pw.EdgeInsets.all(10), decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(9), border: pw.Border.all(color: PdfColor.fromInt(0xFFE1E7EF))), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Container(width: 22, height: 3, color: accent), pw.SizedBox(height: 7), pw.Text(label, style: const pw.TextStyle(fontSize: 6.5, color: _muted)), pw.SizedBox(height: 3), pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _navy))])));
  pw.Widget _sectionTitle(String text) => pw.Row(children: [pw.Container(width: 4, height: 17, color: _gold), pw.SizedBox(width: 7), pw.Text(text, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _navy, letterSpacing: .8))]);
  pw.Widget _gradingNote() => pw.Container(padding: const pw.EdgeInsets.all(11), decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFFBF2), borderRadius: pw.BorderRadius.circular(8), border: pw.Border.all(color: PdfColor.fromInt(0xFFF0DFB5))), child: pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Performance guide  ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _navy, fontSize: 8)), const pw.TextSpan(text: 'A = 70–100   B = 60–69   C = 50–59   D = 45–49   E = 40–44   F = below 40', style: pw.TextStyle(color: _muted, fontSize: 8))])));
  pw.Widget _officialNote() => pw.Container(padding: const pw.EdgeInsets.all(11), decoration: pw.BoxDecoration(color: _navy, borderRadius: pw.BorderRadius.circular(8)), child: pw.Row(children: [pw.Text('✓', style: pw.TextStyle(color: _gold, fontSize: 16, fontWeight: pw.FontWeight.bold)), pw.SizedBox(width: 8), pw.Expanded(child: pw.Text('This document is an official digital player development record issued by Croc City Football Academy. Please retain it for your records.', style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, lineSpacing: 1.3)))]));
  pw.Widget _footer(pw.Context context) => pw.Container(padding: const pw.EdgeInsets.only(top: 8), child: pw.Row(children: [pw.Text('Croc City Football Academy • Confidential player record', style: const pw.TextStyle(fontSize: 7, color: _muted)), pw.Spacer(), pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 7, color: _muted))]));
  Future<pw.ImageProvider?> _assetImage(String path) async { try { return pw.MemoryImage((await rootBundle.load(path)).buffer.asUint8List()); } catch (_) { return null; } }
  Future<pw.ImageProvider?> _networkImage(String url) async { if (url.trim().isEmpty) return null; try { return await networkImage(url.trim()); } catch (_) { return null; } }
  String _initials(String name) { final parts = name.trim().split(RegExp(r'\s+')).where((x) => x.isNotEmpty).toList(); if (parts.isEmpty) return '?'; return parts.take(2).map((x) => x[0].toUpperCase()).join(); }
  Future<String> publishPdf({required String resultId, required String playerId, required Uint8List bytes}) async { final ref = _storage.ref('player_results/$playerId/$resultId.pdf'); await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf')); return ref.getDownloadURL(); }
  Future<void> saveOrShare(Uint8List bytes, String filename) => Printing.sharePdf(bytes: bytes, filename: filename);
  double _number(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
  String _grade(double score) { if (score >= 70) return 'A'; if (score >= 60) return 'B'; if (score >= 50) return 'C'; if (score >= 45) return 'D'; if (score >= 40) return 'E'; return 'F'; }
}
