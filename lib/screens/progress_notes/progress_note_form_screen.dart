import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../models/progress_note.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class ProgressNoteFormScreen extends ConsumerStatefulWidget {
  final int admissionId;
  final int? noteId;

  const ProgressNoteFormScreen({
    super.key,
    required this.admissionId,
    this.noteId,
  });

  @override
  ConsumerState<ProgressNoteFormScreen> createState() => _ProgressNoteFormScreenState();
}

class _ProgressNoteFormScreenState extends ConsumerState<ProgressNoteFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  ProgressNote? _editingNote;
  bool _isLoading = false;
  bool _isEdit = false;
  List<String> _existingProblems = [];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.noteId != null;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(progressNoteRepositoryProvider);
      
      // Load existing problems for autocomplete
      final problems = await repository.getUniqueProblems(widget.admissionId);
      setState(() {
        _existingProblems = problems;
      });

      // Load note data if editing
      if (_isEdit) {
        final note = await repository.getProgressNoteById(widget.noteId!);
        setState(() {
          _editingNote = note;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'แก้ไข Progress Note' : 'เพิ่ม Progress Note'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveNote,
          child: Text(_isEdit ? 'บันทึกการแก้ไข' : 'เพิ่ม Note'),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FormBuilder(
        key: _formKey,
        initialValue: _getInitialValues(),
        child: Column(
          children: [
            // DateTime
            FormBuilderDateTimePicker(
              name: 'noteDateTime',
              decoration: const InputDecoration(
                labelText: 'วันที่และเวลา *',
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.required(
                errorText: 'กรุณาเลือกวันที่และเวลา',
              ),
              format: DateFormat('dd/MM/yyyy HH:mm'),
            ),
            const SizedBox(height: 16),

            // Problem
            FormBuilderTextField(
              name: 'problem',
              decoration: InputDecoration(
                labelText: 'Problem',
                border: const OutlineInputBorder(),
                hintText: 'เช่น Fever, Abdominal Pain, Hypertension',
                suffixIcon: _existingProblems.isNotEmpty
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (value) {
                          _formKey.currentState?.fields['problem']?.didChange(value);
                        },
                        itemBuilder: (context) => _existingProblems
                            .map((problem) => PopupMenuItem(
                                  value: problem,
                                  child: Text(problem),
                                ))
                            .toList(),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // S.O.A.P. Note Info Card
            _buildSOAPInfoCard(),
            const SizedBox(height: 16),

            // Subjective
            FormBuilderTextField(
              name: 'subjective',
              decoration: const InputDecoration(
                labelText: 'S - Subjective (ข้อมูลจากผู้ป่วย)',
                border: OutlineInputBorder(),
                hintText: 'อาการที่ผู้ป่วยบอกเล่า, ความรู้สึก, ประวัติ',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Objective
            FormBuilderTextField(
              name: 'objective',
              decoration: const InputDecoration(
                labelText: 'O - Objective (ข้อมูลที่ตรวจวัดได้)',
                border: OutlineInputBorder(),
                hintText: 'สัญญาณชีพ, การตรวจร่างกาย, ผล Lab, การตรวจพิเศษ',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Assessment
            FormBuilderTextField(
              name: 'assessment',
              decoration: const InputDecoration(
                labelText: 'A - Assessment (การประเมิน)',
                border: OutlineInputBorder(),
                hintText: 'การวินิจฉัย, การประเมินปัญหา, ความคิดเห็นทางแพทย์',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Plan
            FormBuilderTextField(
              name: 'plan',
              decoration: const InputDecoration(
                labelText: 'P - Plan (แผนการรักษา)',
                border: OutlineInputBorder(),
                hintText: 'แผนการรักษา, การดูแล, การติดตาม, คำสั่งเพิ่มเติม',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOAPInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'S.O.A.P. Note Format',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSOAPExample('S', 'Subjective', 'ผู้ป่วยบอกปวดท้อง มา 2 วัน รู้สึกคลื่นไส้'),
            _buildSOAPExample('O', 'Objective', 'BT 38.5°C, BP 120/80, ท้องอ่อน tender epigastrium'),
            _buildSOAPExample('A', 'Assessment', 'Acute gastritis, rule out peptic ulcer'),
            _buildSOAPExample('P', 'Plan', 'NPO, IV fluid, PPI, check CBC, monitor symptoms'),
          ],
        ),
      ),
    );
  }

  Widget _buildSOAPExample(String letter, String title, String example) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getSOAPColor(letter),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $example',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSOAPColor(String section) {
    switch (section) {
      case 'S':
        return Colors.green;
      case 'O':
        return Colors.blue;
      case 'A':
        return Colors.orange;
      case 'P':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> _getInitialValues() {
    if (_editingNote == null) {
      return {
        'noteDateTime': DateTime.now(),
      };
    }

    return {
      'noteDateTime': _editingNote!.noteDateTime,
      'problem': _editingNote!.problem,
      'subjective': _editingNote!.subjective,
      'objective': _editingNote!.objective,
      'assessment': _editingNote!.assessment,
      'plan': _editingNote!.plan,
    };
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    // Check if at least one SOAP field is filled
    final formData = _formKey.currentState!.value;
    final hasContent = [
      formData['subjective'],
      formData['objective'],
      formData['assessment'],
      formData['plan'],
    ].any((field) => field != null && field.toString().trim().isNotEmpty);

    if (!hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลอย่างน้อยหนึ่งส่วนของ S.O.A.P.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(progressNoteRepositoryProvider);

      final note = ProgressNote(
        noteId: _editingNote?.noteId,
        admissionId: widget.admissionId,
        noteDateTime: formData['noteDateTime'] as DateTime,
        authorProviderId: 1, // TODO: Get from current user
        problem: formData['problem']?.toString().trim().isEmpty == true 
            ? null 
            : formData['problem'] as String?,
        subjective: formData['subjective']?.toString().trim().isEmpty == true 
            ? null 
            : formData['subjective'] as String?,
        objective: formData['objective']?.toString().trim().isEmpty == true 
            ? null 
            : formData['objective'] as String?,
        assessment: formData['assessment']?.toString().trim().isEmpty == true 
            ? null 
            : formData['assessment'] as String?,
        plan: formData['plan']?.toString().trim().isEmpty == true 
            ? null 
            : formData['plan'] as String?,
      );

      if (_isEdit) {
        await repository.updateProgressNote(note);
      } else {
        await repository.createProgressNote(note);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'แก้ไข Note เรียบร้อยแล้ว' : 'เพิ่ม Note เรียบร้อยแล้ว'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบ Progress Note นี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteNote();
    }
  }

  Future<void> _deleteNote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(progressNoteRepositoryProvider);
      await repository.deleteProgressNote(widget.noteId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบ Note เรียบร้อยแล้ว')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
