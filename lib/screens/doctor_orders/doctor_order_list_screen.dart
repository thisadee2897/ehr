import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/doctor_order.dart';
import '../../models/healthcare_provider.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class DoctorOrderListScreen extends ConsumerStatefulWidget {
  final int admissionId;

  const DoctorOrderListScreen({
    super.key,
    required this.admissionId,
  });

  @override
  ConsumerState<DoctorOrderListScreen> createState() => _DoctorOrderListScreenState();
}

class _DoctorOrderListScreenState extends ConsumerState<DoctorOrderListScreen> {
  List<DoctorOrder> _doctorOrders = [];
  Map<int, HealthcareProvider> _providers = {};
  bool _isLoading = true;
  OrderStatus? _statusFilter;
  OrderType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _loadDoctorOrders();
  }

  Future<void> _loadDoctorOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doctorOrderRepository = ref.read(doctorOrderRepositoryProvider);
      
      List<DoctorOrder> orders;
      if (_statusFilter != null) {
        orders = await doctorOrderRepository.getDoctorOrdersByStatus(widget.admissionId, _statusFilter!);
      } else if (_typeFilter != null) {
        orders = await doctorOrderRepository.getDoctorOrdersByType(widget.admissionId, _typeFilter!);
      } else {
        orders = await doctorOrderRepository.getDoctorOrdersByAdmissionId(widget.admissionId);
      }

      // Load provider information
      // final Set<int> providerIds = orders.map((order) => order.orderingProviderId).toSet();
      final Map<int, HealthcareProvider> providers = {};
      
      // TODO: Load providers data
      // for (final providerId in providerIds) {
      //   providers[providerId] = await getProviderById(providerId);
      // }

      setState(() {
        _doctorOrders = orders;
        _providers = providers;
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
        title: const Text('คำสั่งการรักษา'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'filter_status') {
                _showStatusFilter();
              } else if (value == 'filter_type') {
                _showTypeFilter();
              } else if (value == 'clear_filter') {
                _clearFilters();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter_status',
                child: Text('กรองตาม Status'),
              ),
              const PopupMenuItem(
                value: 'filter_type',
                child: Text('กรองตามประเภท'),
              ),
              const PopupMenuItem(
                value: 'clear_filter',
                child: Text('ล้างตัวกรอง'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOrdersList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_doctorOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('ไม่มีคำสั่งการรักษา'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDoctorOrders,
      child: ListView.builder(
        itemCount: _doctorOrders.length,
        itemBuilder: (context, index) {
          final order = _doctorOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(DoctorOrder order) {
    final provider = _providers[order.orderingProviderId];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToDetail(order.orderId!),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildOrderTypeChip(order.orderType),
                  const Spacer(),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.orderText,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(order.orderDateTime),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (order.isContinuous) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Continuous',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (provider != null) ...[
                const SizedBox(height: 4),
                Text(
                  'สั่งโดย: ${provider.firstName} ${provider.lastName}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeChip(OrderType orderType) {
    Color color;
    String label;
    
    switch (orderType) {
      case OrderType.medication:
        color = Colors.green;
        label = 'ยา';
        break;
      case OrderType.lab:
        color = Colors.blue;
        label = 'Lab';
        break;
      case OrderType.imaging:
        color = Colors.purple;
        label = 'X-ray';
        break;
      case OrderType.diet:
        color = Colors.orange;
        label = 'อาหาร';
        break;
      case OrderType.activity:
        color = Colors.teal;
        label = 'กิจกรรม';
        break;
      case OrderType.nursing:
        color = Colors.pink;
        label = 'พยาบาล';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case OrderStatus.active:
        color = Colors.green;
        label = 'ใช้งาน';
        break;
      case OrderStatus.completed:
        color = Colors.blue;
        label = 'เสร็จแล้ว';
        break;
      case OrderStatus.discontinued:
        color = Colors.red;
        label = 'หยุด';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showStatusFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือก Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values.map((status) {
            return RadioListTile<OrderStatus>(
              title: Text(_getStatusLabel(status)),
              value: status,
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() {
                  _statusFilter = value;
                  _typeFilter = null;
                });
                Navigator.pop(context);
                _loadDoctorOrders();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTypeFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกประเภท'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderType.values.map((type) {
            return RadioListTile<OrderType>(
              title: Text(_getTypeLabel(type)),
              value: type,
              groupValue: _typeFilter,
              onChanged: (value) {
                setState(() {
                  _typeFilter = value;
                  _statusFilter = null;
                });
                Navigator.pop(context);
                _loadDoctorOrders();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _typeFilter = null;
    });
    _loadDoctorOrders();
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

  void _navigateToForm({int? orderId}) {
    Navigator.pushNamed(
      context,
      '/doctor-orders/form',
      arguments: {
        'admissionId': widget.admissionId,
        'orderId': orderId,
      },
    ).then((result) {
      if (result == true) {
        _loadDoctorOrders();
      }
    });
  }

  void _navigateToDetail(int orderId) {
    Navigator.pushNamed(
      context,
      '/doctor-orders/detail',
      arguments: {
        'orderId': orderId,
      },
    ).then((result) {
      if (result == true) {
        _loadDoctorOrders();
      }
    });
  }
}
