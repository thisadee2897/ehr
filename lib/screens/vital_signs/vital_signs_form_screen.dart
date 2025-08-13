import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VitalSignsFormScreen extends ConsumerWidget {
  final int admissionId;
  final int? vitalSignId;

  const VitalSignsFormScreen({
    super.key,
    required this.admissionId,
    this.vitalSignId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = vitalSignId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'แก้ไขสัญญาณชีพ' : 'บันทึกสัญญาณชีพ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.monitor_heart,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'แก้ไขสัญญาณชีพ' : 'บันทึกสัญญาณชีพ',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Admission ID: $admissionId',
              style: const TextStyle(color: Colors.grey),
            ),
            if (vitalSignId != null)
              Text(
                'Vital Sign ID: $vitalSignId',
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
