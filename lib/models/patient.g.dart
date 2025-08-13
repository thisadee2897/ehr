// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
  patientId: (json['patientId'] as num?)?.toInt(),
  hospitalNumber: json['hospitalNumber'] as String,
  nationalId: json['nationalId'] as String?,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  address: json['address'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  religion: json['religion'] as String?,
  maritalStatus: $enumDecodeNullable(
    _$MaritalStatusEnumMap,
    json['maritalStatus'],
  ),
  nationality: json['nationality'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
  'patientId': instance.patientId,
  'hospitalNumber': instance.hospitalNumber,
  'nationalId': instance.nationalId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'dateOfBirth': instance.dateOfBirth.toIso8601String(),
  'gender': _$GenderEnumMap[instance.gender]!,
  'address': instance.address,
  'phoneNumber': instance.phoneNumber,
  'religion': instance.religion,
  'maritalStatus': _$MaritalStatusEnumMap[instance.maritalStatus],
  'nationality': instance.nationality,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

const _$MaritalStatusEnumMap = {
  MaritalStatus.single: 'single',
  MaritalStatus.married: 'married',
  MaritalStatus.divorced: 'divorced',
  MaritalStatus.widowed: 'widowed',
};
