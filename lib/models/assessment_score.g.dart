// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentScore _$AssessmentScoreFromJson(Map<String, dynamic> json) =>
    AssessmentScore(
      scoreId: (json['score_id'] as num?)?.toInt(),
      admissionId: (json['admission_id'] as num).toInt(),
      formId: (json['form_id'] as num).toInt(),
      assessmentDateTime: DateTime.parse(
        json['assessment_date_time'] as String,
      ),
      assessorProviderId: (json['assessor_provider_id'] as num).toInt(),
      totalScore: (json['total_score'] as num).toInt(),
      resultsData: json['results_data'] as Map<String, dynamic>,
      interpretation: json['interpretation'] as String?,
    );

Map<String, dynamic> _$AssessmentScoreToJson(AssessmentScore instance) =>
    <String, dynamic>{
      'score_id': instance.scoreId,
      'admission_id': instance.admissionId,
      'form_id': instance.formId,
      'assessment_date_time': instance.assessmentDateTime.toIso8601String(),
      'assessor_provider_id': instance.assessorProviderId,
      'total_score': instance.totalScore,
      'results_data': instance.resultsData,
      'interpretation': instance.interpretation,
    };
