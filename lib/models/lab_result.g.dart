// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabResult _$LabResultFromJson(Map<String, dynamic> json) => LabResult(
  resultId: (json['result_id'] as num?)?.toInt(),
  admissionId: (json['admission_id'] as num).toInt(),
  testName: json['test_name'] as String,
  specimenDateTime:
      json['specimen_date_time'] == null
          ? null
          : DateTime.parse(json['specimen_date_time'] as String),
  resultDateTime:
      json['result_date_time'] == null
          ? null
          : DateTime.parse(json['result_date_time'] as String),
  resultDetails: json['result_details'] as Map<String, dynamic>,
  note: json['note'] as String?,
);

Map<String, dynamic> _$LabResultToJson(LabResult instance) => <String, dynamic>{
  'result_id': instance.resultId,
  'admission_id': instance.admissionId,
  'test_name': instance.testName,
  'specimen_date_time': instance.specimenDateTime?.toIso8601String(),
  'result_date_time': instance.resultDateTime?.toIso8601String(),
  'result_details': instance.resultDetails,
  'note': instance.note,
};
