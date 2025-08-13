import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdmissionListScreen extends ConsumerWidget {
  const AdmissionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการการรักษา'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'หน้ารายการการรักษา',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'ยังไม่ได้พัฒนา - กำลังจะพัฒนาต่อไป',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ฟีเจอร์นี้กำลังจะพัฒนาต่อไป')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
