// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Admission _$AdmissionFromJson(Map<String, dynamic> json) => Admission(
  admissionId: (json['admissionId'] as num?)?.toInt(),
  admissionNumber: json['admissionNumber'] as String,
  patientId: (json['patientId'] as num).toInt(),
  admissionDateTime: DateTime.parse(json['admissionDateTime'] as String),
  dischargeDateTime:
      json['dischargeDateTime'] == null
          ? null
          : DateTime.parse(json['dischargeDateTime'] as String),
  admittingDoctorId: (json['admittingDoctorId'] as num?)?.toInt(),
  chiefComplaint: json['chiefComplaint'] as String?,
  presentIllness: json['presentIllness'] as String?,
  provisionalDiagnosis: json['provisionalDiagnosis'] as String?,
  finalDiagnosis: json['finalDiagnosis'] as String?,
  ward: json['ward'] as String?,
  bedNumber: json['bedNumber'] as String?,
  insuranceRight: json['insuranceRight'] as String?,
  dischargeType: $enumDecodeNullable(
    _$DischargeTypeEnumMap,
    json['dischargeType'],
  ),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AdmissionToJson(Admission instance) => <String, dynamic>{
  'admissionId': instance.admissionId,
  'admissionNumber': instance.admissionNumber,
  'patientId': instance.patientId,
  'admissionDateTime': instance.admissionDateTime.toIso8601String(),
  'dischargeDateTime': instance.dischargeDateTime?.toIso8601String(),
  'admittingDoctorId': instance.admittingDoctorId,
  'chiefComplaint': instance.chiefComplaint,
  'presentIllness': instance.presentIllness,
  'provisionalDiagnosis': instance.provisionalDiagnosis,
  'finalDiagnosis': instance.finalDiagnosis,
  'ward': instance.ward,
  'bedNumber': instance.bedNumber,
  'insuranceRight': instance.insuranceRight,
  'dischargeType': _$DischargeTypeEnumMap[instance.dischargeType],
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$DischargeTypeEnumMap = {
  DischargeType.improved: 'improved',
  DischargeType.againstAdvice: 'againstAdvice',
  DischargeType.transfer: 'transfer',
  DischargeType.deceased: 'deceased',
};
