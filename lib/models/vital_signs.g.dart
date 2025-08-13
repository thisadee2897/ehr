// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital_signs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VitalSigns _$VitalSignsFromJson(Map<String, dynamic> json) => VitalSigns(
  vitalSignId: (json['vitalSignId'] as num?)?.toInt(),
  admissionId: (json['admissionId'] as num).toInt(),
  recordedAt: DateTime.parse(json['recordedAt'] as String),
  bodyTemperature: (json['bodyTemperature'] as num?)?.toDouble(),
  pulseRate: (json['pulseRate'] as num?)?.toInt(),
  respiratoryRate: (json['respiratoryRate'] as num?)?.toInt(),
  bpSystolic: (json['bpSystolic'] as num?)?.toInt(),
  bpDiastolic: (json['bpDiastolic'] as num?)?.toInt(),
  oxygenSaturation: (json['oxygenSaturation'] as num?)?.toInt(),
  painScore: (json['painScore'] as num?)?.toInt(),
  recordedByProviderId: (json['recordedByProviderId'] as num?)?.toInt(),
);

Map<String, dynamic> _$VitalSignsToJson(VitalSigns instance) =>
    <String, dynamic>{
      'vitalSignId': instance.vitalSignId,
      'admissionId': instance.admissionId,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'bodyTemperature': instance.bodyTemperature,
      'pulseRate': instance.pulseRate,
      'respiratoryRate': instance.respiratoryRate,
      'bpSystolic': instance.bpSystolic,
      'bpDiastolic': instance.bpDiastolic,
      'oxygenSaturation': instance.oxygenSaturation,
      'painScore': instance.painScore,
      'recordedByProviderId': instance.recordedByProviderId,
    };
