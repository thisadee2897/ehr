// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorOrder _$DoctorOrderFromJson(Map<String, dynamic> json) => DoctorOrder(
  orderId: (json['order_id'] as num?)?.toInt(),
  admissionId: (json['admission_id'] as num).toInt(),
  orderDateTime: DateTime.parse(json['order_date_time'] as String),
  orderingProviderId: (json['ordering_provider_id'] as num).toInt(),
  orderType: $enumDecode(_$OrderTypeEnumMap, json['order_type']),
  orderText: json['order_text'] as String,
  isContinuous: json['is_continuous'] as bool? ?? false,
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.active,
);

Map<String, dynamic> _$DoctorOrderToJson(DoctorOrder instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'admission_id': instance.admissionId,
      'order_date_time': instance.orderDateTime.toIso8601String(),
      'ordering_provider_id': instance.orderingProviderId,
      'order_type': _$OrderTypeEnumMap[instance.orderType]!,
      'order_text': instance.orderText,
      'is_continuous': instance.isContinuous,
      'status': _$OrderStatusEnumMap[instance.status]!,
    };

const _$OrderTypeEnumMap = {
  OrderType.medication: 'medication',
  OrderType.lab: 'lab',
  OrderType.imaging: 'imaging',
  OrderType.diet: 'diet',
  OrderType.activity: 'activity',
  OrderType.nursing: 'nursing',
};

const _$OrderStatusEnumMap = {
  OrderStatus.active: 'active',
  OrderStatus.completed: 'completed',
  OrderStatus.discontinued: 'discontinued',
};
