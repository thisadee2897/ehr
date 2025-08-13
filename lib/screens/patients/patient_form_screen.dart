import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../models/patient.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';

class PatientFormScreen extends ConsumerStatefulWidget {
  final int? patientId; // null สำหรับสร้างใหม่

  const PatientFormScreen({
    super.key,
    this.patientId,
  });

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Patient? _editingPatient;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.patientId != null;
    if (_isEdit) {
      _loadPatientData();
    }
  }

  Future<void> _loadPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(patientRepositoryProvider);
      final patient = await repository.getPatientById(widget.patientId!);
      
      setState(() {
        _editingPatient = patient;
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
        context.goBack();
      }
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = _formKey.currentState!.value;
      final repository = ref.read(patientRepositoryProvider);

      // ตรวจสอบ HN ซ้ำ
      final hnExists = await repository.isHNExists(
        formData['hospitalNumber'] as String,
        excludePatientId: widget.patientId,
      );
      if (hnExists) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('หมายเลข HN นี้มีอยู่ในระบบแล้ว');
        return;
      }

      // ตรวจสอบเลขประจำตัวประชาชนซ้ำ (ถ้ามี)
      final nationalId = formData['nationalId'] as String?;
      if (nationalId != null && nationalId.isNotEmpty) {
        final nationalIdExists = await repository.isNationalIdExists(
          nationalId,
          excludePatientId: widget.patientId,
        );
        if (nationalIdExists) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('เลขประจำตัวประชาชนนี้มีอยู่ในระบบแล้ว');
          return;
        }
      }

      // สร้าง Patient object
      final patient = Patient(
        patientId: widget.patientId,
        hospitalNumber: formData['hospitalNumber'] as String,
        nationalId: nationalId?.isNotEmpty == true ? nationalId : null,
        firstName: formData['firstName'] as String,
        lastName: formData['lastName'] as String,
        dateOfBirth: formData['dateOfBirth'] as DateTime,
        gender: formData['gender'] as Gender,
        address: (formData['address'] as String?)?.isNotEmpty == true 
            ? formData['address'] as String? : null,
        phoneNumber: (formData['phoneNumber'] as String?)?.isNotEmpty == true 
            ? formData['phoneNumber'] as String? : null,
        religion: (formData['religion'] as String?)?.isNotEmpty == true 
            ? formData['religion'] as String? : null,
        maritalStatus: formData['maritalStatus'] as MaritalStatus?,
        nationality: (formData['nationality'] as String?)?.isNotEmpty == true 
            ? formData['nationality'] as String? : null,
      );

      if (_isEdit) {
        await repository.updatePatient(patient);
      } else {
        await repository.createPatient(patient);
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'แก้ไขข้อมูลผู้ป่วยเรียบร้อยแล้ว' : 'เพิ่มผู้ป่วยใหม่เรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
        context.goBack();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showErrorDialog('เกิดข้อผิดพลาด: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ข้อผิดพลาด'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Future<String> _generateHN() async {
    try {
      final repository = ref.read(patientRepositoryProvider);
      return await repository.generateNextHN();
    } catch (e) {
      return '0000001';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEdit && _isLoading && _editingPatient == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('กำลังโหลด...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'แก้ไขข้อมูลผู้ป่วย' : 'เพิ่มผู้ป่วยใหม่'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePatient,
            child: Text(
              _isEdit ? 'บันทึก' : 'เพิ่ม',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: FormBuilder(
        key: _formKey,
        initialValue: _editingPatient != null
            ? {
                'hospitalNumber': _editingPatient!.hospitalNumber,
                'nationalId': _editingPatient!.nationalId,
                'firstName': _editingPatient!.firstName,
                'lastName': _editingPatient!.lastName,
                'dateOfBirth': _editingPatient!.dateOfBirth,
                'gender': _editingPatient!.gender,
                'address': _editingPatient!.address,
                'phoneNumber': _editingPatient!.phoneNumber,
                'religion': _editingPatient!.religion,
                'maritalStatus': _editingPatient!.maritalStatus,
                'nationality': _editingPatient!.nationality,
              }
            : {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HN Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'hospitalNumber',
                          decoration: const InputDecoration(
                            labelText: 'หมายเลข HN *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'กรุณาระบุหมายเลข HN'),
                          ]),
                        ),
                      ),
                      if (!_isEdit) ...[
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final hn = await _generateHN();
                            _formKey.currentState?.fields['hospitalNumber']?.didChange(hn);
                          },
                          child: const Text('สร้างอัตโนมัติ'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Personal Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ข้อมูลส่วนตัว',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // National ID
                      FormBuilderTextField(
                        name: 'nationalId',
                        decoration: const InputDecoration(
                          labelText: 'เลขประจำตัวประชาชน',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        validator: FormBuilderValidators.compose([
                          (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^\d{13}$').hasMatch(value)) {
                                return 'กรุณาระบุเลขประจำตัวประชาชน 13 หลัก';
                              }
                            }
                            return null;
                          },
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // First Name
                      FormBuilderTextField(
                        name: 'firstName',
                        decoration: const InputDecoration(
                          labelText: 'ชื่อ *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'กรุณาระบุชื่อ'),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // Last Name
                      FormBuilderTextField(
                        name: 'lastName',
                        decoration: const InputDecoration(
                          labelText: 'นามสกุล *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'กรุณาระบุนามสกุล'),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth
                      FormBuilderDateTimePicker(
                        name: 'dateOfBirth',
                        inputType: InputType.date,
                        decoration: const InputDecoration(
                          labelText: 'วันเกิด *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.cake),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'กรุณาเลือกวันเกิด'),
                        ]),
                        lastDate: DateTime.now(),
                        firstDate: DateTime(1900),
                      ),
                      const SizedBox(height: 16),

                      // Gender
                      FormBuilderDropdown<Gender>(
                        name: 'gender',
                        decoration: const InputDecoration(
                          labelText: 'เพศ *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'กรุณาเลือกเพศ'),
                        ]),
                        items: Gender.values.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(_getGenderText(gender)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contact Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ข้อมูลติดต่อ',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      FormBuilderTextField(
                        name: 'phoneNumber',
                        decoration: const InputDecoration(
                          labelText: 'เบอร์โทรศัพท์',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      FormBuilderTextField(
                        name: 'address',
                        decoration: const InputDecoration(
                          labelText: 'ที่อยู่',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ข้อมูลเพิ่มเติม',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Religion
                      FormBuilderTextField(
                        name: 'religion',
                        decoration: const InputDecoration(
                          labelText: 'ศาสนา',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.church),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Marital Status
                      FormBuilderDropdown<MaritalStatus>(
                        name: 'maritalStatus',
                        decoration: const InputDecoration(
                          labelText: 'สถานภาพสมรส',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        items: MaritalStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getMaritalStatusText(status)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Nationality
                      FormBuilderTextField(
                        name: 'nationality',
                        decoration: const InputDecoration(
                          labelText: 'สัญชาติ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มผู้ป่วยใหม่',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
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

  String _getMaritalStatusText(MaritalStatus status) {
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
