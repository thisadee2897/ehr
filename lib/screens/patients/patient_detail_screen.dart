import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/patient.dart';
import '../../models/admission.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final int patientId;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  Patient? _patient;
  List<Admission> _admissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patientRepository = ref.read(patientRepositoryProvider);
      final admissionRepository = ref.read(admissionRepositoryProvider);

      final patient = await patientRepository.getPatientById(widget.patientId);
      final admissions = await admissionRepository.getAdmissionsByPatientId(widget.patientId);

      setState(() {
        _patient = patient;
        _admissions = admissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('รายละเอียดผู้ป่วย'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ไม่พบข้อมูลผู้ป่วย'),
        ),
        body: const Center(
          child: Text('ไม่พบข้อมูลผู้ป่วยที่ต้องการ'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_patient!.fullName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.goToPatientEdit(widget.patientId),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('รีเฟรช'),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'refresh') {
                _loadPatientData();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatientData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientInfoCard(),
              const SizedBox(height: 16),
              _buildQuickActionsCard(),
              const SizedBox(height: 16),
              _buildAdmissionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    _patient!.gender == Gender.male ? Icons.man : Icons.woman,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patient!.fullName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'HN: ${_patient!.hospitalNumber}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('เลขประจำตัวประชาชน', _patient!.nationalId ?? 'ไม่ระบุ'),
            _buildInfoRow('วันเกิด', DateFormat('dd/MM/yyyy').format(_patient!.dateOfBirth)),
            _buildInfoRow('อายุ', '${_patient!.age} ปี'),
            _buildInfoRow('เพศ', _getGenderText(_patient!.gender)),
            _buildInfoRow('เบอร์โทรศัพท์', _patient!.phoneNumber ?? 'ไม่ระบุ'),
            _buildInfoRow('ศาสนา', _patient!.religion ?? 'ไม่ระบุ'),
            _buildInfoRow('สถานภาพสมรส', _getMaritalStatusText(_patient!.maritalStatus)),
            _buildInfoRow('สัญชาติ', _patient!.nationality ?? 'ไม่ระบุ'),
            if (_patient!.address != null) ...[
              const SizedBox(height: 8),
              Text(
                'ที่อยู่',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _patient!.address!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    final currentAdmission = _admissions.where((a) => a.isActive).firstOrNull;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'การดำเนินการ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.goToAdmissionNew(patientId: widget.patientId),
                    icon: const Icon(Icons.add),
                    label: const Text('เข้ารักษาใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (currentAdmission != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.goToAdmissionDetail(currentAdmission.admissionId!),
                      icon: const Icon(Icons.visibility),
                      label: const Text('ดูการรักษา'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdmissionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ประวัติการเข้ารักษา',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_admissions.isNotEmpty)
                  Text(
                    '${_admissions.length} ครั้ง',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_admissions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ยังไม่มีประวัติการเข้ารักษา',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: _admissions.map((admission) => _buildAdmissionItem(admission)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdmissionItem(Admission admission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: admission.isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: admission.isActive
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => context.goToAdmissionDetail(admission.admissionId!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: admission.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    admission.isActive ? 'กำลังรักษา' : 'จำหน่ายแล้ว',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'AN: ${admission.admissionNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'เข้ารักษา: ${DateFormat('dd/MM/yyyy HH:mm').format(admission.admissionDateTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!admission.isActive && admission.dischargeDateTime != null)
              Text(
                'จำหน่าย: ${DateFormat('dd/MM/yyyy HH:mm').format(admission.dischargeDateTime!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (admission.ward != null) ...[
              const SizedBox(height: 4),
              Text(
                'แผนก: ${admission.ward}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (admission.chiefComplaint != null) ...[
              const SizedBox(height: 4),
              Text(
                'อาการสำคัญ: ${admission.chiefComplaint}',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'ชาย';
      case Gender.female:
        return 'หญิง';
      case Gender.other:
        return 'อื่นๆ';
    }
  }

  String _getMaritalStatusText(MaritalStatus? status) {
    if (status == null) return 'ไม่ระบุ';
    switch (status) {
      case MaritalStatus.single:
        return 'โสด';
      case MaritalStatus.married:
        return 'สมรส';
      case MaritalStatus.divorced:
        return 'หย่าร้าง';
      case MaritalStatus.widowed:
        return 'หม้าย';
    }
  }
}
