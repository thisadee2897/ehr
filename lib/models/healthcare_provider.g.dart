// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'healthcare_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthcareProvider _$HealthcareProviderFromJson(Map<String, dynamic> json) =>
    HealthcareProvider(
      providerId: (json['providerId'] as num?)?.toInt(),
      licenseNumber: json['licenseNumber'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      providerType: $enumDecode(_$ProviderTypeEnumMap, json['providerType']),
      specialty: json['specialty'] as String?,
    );

Map<String, dynamic> _$HealthcareProviderToJson(HealthcareProvider instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'licenseNumber': instance.licenseNumber,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'providerType': _$ProviderTypeEnumMap[instance.providerType]!,
      'specialty': instance.specialty,
    };

const _$ProviderTypeEnumMap = {
  ProviderType.doctor: 'doctor',
  ProviderType.nurse: 'nurse',
  ProviderType.therapist: 'therapist',
};
