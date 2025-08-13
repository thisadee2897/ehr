import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/assessment_form.dart';
import '../../models/assessment_score.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class AssessmentListScreen extends ConsumerStatefulWidget {
  final int admissionId;

  const AssessmentListScreen({
    super.key,
    required this.admissionId,
  });

  @override
  ConsumerState<AssessmentListScreen> createState() => _AssessmentListScreenState();
}

class _AssessmentListScreenState extends ConsumerState<AssessmentListScreen> {
  List<AssessmentForm> _assessmentForms = [];
  List<AssessmentScore> _latestScores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(assessmentRepositoryProvider);
      
      // Load available assessment forms
      final forms = await repository.getAllAssessmentForms();
      
      // Load latest scores for this admission
      final latestScores = await repository.getLatestAssessmentScores(widget.admissionId);
      
      setState(() {
        _assessmentForms = forms;
        _latestScores = latestScores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การประเมิน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _navigateToHistory(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAssessmentList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAssessmentList() {
    if (_assessmentForms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('ไม่มีแบบประเมิน'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _createDefaultForms(),
              child: const Text('สร้างแบบประเมินเริ่มต้น'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _assessmentForms.length,
        itemBuilder: (context, index) {
          final form = _assessmentForms[index];
          final latestScore = _latestScores.where((score) => score.formId == form.formId).firstOrNull;
          return _buildAssessmentCard(form, latestScore);
        },
      ),
    );
  }

  Widget _buildAssessmentCard(AssessmentForm form, AssessmentScore? latestScore) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToAssessment(form),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      form.formName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (latestScore != null)
                    _buildScoreChip(latestScore.totalScore, latestScore.interpretation),
                ],
              ),
              const SizedBox(height: 8),
              
              if (form.formDetails['description'] != null) ...[
                Text(
                  form.formDetails['description'] as String,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              if (latestScore != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ประเมินล่าสุด: ${DateFormat('dd/MM/yyyy HH:mm').format(latestScore.assessmentDateTime)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ยังไม่ได้ประเมิน',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToAssessment(form),
                      icon: const Icon(Icons.edit),
                      label: Text(latestScore != null ? 'ประเมินใหม่' : 'ประเมิน'),
                    ),
                  ),
                  if (latestScore != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToHistory(form.formId),
                        icon: const Icon(Icons.history),
                        label: const Text('ประวัติ'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreChip(int score, String? interpretation) {
    Color color = Colors.grey;
    if (interpretation != null) {
      if (interpretation.contains('สูง') || interpretation.contains('high')) {
        color = Colors.red;
      } else if (interpretation.contains('ปานกลาง') || interpretation.contains('medium')) {
        color = Colors.orange;
      } else if (interpretation.contains('ต่ำ') || interpretation.contains('low')) {
        color = Colors.green;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (interpretation != null)
            Text(
              interpretation,
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToAssessment(AssessmentForm form) {
    Navigator.pushNamed(
      context,
      '/assessments/form',
      arguments: {
        'admissionId': widget.admissionId,
        'formId': form.formId,
        'formName': form.formName,
      },
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  void _navigateToHistory([int? formId]) {
    Navigator.pushNamed(
      context,
      '/assessments/history',
      arguments: {
        'admissionId': widget.admissionId,
        'formId': formId,
      },
    );
  }

  void _showCreateFormDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สร้างแบบประเมินใหม่'),
        content: const Text('คุณต้องการสร้างแบบประเมินใหม่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateForm();
            },
            child: const Text('สร้าง'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateForm() {
    Navigator.pushNamed(
      context,
      '/assessments/create-form',
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  Future<void> _createDefaultForms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(assessmentRepositoryProvider);
      
      // Create Fall Risk Assessment
      final fallRiskForm = AssessmentForm(
        formName: 'แบบประเมินความเสี่ยงต่อการพลัดตกหกล้ม',
        formDetails: {
          'description': 'ประเมินความเสี่ยงของผู้ป่วยต่อการพลัดตกหกล้ม',
          'questions': [
            {
              'id': 1,
              'text': 'มีประวัติหกล้มใน 3 เดือนที่ผ่านมา',
              'type': 'boolean',
              'score': {'true': 25, 'false': 0}
            },
            {
              'id': 2,
              'text': 'การวินิจฉัยรอง (มากกว่า 1 โรค)',
              'type': 'boolean',
              'score': {'true': 15, 'false': 0}
            },
            {
              'id': 3,
              'text': 'ต้องใช้อุปกรณ์ช่วยเดิน',
              'type': 'select',
              'options': ['ไม่ใช้', 'ไม้เท้า/walker', 'เก้าอี้รถเข็น', 'เตียง/พยาบาลช่วย'],
              'score': {'ไม่ใช้': 0, 'ไม้เท้า/walker': 15, 'เก้าอี้รถเข็น': 20, 'เตียง/พยาบาลช่วย': 30}
            },
            {
              'id': 4,
              'text': 'ติด IV หรือ Heparin lock',
              'type': 'boolean',
              'score': {'true': 20, 'false': 0}
            },
            {
              'id': 5,
              'text': 'ลักษณะการเดิน',
              'type': 'select',
              'options': ['ปกติ', 'อ่อนแอ', 'เดินไม่ได้'],
              'score': {'ปกติ': 0, 'อ่อนแอ': 10, 'เดินไม่ได้': 20}
            },
            {
              'id': 6,
              'text': 'สภาพจิตใจ',
              'type': 'select',
              'options': ['รู้สึกตัวดี', 'หลงลืม'],
              'score': {'รู้สึกตัวดี': 0, 'หลงลืม': 15}
            }
          ],
          'scoring': {
            'low': {'min': 0, 'max': 24, 'interpretation': 'ความเสี่ยงต่ำ'},
            'medium': {'min': 25, 'max': 50, 'interpretation': 'ความเสี่ยงปานกลาง'},
            'high': {'min': 51, 'max': 100, 'interpretation': 'ความเสี่ยงสูง'}
          }
        },
      );

      // Create Pain Assessment
      final painForm = AssessmentForm(
        formName: 'แบบประเมินความปวด',
        formDetails: {
          'description': 'ประเมินระดับความปวดของผู้ป่วย (Pain Scale 0-10)',
          'questions': [
            {
              'id': 1,
              'text': 'ระดับความปวด (0 = ไม่ปวด, 10 = ปวดมากที่สุด)',
              'type': 'scale',
              'min': 0,
              'max': 10,
              'score': 'value'
            },
            {
              'id': 2,
              'text': 'ลักษณะความปวด',
              'type': 'select',
              'options': ['จุกแน่น', 'แสบร้อน', 'เสียดแทง', 'ชาเสียว', 'ปวดแปล้บๆ'],
              'score': 'descriptive'
            },
            {
              'id': 3,
              'text': 'ตำแหน่งที่ปวด',
              'type': 'text',
              'score': 'descriptive'
            }
          ],
          'scoring': {
            'none': {'min': 0, 'max': 0, 'interpretation': 'ไม่ปวด'},
            'mild': {'min': 1, 'max': 3, 'interpretation': 'ปวดเล็กน้อย'},
            'moderate': {'min': 4, 'max': 6, 'interpretation': 'ปวดปานกลาง'},
            'severe': {'min': 7, 'max': 10, 'interpretation': 'ปวดมาก'}
          }
        },
      );

      await repository.createAssessmentForm(fallRiskForm);
      await repository.createAssessmentForm(painForm);

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สร้างแบบประเมินเริ่มต้นเรียบร้อยแล้ว')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }
}
