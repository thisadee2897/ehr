// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentForm _$AssessmentFormFromJson(Map<String, dynamic> json) =>
    AssessmentForm(
      formId: (json['form_id'] as num?)?.toInt(),
      formName: json['form_name'] as String,
      formDetails: json['form_details'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AssessmentFormToJson(AssessmentForm instance) =>
    <String, dynamic>{
      'form_id': instance.formId,
      'form_name': instance.formName,
      'form_details': instance.formDetails,
    };
