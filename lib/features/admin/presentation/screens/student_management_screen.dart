import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../students/data/models/student.dart';
import '../../../students/data/student_result_pdf_service.dart';
import '../../../students/data/student_service.dart';

class StudentManagementScreen extends StatelessWidget {
  const StudentManagementScreen({
    super.key,
    this.showResults = false,
  });

  final bool showResults;

  @override
  Widget build(BuildContext context) {
    final service = StudentService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          showResults ? 'Student Results' : 'Education Centre',
        ),
      ),
      floatingActionButton: showResults
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showCreateStudent(context),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add student'),
            ),
      body: StreamBuilder<List<Student>>(
        stream: service.watchStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load students:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text('No students registered yet.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = students[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      student.firstName.isEmpty
                          ? '?'
                          : student.firstName[0].toUpperCase(),
                    ),
                  ),
                  title: Text(
                    student.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
  '${student.studentId} · ${student.className}\n'
  'Parent: ${student.parentName.isEmpty ? 'Not linked' : student.parentName}\n'
  'Coach: ${student.coachId.isEmpty ? 'Not linked' : student.coachId}\n'
  'Teacher: ${student.teacherId.isEmpty ? 'Not linked' : student.teacherId}',
),
                  isThreeLine: true,
                  trailing: showResults
                      ? const Icon(Icons.assessment_outlined)
                      : PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await _showEditStudent(context, student);
                            }

                            if (value == 'result') {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentResultScreen(
                                    student: student,
                                  ),
                                ),
                              );
                            }

                            if (value == 'delete') {
                              await _delete(context, student);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Link / Edit student'),
                            ),
                            PopupMenuItem(
                              value: 'result',
                              child: Text('Create result'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete student'),
                            ),
                          ],
                        ),
                  onTap: () {
                    if (showResults) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentResultScreen(
                            student: student,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    Student student,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete student?'),
          content: Text(
            'Remove ${student.fullName} from the Education Centre?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await StudentService().deleteStudent(student.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student deleted successfully.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete student: ${_cleanError(e)}',
          ),
        ),
      );
    }
  }

  Future<void> _showEditStudent(
    BuildContext context,
    Student student,
  ) async {
    final updated = await showDialog<Student>(
      context: context,
      builder: (_) => _StudentDialog(student: student),
    );

    if (updated == null) return;

    try {
      await StudentService().createStudent(updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student links updated successfully.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update student: ${_cleanError(e)}')),
      );
    }
  }

  Future<void> _showCreateStudent(
    BuildContext context,
  ) async {
    final student = await showDialog<Student>(
      context: context,
      builder: (_) => const _StudentDialog(),
    );

    if (student == null) {
      return;
    }

    try {
      await StudentService().createStudent(student);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student created successfully.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to create student: ${_cleanError(e)}',
          ),
        ),
      );
    }
  }

  static String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }
}

class _StudentDialog extends StatefulWidget {
  const _StudentDialog({this.student});

  final Student? student;

  @override
  State<_StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<_StudentDialog> {
  final _formKey = GlobalKey<FormState>();

  final firstController = TextEditingController();
  final lastController = TextEditingController();
  final studentIdController = TextEditingController();
  final classController = TextEditingController();
  final gradeController = TextEditingController();
  final phoneController = TextEditingController();

  String? parentId;
  String parentName = '';
  String? coachId;
  String? teacherId;
  String? userId;

  bool saving = false;
  String photoUrl = '';
  Uint8List? photoBytes;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    if (student != null) {
      firstController.text = student.firstName;
      lastController.text = student.lastName;
      studentIdController.text = student.studentId;
      classController.text = student.className;
      gradeController.text = student.gradeLevel;
      phoneController.text = student.phone;
      parentId = student.parentId.isEmpty ? null : student.parentId;
      parentName = student.parentName;
      coachId = student.coachId.isEmpty ? null : student.coachId;
      teacherId = student.teacherId.isEmpty ? null : student.teacherId;
      userId = student.userId.isEmpty ? null : student.userId;
      photoUrl = student.photoUrl;
    }
  }

  @override
  void dispose() {
    firstController.dispose();
    lastController.dispose();
    studentIdController.dispose();
    classController.dispose();
    gradeController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.student == null ? 'Add student' : 'Link / Edit student'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildPhotoPicker(),
                const SizedBox(height: 14),
                _field(
                  controller: firstController,
                  label: 'First name',
                  required: true,
                ),
                _field(
                  controller: lastController,
                  label: 'Last name',
                  required: true,
                ),
                _field(
                  controller: studentIdController,
                  label: 'Student ID',
                  required: true,
                ),
                _field(
                  controller: classController,
                  label: 'Class',
                ),
                _field(
                  controller: gradeController,
                  label: 'Grade level',
                ),
                _field(
                  controller: phoneController,
                  label: 'Phone',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                _buildParentSelector(),
                const SizedBox(height: 10),
                _buildCoachSelector(),
                const SizedBox(height: 10),
                _buildTeacherSelector(),
                const SizedBox(height: 10),
                _buildStudentAccountSelector(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: saving ? null : _save,
          icon: saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(
            saving ? 'Saving...' : (widget.student == null ? 'Save student' : 'Save changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    return Row(
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withOpacity(.08),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(.18)),
          ),
          clipBehavior: Clip.antiAlias,
          child: photoBytes != null
              ? Image.memory(photoBytes!, fit: BoxFit.cover)
              : photoUrl.isNotEmpty
                  ? Image.network(photoUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, size: 30))
                  : const Icon(Icons.school_rounded, size: 30),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Student photo', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text('Add a clear portrait. It will appear on the official PDF report.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 7),
            OutlinedButton.icon(
              onPressed: saving ? null : _pickPhoto,
              icon: const Icon(Icons.photo_camera_back_outlined, size: 18),
              label: Text(photoUrl.isEmpty && photoBytes == null ? 'Choose photo' : 'Change photo'),
            ),
          ]),
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 88);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => photoBytes = bytes);
  }

  Future<String> _uploadPhoto(String studentId) async {
    if (photoBytes == null) return photoUrl;
    final ref = FirebaseStorage.instance.ref('student_profiles/$studentId/profile.jpg');
    await ref.putData(photoBytes!, SettableMetadata(contentType: 'image/jpeg', cacheControl: 'public,max-age=3600'));
    return ref.getDownloadURL();
  }

  Widget _buildParentSelector() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', whereIn: const ['Parent', 'Player Parent', 'Student Parent'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Unable to load student parents.',
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final items = docs.map((document) {
          final data = document.data();

          final firstName =
              data['firstName']?.toString().trim() ?? '';
          final lastName =
              data['lastName']?.toString().trim() ?? '';

          final fullName =
              '$firstName $lastName'.trim();

          final email =
              data['email']?.toString().trim() ?? '';

          final displayName =
              fullName.isNotEmpty
                  ? fullName
                  : email.isNotEmpty
                      ? email
                      : 'Student Parent';

          return DropdownMenuItem<String>(
            value: document.id,
            child: Text(
              displayName,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();

        return DropdownButtonFormField<String>(
          initialValue: parentId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Student parent',
            prefixIcon: Icon(Icons.family_restroom_outlined),
          ),
          items: items,
          onChanged: (value) {
            if (value == null) {
              setState(() {
                parentId = null;
                parentName = '';
              });
              return;
            }

            final document = docs.firstWhere(
              (doc) => doc.id == value,
            );

            final data = document.data();

            final firstName =
                data['firstName']?.toString().trim() ?? '';
            final lastName =
                data['lastName']?.toString().trim() ?? '';

            final fullName =
                '$firstName $lastName'.trim();

            final email =
                data['email']?.toString().trim() ?? '';

            setState(() {
              parentId = document.id;
              parentName =
                  fullName.isNotEmpty ? fullName : email;
            });
          },
        );
      },
    );
  }

  Widget _buildCoachSelector() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Coach')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Unable to load coach accounts.');
        if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
        final docs = snapshot.data?.docs ?? const [];
        return DropdownButtonFormField<String>(
          initialValue: coachId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Coach', prefixIcon: Icon(Icons.sports_outlined)),
          hint: const Text('Assign coach (optional)'),
          items: [
            const DropdownMenuItem<String>(value: '', child: Text('No coach assigned yet')),
            ...docs.map((doc) {
              final data = doc.data();
              final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
              final email = data['email']?.toString() ?? '';
              return DropdownMenuItem<String>(
                value: doc.id,
                child: Text(name.isEmpty ? email : '$name · $email', overflow: TextOverflow.ellipsis),
              );
            }),
          ],
          onChanged: (value) => setState(() => coachId = value),
        );
      },
    );
  }

  Widget _buildTeacherSelector() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Teacher').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
        final docs = snapshot.data?.docs ?? const [];
        return DropdownButtonFormField<String>(
          initialValue: teacherId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Teacher', prefixIcon: Icon(Icons.school_outlined)),
          hint: const Text('Assign teacher (optional)'),
          items: [const DropdownMenuItem<String>(value: '', child: Text('No teacher assigned yet')), ...docs.map((doc) { final d=doc.data(); final name='${d['firstName']??''} ${d['lastName']??''}'.trim(); return DropdownMenuItem<String>(value:doc.id,child:Text(name.isEmpty?(d['email']?.toString()??'Teacher'):'$name · ${d['email']??''}',overflow:TextOverflow.ellipsis)); })],
          onChanged: (value) => setState(() => teacherId = value),
        );
      },
    );
  }

  Widget _buildStudentAccountSelector() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Student').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
        final docs = snapshot.data?.docs ?? const [];
        return DropdownButtonFormField<String>(
          initialValue: userId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Student login account', prefixIcon: Icon(Icons.account_circle_outlined)),
          hint: const Text('Link student portal account (optional)'),
          items: [const DropdownMenuItem<String>(value: '', child: Text('No student account linked yet')), ...docs.map((doc) { final d=doc.data(); final name='${d['firstName']??''} ${d['lastName']??''}'.trim(); return DropdownMenuItem<String>(value:doc.id,child:Text(name.isEmpty?(d['email']?.toString()??'Student'):'$name · ${d['email']??''}',overflow:TextOverflow.ellipsis)); })],
          onChanged: (value) => setState(() => userId = value),
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final id = widget.student?.id ?? studentIdController.text.trim();
      final savedPhotoUrl = await _uploadPhoto(id);
      final student = Student(
        id: id,
        studentId: studentIdController.text.trim(),
        firstName: firstController.text.trim(),
        lastName: lastController.text.trim(),
        parentId: parentId ?? '',
        parentName: parentName,
        coachId: coachId ?? '',
        teacherId: teacherId ?? '',
        userId: userId ?? '',
        photoUrl: savedPhotoUrl,
        className: classController.text.trim(),
        gradeLevel: gradeController.text.trim(),
        phone: phoneController.text.trim(),
        createdAt: DateTime.now(),
      );

      if (!mounted) return;

      Navigator.pop(context, student);
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }
}

class StudentResultScreen extends StatefulWidget {
  const StudentResultScreen({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  State<StudentResultScreen> createState() =>
      _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
  final service = StudentService();
  final pdfService = StudentResultPdfService();

  final termController =
      TextEditingController(text: 'First Term');

  final sessionController =
      TextEditingController(text: '2026/2027');

  final List<_SubjectRow> rows = [
    _SubjectRow(),
    _SubjectRow(),
    _SubjectRow(),
  ];

  bool loading = false;

  @override
  void dispose() {
    termController.dispose();
    sessionController.dispose();

    for (final row in rows) {
      row.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Results · ${widget.student.fullName}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          32,
        ),
        children: [
          _buildStudentHeader(),
          const SizedBox(height: 14),
          _buildSubjectsCard(),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: loading ? null : _publish,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(
              loading
                  ? 'Publishing...'
                  : 'Publish PDF result to parent',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Published results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _buildPublishedResults(),
        ],
      ),
    );
  }

  Widget _buildStudentHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.student.fullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.student.studentId} · '
              '${widget.student.className}',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: termController,
                    decoration: const InputDecoration(
                      labelText: 'Term',
                      prefixIcon:
                          Icon(Icons.calendar_month_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: sessionController,
                    decoration: const InputDecoration(
                      labelText: 'Session',
                      prefixIcon:
                          Icon(Icons.school_outlined),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Subject scores',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...rows.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final row = entry.value;

                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10),
                  child: _buildSubjectRow(
                    index,
                    row,
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addSubject,
                icon: const Icon(Icons.add),
                label: const Text('Add subject'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectRow(
    int index,
    _SubjectRow row,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: TextField(
            controller: row.subject,
            decoration: const InputDecoration(
              labelText: 'Subject',
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: TextField(
            controller: row.score,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Score',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextField(
            controller: row.remark,
            decoration: const InputDecoration(
              labelText: 'Remark',
            ),
          ),
        ),
        if (rows.length > 1)
          IconButton(
            tooltip: 'Remove subject',
            onPressed: () => _removeSubject(index),
            icon: const Icon(
              Icons.remove_circle_outline,
            ),
          ),
      ],
    );
  }

  Widget _buildPublishedResults() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.watchResults(widget.student.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Unable to load published results:\n'
                '${snapshot.error}',
              ),
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No results published yet.',
            ),
          );
        }

        return Column(
          children: items.map((result) {
            final pdfUrl =
                result['pdfUrl']?.toString();

            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.picture_as_pdf,
                  ),
                ),
                title: Text(
                  '${result['term'] ?? ''} · '
                  '${result['session'] ?? ''}',
                ),
                subtitle: Text(
                  DateFormat('d MMM yyyy').format(
                    _date(result['createdAt']),
                  ),
                ),
                trailing: pdfUrl != null &&
                        pdfUrl.isNotEmpty
                    ? const Icon(
                        Icons.cloud_done_rounded,
                      )
                    : const Icon(
                        Icons.pending_outlined,
                      ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _addSubject() {
    setState(() {
      rows.add(_SubjectRow());
    });
  }

  void _removeSubject(int index) {
    if (rows.length <= 1) {
      return;
    }

    final row = rows.removeAt(index);
    row.dispose();

    setState(() {});
  }

  Future<void> _publish() async {
    if (widget.student.parentId.trim().isEmpty) {
      _snack(
        'Link a Student Parent before publishing results.',
      );
      return;
    }

    final subjects = <Map<String, dynamic>>[];

    for (final row in rows) {
      final subjectName =
          row.subject.text.trim();

      final scoreText =
          row.score.text.trim();

      if (subjectName.isEmpty &&
          scoreText.isEmpty &&
          row.remark.text.trim().isEmpty) {
        continue;
      }

      final score =
          double.tryParse(scoreText);

      if (subjectName.isEmpty) {
        _snack(
          'Every result row must have a subject name.',
        );
        return;
      }

      if (score == null ||
          score < 0 ||
          score > 100) {
        _snack(
          'Enter a valid score between 0 and 100 for $subjectName.',
        );
        return;
      }

      subjects.add({
        'subject': subjectName,
        'score': score,
        'grade': _grade(score),
        'remark': row.remark.text.trim(),
      });
    }

    if (subjects.isEmpty) {
      _snack(
        'Add at least one subject.',
      );
      return;
    }

    final term = termController.text.trim();
    final session = sessionController.text.trim();

    if (term.isEmpty || session.isEmpty) {
      _snack(
        'Term and academic session are required.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final resultId = await service.saveResult(
        studentId: widget.student.id,
        parentId: widget.student.parentId,
        studentName: widget.student.fullName,
        term: term,
        session: session,
        subjects: subjects,
      );

      final bytes = await pdfService.buildPdf(
        studentName: widget.student.fullName,
        studentId: widget.student.studentId,
        className: widget.student.className,
        term: term,
        session: session,
        subjects: subjects,
        photoUrl: widget.student.photoUrl,
      );

      final pdfUrl = await pdfService.publishPdf(
        resultId: resultId,
        studentId: widget.student.id,
        bytes: bytes,
      );

      await service.updateResultPdf(
        resultId,
        pdfUrl,
      );

      if (!mounted) return;

      _snack(
        'Result published successfully. '
        'The student parent can now access the PDF.',
      );
    } catch (error) {
      if (!mounted) return;

      _snack(
        _cleanError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  DateTime _date(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
          value?.toString() ?? '',
        ) ??
        DateTime.now();
  }

  String _grade(double score) {
    if (score >= 70) return 'A';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C';
    if (score >= 45) return 'D';
    if (score >= 40) return 'E';
    return 'F';
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }
}

class _SubjectRow {
  final TextEditingController subject =
      TextEditingController();

  final TextEditingController score =
      TextEditingController();

  final TextEditingController remark =
      TextEditingController();

  void dispose() {
    subject.dispose();
    score.dispose();
    remark.dispose();
  }
}