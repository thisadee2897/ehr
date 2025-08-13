import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../models/admission.dart';
import '../../models/patient.dart';
import '../../models/healthcare_provider.dart';
import '../../providers/providers.dart';

class AdmissionFormScreen extends ConsumerStatefulWidget {
  final int? patientId;
  final int? admissionId;

  const AdmissionFormScreen({
    super.key,
    this.patientId,
    this.admissionId,
  });

  @override
  ConsumerState<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends ConsumerState<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Admission? _admission;
  List<Patient> _patients = [];
  List<HealthcareProvider> _doctors = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final patientRepo = ref.read(patientRepositoryProvider);
      
      // Load patients and doctors
      _patients = await patientRepo.getAllPatients();
      
      // For now, create mock doctors list since we don't have the provider yet
      _doctors = [
        HealthcareProvider(
          providerId: 1,
          licenseNumber: 'DOC001',
          firstName: 'สมศักดิ์',
          lastName: 'ใจดี',
          providerType: ProviderType.doctor,
          specialty: 'อายุรกรรม',
        ),
        HealthcareProvider(
          providerId: 2,
          licenseNumber: 'DOC002',
          firstName: 'สมหญิง',
          lastName: 'รักษาดี',
          providerType: ProviderType.doctor,
          specialty: 'ศัลยกรรม',
        ),
      ];
      
      // Load admission data if editing
      if (widget.admissionId != null) {
        final admissionRepo = ref.read(admissionRepositoryProvider);
        _admission = await admissionRepo.getAdmissionById(widget.admissionId!);
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAdmission() async {
    if (!_formKey.currentState!.saveAndValidate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final formData = _formKey.currentState!.value;
      final admissionRepo = ref.read(admissionRepositoryProvider);
      
      final admission = Admission(
        admissionId: _admission?.admissionId,
        admissionNumber: formData['admissionNumber'],
        patientId: formData['patientId'],
        admissionDateTime: formData['admissionDateTime'],
        dischargeDateTime: formData['dischargeDateTime'],
        admittingDoctorId: formData['admittingDoctorId'],
        chiefComplaint: formData['chiefComplaint'],
        presentIllness: formData['presentIllness'],
        provisionalDiagnosis: formData['provisionalDiagnosis'],
        finalDiagnosis: formData['finalDiagnosis'],
        ward: formData['ward'],
        bedNumber: formData['bedNumber'],
        insuranceRight: formData['insuranceRight'],
        dischargeType: formData['dischargeType'] != null 
            ? DischargeType.values.firstWhere((e) => e.toString().split('.').last == formData['dischargeType'])
            : null,
        createdAt: _admission?.createdAt ?? DateTime.now(),
      );

      if (_admission == null) {
        await admissionRepo.createAdmission(admission);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เพิ่มการรักษาสำเร็จ')),
          );
        }
      } else {
        await admissionRepo.updateAdmission(admission);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('แก้ไขการรักษาสำเร็จ')),
          );
        }
      }
      
      if (mounted) {
        context.pop();
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.admissionId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'แก้ไขการรักษา' : 'เพิ่มการรักษาใหม่'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveAdmission,
              child: _isSaving 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('บันทึก', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ข้อมูลพื้นฐาน',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Patient Selection
                            FormBuilderDropdown<int>(
                              name: 'patientId',
                              decoration: const InputDecoration(
                                labelText: 'ผู้ป่วย *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              initialValue: widget.patientId ?? _admission?.patientId,
                              items: _patients.map((patient) => DropdownMenuItem(
                                value: patient.patientId,
                                child: Text('${patient.hospitalNumber} - ${patient.firstName} ${patient.lastName}'),
                              )).toList(),
                              validator: FormBuilderValidators.required(
                                errorText: 'กรุณาเลือกผู้ป่วย',
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Admission Number
                            FormBuilderTextField(
                              name: 'admissionNumber',
                              decoration: const InputDecoration(
                                labelText: 'เลขที่ Admission (AN) *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.confirmation_number),
                              ),
                              initialValue: _admission?.admissionNumber,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(errorText: 'กรุณากรอกเลขที่ AN'),
                                FormBuilderValidators.minLength(3, errorText: 'เลขที่ AN ต้องมีอย่างน้อย 3 ตัวอักษร'),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            
                            // Admission DateTime
                            FormBuilderDateTimePicker(
                              name: 'admissionDateTime',
                              decoration: const InputDecoration(
                                labelText: 'วันเวลาที่รับเข้า *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              initialValue: _admission?.admissionDateTime ?? DateTime.now(),
                              inputType: InputType.both,
                              validator: FormBuilderValidators.required(
                                errorText: 'กรุณาเลือกวันเวลาที่รับเข้า',
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Admitting Doctor
                            FormBuilderDropdown<int>(
                              name: 'admittingDoctorId',
                              decoration: const InputDecoration(
                                labelText: 'แพทย์ผู้รับเข้า',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.local_hospital),
                              ),
                              initialValue: _admission?.admittingDoctorId,
                              items: _doctors.map((doctor) => DropdownMenuItem(
                                value: doctor.providerId,
                                child: Text('${doctor.firstName} ${doctor.lastName}'),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Clinical Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ข้อมูลทางคลินิก',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Chief Complaint
                            FormBuilderTextField(
                              name: 'chiefComplaint',
                              decoration: const InputDecoration(
                                labelText: 'อาการสำคัญ (Chief Complaint)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.medical_services),
                              ),
                              initialValue: _admission?.chiefComplaint,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            
                            // Present Illness
                            FormBuilderTextField(
                              name: 'presentIllness',
                              decoration: const InputDecoration(
                                labelText: 'ประวัติการเจ็บป่วยในปัจจุบัน',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.history),
                              ),
                              initialValue: _admission?.presentIllness,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            
                            // Provisional Diagnosis
                            FormBuilderTextField(
                              name: 'provisionalDiagnosis',
                              decoration: const InputDecoration(
                                labelText: 'การวินิจฉัยเบื้องต้น',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.assignment),
                              ),
                              initialValue: _admission?.provisionalDiagnosis,
                            ),
                            const SizedBox(height: 16),
                            
                            // Final Diagnosis
                            FormBuilderTextField(
                              name: 'finalDiagnosis',
                              decoration: const InputDecoration(
                                labelText: 'การวินิจฉัยสุดท้าย',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.assignment_turned_in),
                              ),
                              initialValue: _admission?.finalDiagnosis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Ward Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ข้อมูลหอผู้ป่วย',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: FormBuilderDropdown<String>(
                                    name: 'ward',
                                    decoration: const InputDecoration(
                                      labelText: 'หอผู้ป่วย',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.domain),
                                    ),
                                    initialValue: _admission?.ward,
                                    items: const [
                                      DropdownMenuItem(value: 'Medical Ward A', child: Text('Medical Ward A')),
                                      DropdownMenuItem(value: 'Medical Ward B', child: Text('Medical Ward B')),
                                      DropdownMenuItem(value: 'Surgical Ward A', child: Text('Surgical Ward A')),
                                      DropdownMenuItem(value: 'Surgical Ward B', child: Text('Surgical Ward B')),
                                      DropdownMenuItem(value: 'ICU', child: Text('ICU')),
                                      DropdownMenuItem(value: 'CCU', child: Text('CCU')),
                                      DropdownMenuItem(value: 'Pediatric Ward', child: Text('Pediatric Ward')),
                                      DropdownMenuItem(value: 'OB-GYN Ward', child: Text('OB-GYN Ward')),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'bedNumber',
                                    decoration: const InputDecoration(
                                      labelText: 'หมายเลขเตียง',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.bed),
                                    ),
                                    initialValue: _admission?.bedNumber,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Insurance Right
                            FormBuilderDropdown<String>(
                              name: 'insuranceRight',
                              decoration: const InputDecoration(
                                labelText: 'สิทธิการรักษา',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.card_membership),
                              ),
                              initialValue: _admission?.insuranceRight,
                              items: const [
                                DropdownMenuItem(value: 'หลักประกันสุขภาพถ้วนหน้า', child: Text('หลักประกันสุขภาพถ้วนหน้า')),
                                DropdownMenuItem(value: 'ประกันสังคม', child: Text('ประกันสังคม')),
                                DropdownMenuItem(value: 'ข้าราชการ', child: Text('ข้าราชการ')),
                                DropdownMenuItem(value: 'จ่ายเอง', child: Text('จ่ายเอง')),
                                DropdownMenuItem(value: 'ประกันเอกชน', child: Text('ประกันเอกชน')),
                                DropdownMenuItem(value: 'อื่นๆ', child: Text('อื่นๆ')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Discharge Information Card (for editing only)
                    if (isEdit) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ข้อมูลการจำหน่าย',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Discharge DateTime
                              FormBuilderDateTimePicker(
                                name: 'dischargeDateTime',
                                decoration: const InputDecoration(
                                  labelText: 'วันเวลาที่จำหน่าย',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.exit_to_app),
                                ),
                                initialValue: _admission?.dischargeDateTime,
                                inputType: InputType.both,
                              ),
                              const SizedBox(height: 16),
                              
                              // Discharge Type
                              FormBuilderDropdown<String>(
                                name: 'dischargeType',
                                decoration: const InputDecoration(
                                  labelText: 'ประเภทการจำหน่าย',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.output),
                                ),
                                initialValue: _admission?.dischargeType?.toString().split('.').last,
                                items: DischargeType.values.map((type) => DropdownMenuItem(
                                  value: type.toString().split('.').last,
                                  child: Text(_getDischargeTypeText(type)),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveAdmission,
                        icon: _isSaving 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึกข้อมูล'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  String _getDischargeTypeText(DischargeType type) {
    switch (type) {
      case DischargeType.improved:
        return 'หายเป็นปกติ';
      case DischargeType.againstAdvice:
        return 'จำหน่ายตามความประสงค์';
      case DischargeType.transfer:
        return 'ส่งต่อ';
      case DischargeType.deceased:
        return 'เสียชีวิต';
    }
  }
}
