import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'assessment_form.g.dart';

@JsonSerializable()
class AssessmentForm {
  @JsonKey(name: 'form_id')
  final int? formId;
  
  @JsonKey(name: 'form_name')
  final String formName;
  
  @JsonKey(name: 'form_details')
  final Map<String, dynamic> formDetails; // เก็บโครงสร้างของฟอร์ม เป็น JSON

  const AssessmentForm({
    this.formId,
    required this.formName,
    required this.formDetails,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'form_id': formId,
      'form_name': formName,
      'form_details': jsonEncode(formDetails),
    };
  }

  // Create AssessmentForm from Map (SQLite result)
  factory AssessmentForm.fromMap(Map<String, dynamic> map) {
    return AssessmentForm(
      formId: map['form_id'] as int?,
      formName: map['form_name'] as String,
      formDetails: map['form_details'] != null
          ? jsonDecode(map['form_details'] as String) as Map<String, dynamic>
          : {},
    );
  }

  // JSON serialization
  factory AssessmentForm.fromJson(Map<String, dynamic> json) => _$AssessmentFormFromJson(json);
  Map<String, dynamic> toJson() => _$AssessmentFormToJson(this);

  // CopyWith method
  AssessmentForm copyWith({
    int? formId,
    String? formName,
    Map<String, dynamic>? formDetails,
  }) {
    return AssessmentForm(
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      formDetails: formDetails ?? this.formDetails,
    );
  }

  @override
  String toString() {
    return 'AssessmentForm(formId: $formId, formName: $formName, formDetails: $formDetails)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssessmentForm &&
        other.formId == formId &&
        other.formName == formName &&
        _mapEquals(other.formDetails, formDetails);
  }

  @override
  int get hashCode {
    return formId.hashCode ^ formName.hashCode ^ formDetails.hashCode;
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
