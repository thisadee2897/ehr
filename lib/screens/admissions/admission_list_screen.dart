import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/admission.dart';
import '../../models/patient.dart';
import '../../providers/providers.dart';

class AdmissionListScreen extends ConsumerStatefulWidget {
  const AdmissionListScreen({super.key});

  @override
  ConsumerState<AdmissionListScreen> createState() => _AdmissionListScreenState();
}

class _AdmissionListScreenState extends ConsumerState<AdmissionListScreen> {
  List<Admission> admissions = [];
  List<Patient> patients = [];
  Map<int, Patient> patientMap = {};
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final admissionRepo = ref.read(admissionRepositoryProvider);
      final patientRepo = ref.read(patientRepositoryProvider);
      
      // Load patients first to create mapping
      patients = await patientRepo.getAllPatients();
      patientMap = {for (var patient in patients) patient.patientId!: patient};
      
      // Load admissions
      admissions = await admissionRepo.getAllAdmissions();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<Admission> get filteredAdmissions {
    if (searchQuery.isEmpty) return admissions;
    
    return admissions.where((admission) {
      final patient = patientMap[admission.patientId];
      final admissionNumber = admission.admissionNumber.toLowerCase();
      final patientName = patient != null ? '${patient.firstName} ${patient.lastName}'.toLowerCase() : '';
      final chiefComplaint = admission.chiefComplaint?.toLowerCase() ?? '';
      
      final query = searchQuery.toLowerCase();
      return admissionNumber.contains(query) ||
             patientName.contains(query) ||
             chiefComplaint.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการการรักษา'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'ค้นหา AN, ชื่อผู้ป่วย, อาการสำคัญ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          
          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAdmissions.isEmpty
                    ? _buildEmptyState()
                    : _buildAdmissionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/admissions/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isNotEmpty ? Icons.search_off : Icons.local_hospital,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty ? 'ไม่พบข้อมูลที่ค้นหา' : 'ยังไม่มีข้อมูลการรักษา',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty 
                ? 'ลองค้นหาด้วยคำค้นอื่น'
                : 'เริ่มต้นด้วยการเพิ่มข้อมูลการรักษาใหม่',
            style: const TextStyle(color: Colors.grey),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/admissions/new'),
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มการรักษาใหม่'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdmissionList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: filteredAdmissions.length,
        itemBuilder: (context, index) {
          final admission = filteredAdmissions[index];
          final patient = patientMap[admission.patientId];
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(admission),
                child: Text(
                  admission.admissionNumber.substring(admission.admissionNumber.length - 2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                patient != null 
                    ? '${patient.firstName} ${patient.lastName}'
                    : 'ไม่พบข้อมูลผู้ป่วย',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AN: ${admission.admissionNumber}'),
                  if (admission.chiefComplaint?.isNotEmpty == true)
                    Text(
                      'อาการสำคัญ: ${admission.chiefComplaint}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    'วันที่รับเข้า: ${_formatDate(admission.admissionDateTime)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    admission.dischargeDateTime != null 
                        ? Icons.check_circle 
                        : Icons.schedule,
                    color: admission.dischargeDateTime != null 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  Text(
                    admission.dischargeDateTime != null ? 'จำหน่าย' : 'รักษาอยู่',
                    style: TextStyle(
                      fontSize: 10,
                      color: admission.dischargeDateTime != null 
                          ? Colors.green 
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              onTap: () {
                context.go('/admissions/${admission.admissionId}');
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(Admission admission) {
    if (admission.dischargeDateTime != null) {
      return Colors.green;
    }
    return Colors.blue;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'ไม่ระบุ';
    return '${date.day}/${date.month}/${date.year}';
  }
}
