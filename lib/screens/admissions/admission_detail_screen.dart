import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admission.dart';
import '../../models/patient.dart';
import '../../providers/providers.dart';
import '../vital_signs/vital_signs_screen.dart';
import '../doctor_orders/doctor_order_list_screen.dart';
import '../progress_notes/progress_note_list_screen.dart';
import '../lab_results/lab_result_list_screen.dart';
import '../assessments/assessment_list_screen.dart';
import 'package:intl/intl.dart';

class AdmissionDetailScreen extends ConsumerStatefulWidget {
  final int admissionId;

  const AdmissionDetailScreen({
    super.key,
    required this.admissionId,
  });

  @override
  ConsumerState<AdmissionDetailScreen> createState() => _AdmissionDetailScreenState();
}

class _AdmissionDetailScreenState extends ConsumerState<AdmissionDetailScreen> {
  Admission? _admission;
  Patient? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdmissionData();
  }

  Future<void> _loadAdmissionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final admissionRepository = ref.read(admissionRepositoryProvider);
      final patientRepository = ref.read(patientRepositoryProvider);
      
      final admission = await admissionRepository.getAdmissionById(widget.admissionId);
      if (admission != null) {
        final patient = await patientRepository.getPatientById(admission.patientId);
        setState(() {
          _admission = admission;
          _patient = patient;
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('รายละเอียดการรักษา')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_admission == null || _patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('รายละเอียดการรักษา')),
        body: const Center(child: Text('ไม่พบข้อมูลการรักษา')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('AN: ${_admission!.admissionNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit admission
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPatientHeader(),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAdmissionInfo(),
                const SizedBox(height: 24),
                _buildFunctionMenu(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue[200],
            child: Text(
              _patient!.firstName[0].toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_patient!.firstName} ${_patient!.lastName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('HN: ${_patient!.hospitalNumber}'),
                Text('อายุ: ${DateTime.now().year - _patient!.dateOfBirth.year} ปี'),
                Text('เพศ: ${_patient!.gender.name}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ข้อมูลการรักษา',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('AN', _admission!.admissionNumber),
            _buildInfoRow('วันที่รับเข้า', 
                DateFormat('dd/MM/yyyy HH:mm').format(_admission!.admissionDateTime)),
            if (_admission!.dischargeDateTime != null)
              _buildInfoRow('วันที่จำหน่าย', 
                  DateFormat('dd/MM/yyyy HH:mm').format(_admission!.dischargeDateTime!)),
            if (_admission!.ward != null)
              _buildInfoRow('Ward', _admission!.ward!),
            if (_admission!.bedNumber != null)
              _buildInfoRow('เตียง', _admission!.bedNumber!),
            if (_admission!.chiefComplaint != null) ...[
              const SizedBox(height: 12),
              Text(
                'อาการสำคัญ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(_admission!.chiefComplaint!),
            ],
            if (_admission!.provisionalDiagnosis != null) ...[
              const SizedBox(height: 12),
              Text(
                'การวินิจฉัยแรกรับ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(_admission!.provisionalDiagnosis!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildFunctionMenu() {
    final menuItems = [
      {
        'title': 'สัญญาณชีพ',
        'subtitle': 'บันทึกและดูสัญญาณชีพ',
        'icon': Icons.favorite,
        'color': Colors.red,
        'onTap': () => _navigateToVitalSigns(),
      },
      {
        'title': 'คำสั่งการรักษา',
        'subtitle': 'คำสั่งแพทย์ และการรักษา',
        'icon': Icons.medication,
        'color': Colors.green,
        'onTap': () => _navigateToDoctorOrders(),
      },
      {
        'title': 'Progress Notes',
        'subtitle': 'บันทึกความก้าวหน้าการรักษา',
        'icon': Icons.notes,
        'color': Colors.blue,
        'onTap': () => _navigateToProgressNotes(),
      },
      {
        'title': 'ผลการตรวจ Lab',
        'subtitle': 'ผลการตรวจทางห้องปฏิบัติการ',
        'icon': Icons.science,
        'color': Colors.purple,
        'onTap': () => _navigateToLabResults(),
      },
      {
        'title': 'การประเมิน',
        'subtitle': 'แบบประเมินต่างๆ',
        'icon': Icons.assessment,
        'color': Colors.orange,
        'onTap': () => _navigateToAssessments(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เมนูการดูแลรักษา',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...menuItems.map((item) => _buildMenuItem(
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          icon: item['icon'] as IconData,
          color: item['color'] as Color,
          onTap: item['onTap'] as VoidCallback,
        )).toList(),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _navigateToVitalSigns() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VitalSignsScreen(admissionId: widget.admissionId),
      ),
    );
  }

  void _navigateToDoctorOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorOrderListScreen(admissionId: widget.admissionId),
      ),
    );
  }

  void _navigateToProgressNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressNoteListScreen(admissionId: widget.admissionId),
      ),
    );
  }

  void _navigateToLabResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LabResultListScreen(admissionId: widget.admissionId),
      ),
    );
  }

  void _navigateToAssessments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentListScreen(admissionId: widget.admissionId),
      ),
    );
  }
}
