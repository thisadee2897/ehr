import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'assessment_score.g.dart';

@JsonSerializable()
class AssessmentScore {
  @JsonKey(name: 'score_id')
  final int? scoreId;
  
  @JsonKey(name: 'admission_id')
  final int admissionId;
  
  @JsonKey(name: 'form_id')
  final int formId;
  
  @JsonKey(name: 'assessment_date_time')
  final DateTime assessmentDateTime;
  
  @JsonKey(name: 'assessor_provider_id')
  final int assessorProviderId;
  
  @JsonKey(name: 'total_score')
  final int totalScore;
  
  @JsonKey(name: 'results_data')
  final Map<String, dynamic> resultsData; // เก็บคำตอบแต่ละข้อ เป็น JSON
  
  final String? interpretation;

  const AssessmentScore({
    this.scoreId,
    required this.admissionId,
    required this.formId,
    required this.assessmentDateTime,
    required this.assessorProviderId,
    required this.totalScore,
    required this.resultsData,
    this.interpretation,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'score_id': scoreId,
      'admission_id': admissionId,
      'form_id': formId,
      'assessment_date_time': assessmentDateTime.toIso8601String(),
      'assessor_provider_id': assessorProviderId,
      'total_score': totalScore,
      'results_data': jsonEncode(resultsData),
      'interpretation': interpretation,
    };
  }

  // Create AssessmentScore from Map (SQLite result)
  factory AssessmentScore.fromMap(Map<String, dynamic> map) {
    return AssessmentScore(
      scoreId: map['score_id'] as int?,
      admissionId: map['admission_id'] as int,
      formId: map['form_id'] as int,
      assessmentDateTime: DateTime.parse(map['assessment_date_time'] as String),
      assessorProviderId: map['assessor_provider_id'] as int,
      totalScore: map['total_score'] as int,
      resultsData: map['results_data'] != null
          ? jsonDecode(map['results_data'] as String) as Map<String, dynamic>
          : {},
      interpretation: map['interpretation'] as String?,
    );
  }

  // JSON serialization
  factory AssessmentScore.fromJson(Map<String, dynamic> json) => _$AssessmentScoreFromJson(json);
  Map<String, dynamic> toJson() => _$AssessmentScoreToJson(this);

  // CopyWith method
  AssessmentScore copyWith({
    int? scoreId,
    int? admissionId,
    int? formId,
    DateTime? assessmentDateTime,
    int? assessorProviderId,
    int? totalScore,
    Map<String, dynamic>? resultsData,
    String? interpretation,
  }) {
    return AssessmentScore(
      scoreId: scoreId ?? this.scoreId,
      admissionId: admissionId ?? this.admissionId,
      formId: formId ?? this.formId,
      assessmentDateTime: assessmentDateTime ?? this.assessmentDateTime,
      assessorProviderId: assessorProviderId ?? this.assessorProviderId,
      totalScore: totalScore ?? this.totalScore,
      resultsData: resultsData ?? this.resultsData,
      interpretation: interpretation ?? this.interpretation,
    );
  }

  @override
  String toString() {
    return 'AssessmentScore(scoreId: $scoreId, admissionId: $admissionId, formId: $formId, assessmentDateTime: $assessmentDateTime, assessorProviderId: $assessorProviderId, totalScore: $totalScore, resultsData: $resultsData, interpretation: $interpretation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssessmentScore &&
        other.scoreId == scoreId &&
        other.admissionId == admissionId &&
        other.formId == formId &&
        other.assessmentDateTime == assessmentDateTime &&
        other.assessorProviderId == assessorProviderId &&
        other.totalScore == totalScore &&
        _mapEquals(other.resultsData, resultsData) &&
        other.interpretation == interpretation;
  }

  @override
  int get hashCode {
    return scoreId.hashCode ^
        admissionId.hashCode ^
        formId.hashCode ^
        assessmentDateTime.hashCode ^
        assessorProviderId.hashCode ^
        totalScore.hashCode ^
        resultsData.hashCode ^
        interpretation.hashCode;
  }

  // Helper method to compare maps
  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return false;
    }
    return true;
  }
}
