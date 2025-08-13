import 'package:json_annotation/json_annotation.dart';

part 'doctor_order.g.dart';

enum OrderType {
  medication,
  lab,
  imaging, 
  diet,
  activity,
  nursing,
}

enum OrderStatus {
  active,
  completed,
  discontinued,
}

@JsonSerializable()
class DoctorOrder {
  @JsonKey(name: 'order_id')
  final int? orderId;
  
  @JsonKey(name: 'admission_id')
  final int admissionId;
  
  @JsonKey(name: 'order_date_time')
  final DateTime orderDateTime;
  
  @JsonKey(name: 'ordering_provider_id')
  final int orderingProviderId;
  
  @JsonKey(name: 'order_type')
  final OrderType orderType;
  
  @JsonKey(name: 'order_text')
  final String orderText;
  
  @JsonKey(name: 'is_continuous')
  final bool isContinuous;
  
  final OrderStatus status;

  const DoctorOrder({
    this.orderId,
    required this.admissionId,
    required this.orderDateTime,
    required this.orderingProviderId,
    required this.orderType,
    required this.orderText,
    this.isContinuous = false,
    this.status = OrderStatus.active,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'admission_id': admissionId,
      'order_date_time': orderDateTime.toIso8601String(),
      'ordering_provider_id': orderingProviderId,
      'order_type': orderType.name,
      'order_text': orderText,
      'is_continuous': isContinuous ? 1 : 0,
      'status': status.name,
    };
  }

  // Create DoctorOrder from Map (SQLite result)
  factory DoctorOrder.fromMap(Map<String, dynamic> map) {
    return DoctorOrder(
      orderId: map['order_id'] as int?,
      admissionId: map['admission_id'] as int,
      orderDateTime: DateTime.parse(map['order_date_time'] as String),
      orderingProviderId: map['ordering_provider_id'] as int,
      orderType: OrderType.values.firstWhere(
        (e) => e.name == map['order_type'],
        orElse: () => OrderType.medication,
      ),
      orderText: map['order_text'] as String,
      isContinuous: (map['is_continuous'] as int) == 1,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.active,
      ),
    );
  }

  // JSON serialization
  factory DoctorOrder.fromJson(Map<String, dynamic> json) => _$DoctorOrderFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorOrderToJson(this);

  // CopyWith method
  DoctorOrder copyWith({
    int? orderId,
    int? admissionId,
    DateTime? orderDateTime,
    int? orderingProviderId,
    OrderType? orderType,
    String? orderText,
    bool? isContinuous,
    OrderStatus? status,
  }) {
    return DoctorOrder(
      orderId: orderId ?? this.orderId,
      admissionId: admissionId ?? this.admissionId,
      orderDateTime: orderDateTime ?? this.orderDateTime,
      orderingProviderId: orderingProviderId ?? this.orderingProviderId,
      orderType: orderType ?? this.orderType,
      orderText: orderText ?? this.orderText,
      isContinuous: isContinuous ?? this.isContinuous,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'DoctorOrder(orderId: $orderId, admissionId: $admissionId, orderDateTime: $orderDateTime, orderingProviderId: $orderingProviderId, orderType: $orderType, orderText: $orderText, isContinuous: $isContinuous, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorOrder &&
        other.orderId == orderId &&
        other.admissionId == admissionId &&
        other.orderDateTime == orderDateTime &&
        other.orderingProviderId == orderingProviderId &&
        other.orderType == orderType &&
        other.orderText == orderText &&
        other.isContinuous == isContinuous &&
        other.status == status;
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
        admissionId.hashCode ^
        orderDateTime.hashCode ^
        orderingProviderId.hashCode ^
        orderType.hashCode ^
        orderText.hashCode ^
        isContinuous.hashCode ^
        status.hashCode;
  }
}
