import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdmissionFormScreen extends ConsumerWidget {
  final int? patientId;
  final int? admissionId;

  const AdmissionFormScreen({
    super.key,
    this.patientId,
    this.admissionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = admissionId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'แก้ไขการรักษา' : 'เพิ่มการรักษาใหม่'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_box,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'แก้ไขการรักษา' : 'เพิ่มการรักษาใหม่',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (patientId != null)
              Text(
                'Patient ID: $patientId',
                style: const TextStyle(color: Colors.grey),
              ),
            if (admissionId != null)
              Text(
                'Admission ID: $admissionId',
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 8),
            const Text(
              'ยังไม่ได้พัฒนา - กำลังจะพัฒนาต่อไป',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
