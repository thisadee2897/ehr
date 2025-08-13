import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/lab_result.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class LabResultListScreen extends ConsumerStatefulWidget {
  final int admissionId;

  const LabResultListScreen({
    super.key,
    required this.admissionId,
  });

  @override
  ConsumerState<LabResultListScreen> createState() => _LabResultListScreenState();
}

class _LabResultListScreenState extends ConsumerState<LabResultListScreen> {
  List<LabResult> _labResults = [];
  List<String> _testNames = [];
  bool _isLoading = true;
  String? _selectedTestName;
  bool _showPendingOnly = false;

  @override
  void initState() {
    super.initState();
    _loadLabResults();
    _loadTestNames();
  }

  Future<void> _loadLabResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(labResultRepositoryProvider);
      
      List<LabResult> results;
      if (_showPendingOnly) {
        results = await repository.getPendingLabResults(widget.admissionId);
      } else if (_selectedTestName != null) {
        results = await repository.getLabResultsByTestName(widget.admissionId, _selectedTestName!);
      } else {
        results = await repository.getLabResultsByAdmissionId(widget.admissionId);
      }

      setState(() {
        _labResults = results;
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

  Future<void> _loadTestNames() async {
    try {
      final repository = ref.read(labResultRepositoryProvider);
      final testNames = await repository.getUniqueTestNames(widget.admissionId);
      
      setState(() {
        _testNames = testNames;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ผลการตรวจ Lab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'latest') {
                _showLatestResults();
              } else if (value == 'pending') {
                _togglePendingFilter();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'latest',
                child: Text('ผลล่าสุดของแต่ละการตรวจ'),
              ),
              PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(_showPendingOnly ? Icons.check_box : Icons.check_box_outline_blank),
                    const SizedBox(width: 8),
                    const Text('แสดงเฉพาะที่รอผล'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildResultsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    if (_testNames.isEmpty && _selectedTestName == null && !_showPendingOnly) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedTestName != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_selectedTestName!),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    _selectedTestName = null;
                  });
                  _loadLabResults();
                },
              ),
            ),
          if (_showPendingOnly)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('รอผล'),
                backgroundColor: Colors.orange[100],
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    _showPendingOnly = false;
                  });
                  _loadLabResults();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_labResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('ไม่มีผลการตรวจ Lab'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLabResults,
      child: ListView.builder(
        itemCount: _labResults.length,
        itemBuilder: (context, index) {
          final result = _labResults[index];
          return _buildResultCard(result);
        },
      ),
    );
  }

  Widget _buildResultCard(LabResult result) {
    final isCompleted = result.resultDateTime != null;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToDetail(result.resultId!),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      result.testName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(isCompleted),
                ],
              ),
              const SizedBox(height: 8),
              
              // Dates
              if (result.specimenDateTime != null) ...[
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'เก็บสิ่งส่งตรวจ: ${DateFormat('dd/MM/yyyy HH:mm').format(result.specimenDateTime!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              
              if (result.resultDateTime != null) ...[
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'รายงานผล: ${DateFormat('dd/MM/yyyy HH:mm').format(result.resultDateTime!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Results preview
              if (result.resultDetails.isNotEmpty) ...[
                _buildResultsPreview(result.resultDetails),
                const SizedBox(height: 8),
              ],

              // Note
              if (result.note != null && result.note!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.yellow[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.yellow[800]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          result.note!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.yellow[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[100] : Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isCompleted ? 'มีผลแล้ว' : 'รอผล',
        style: TextStyle(
          color: isCompleted ? Colors.green[800] : Colors.orange[800],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultsPreview(Map<String, dynamic> results) {
    final keys = results.keys.take(3).toList(); // Show first 3 results
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...keys.map((key) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  key,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Text(': '),
              Text(
                results[key].toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        )).toList(),
        if (results.length > 3) ...[
          Text(
            'และอีก ${results.length - 3} รายการ...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('กรองตามการตรวจ'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              ListTile(
                title: const Text('ทั้งหมด'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _selectedTestName,
                  onChanged: (value) {
                    setState(() {
                      _selectedTestName = value;
                    });
                    Navigator.pop(context);
                    _loadLabResults();
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _testNames.length,
                  itemBuilder: (context, index) {
                    final testName = _testNames[index];
                    return ListTile(
                      title: Text(testName),
                      leading: Radio<String>(
                        value: testName,
                        groupValue: _selectedTestName,
                        onChanged: (value) {
                          setState(() {
                            _selectedTestName = value;
                          });
                          Navigator.pop(context);
                          _loadLabResults();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLatestResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(labResultRepositoryProvider);
      final results = await repository.getLatestLabResults(widget.admissionId);
      
      setState(() {
        _labResults = results;
        _selectedTestName = null;
        _showPendingOnly = false;
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

  void _togglePendingFilter() {
    setState(() {
      _showPendingOnly = !_showPendingOnly;
      _selectedTestName = null;
    });
    _loadLabResults();
  }

  void _navigateToForm({int? resultId}) {
    Navigator.pushNamed(
      context,
      '/lab-results/form',
      arguments: {
        'admissionId': widget.admissionId,
        'resultId': resultId,
      },
    ).then((result) {
      if (result == true) {
        _loadLabResults();
        _loadTestNames();
      }
    });
  }

  void _navigateToDetail(int resultId) {
    Navigator.pushNamed(
      context,
      '/lab-results/detail',
      arguments: {
        'resultId': resultId,
      },
    ).then((result) {
      if (result == true) {
        _loadLabResults();
        _loadTestNames();
      }
    });
  }
}
