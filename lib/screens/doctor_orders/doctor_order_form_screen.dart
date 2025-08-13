import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../models/doctor_order.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class DoctorOrderFormScreen extends ConsumerStatefulWidget {
  final int admissionId;
  final int? orderId;

  const DoctorOrderFormScreen({
    super.key,
    required this.admissionId,
    this.orderId,
  });

  @override
  ConsumerState<DoctorOrderFormScreen> createState() => _DoctorOrderFormScreenState();
}

class _DoctorOrderFormScreenState extends ConsumerState<DoctorOrderFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  DoctorOrder? _editingOrder;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.orderId != null;
    if (_isEdit) {
      _loadOrderData();
    }
  }

  Future<void> _loadOrderData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(doctorOrderRepositoryProvider);
      final order = await repository.getDoctorOrderById(widget.orderId!);
      
      setState(() {
        _editingOrder = order;
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
        title: Text(_isEdit ? 'แก้ไขคำสั่งการรักษา' : 'เพิ่มคำสั่งการรักษา'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveOrder,
          child: Text(_isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มคำสั่ง'),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FormBuilder(
        key: _formKey,
        initialValue: _getInitialValues(),
        child: Column(
          children: [
            // Order Type
            FormBuilderDropdown<OrderType>(
              name: 'orderType',
              decoration: const InputDecoration(
                labelText: 'ประเภทคำสั่ง *',
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.required(
                errorText: 'กรุณาเลือกประเภทคำสั่ง',
              ),
              items: OrderType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeLabel(type)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Order Text
            FormBuilderTextField(
              name: 'orderText',
              decoration: const InputDecoration(
                labelText: 'รายละเอียดคำสั่ง *',
                border: OutlineInputBorder(),
                hintText: 'เช่น Paracetamol 500mg tab 1 pc oral q6h prn for pain',
              ),
              validator: FormBuilderValidators.required(
                errorText: 'กรุณากรอกรายละเอียดคำสั่ง',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Order DateTime
            FormBuilderDateTimePicker(
              name: 'orderDateTime',
              decoration: const InputDecoration(
                labelText: 'วันที่และเวลาที่สั่ง *',
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.required(
                errorText: 'กรุณาเลือกวันที่และเวลา',
              ),
              format: DateFormat('dd/MM/yyyy HH:mm'),
            ),
            const SizedBox(height: 16),

            // Is Continuous
            FormBuilderCheckbox(
              name: 'isContinuous',
              title: const Text('คำสั่งต่อเนื่อง (Continuous Order)'),
              subtitle: const Text('เช่น ยาประจำ, การดูแลพื้นฐาน'),
            ),
            const SizedBox(height: 16),

            // Status (for edit mode)
            if (_isEdit) ...[
              FormBuilderDropdown<OrderStatus>(
                name: 'status',
                decoration: const InputDecoration(
                  labelText: 'สถานะ',
                  border: OutlineInputBorder(),
                ),
                items: OrderStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusLabel(status)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Order Examples Card
            _buildOrderExamplesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderExamplesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ตัวอย่างคำสั่งการรักษา',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              '• ยา: Paracetamol 500mg tab 1 pc oral q6h prn for pain\n'
              '• Lab: CBC, Electrolyte, BUN/Cr tomorrow morning\n'
              '• X-ray: Chest X-ray PA view stat\n'
              '• อาหาร: Soft diet, No added salt\n'
              '• กิจกรรม: Bed rest with bathroom privilege\n'
              '• พยาบาล: Check vital signs q4h',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getInitialValues() {
    if (_editingOrder == null) {
      return {
        'orderDateTime': DateTime.now(),
        'isContinuous': false,
        'status': OrderStatus.active,
      };
    }

    return {
      'orderType': _editingOrder!.orderType,
      'orderText': _editingOrder!.orderText,
      'orderDateTime': _editingOrder!.orderDateTime,
      'isContinuous': _editingOrder!.isContinuous,
      'status': _editingOrder!.status,
    };
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = _formKey.currentState!.value;
      final repository = ref.read(doctorOrderRepositoryProvider);

      final order = DoctorOrder(
        orderId: _editingOrder?.orderId,
        admissionId: widget.admissionId,
        orderDateTime: formData['orderDateTime'] as DateTime,
        orderingProviderId: 1, // TODO: Get from current user
        orderType: formData['orderType'] as OrderType,
        orderText: formData['orderText'] as String,
        isContinuous: formData['isContinuous'] as bool? ?? false,
        status: formData['status'] as OrderStatus? ?? OrderStatus.active,
      );

      if (_isEdit) {
        await repository.updateDoctorOrder(order);
      } else {
        await repository.createDoctorOrder(order);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'แก้ไขคำสั่งเรียบร้อยแล้ว' : 'เพิ่มคำสั่งเรียบร้อยแล้ว'),
          ),
        );
        Navigator.pop(context, true);
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

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบคำสั่งการรักษานี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteOrder();
    }
  }

  Future<void> _deleteOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(doctorOrderRepositoryProvider);
      await repository.deleteDoctorOrder(widget.orderId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบคำสั่งเรียบร้อยแล้ว')),
        );
        Navigator.pop(context, true);
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

  String _getTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.medication:
        return 'ยา';
      case OrderType.lab:
        return 'Lab';
      case OrderType.imaging:
        return 'X-ray';
      case OrderType.diet:
        return 'อาหาร';
      case OrderType.activity:
        return 'กิจกรรม';
      case OrderType.nursing:
        return 'พยาบาล';
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return 'ใช้งาน';
      case OrderStatus.completed:
        return 'เสร็จแล้ว';
      case OrderStatus.discontinued:
        return 'หยุด';
    }
  }
}
