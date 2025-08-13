import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'lab_result.g.dart';

@JsonSerializable()
class LabResult {
  @JsonKey(name: 'result_id')
  final int? resultId;
  
  @JsonKey(name: 'admission_id')
  final int admissionId;
  
  @JsonKey(name: 'test_name')
  final String testName;
  
  @JsonKey(name: 'specimen_date_time')
  final DateTime? specimenDateTime;
  
  @JsonKey(name: 'result_date_time')
  final DateTime? resultDateTime;
  
  @JsonKey(name: 'result_details')
  final Map<String, dynamic> resultDetails; // เก็บผล Lab เป็น JSON
  
  final String? note;

  const LabResult({
    this.resultId,
    required this.admissionId,
    required this.testName,
    this.specimenDateTime,
    this.resultDateTime,
    required this.resultDetails,
    this.note,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'result_id': resultId,
      'admission_id': admissionId,
      'test_name': testName,
      'specimen_date_time': specimenDateTime?.toIso8601String(),
      'result_date_time': resultDateTime?.toIso8601String(),
      'result_details': jsonEncode(resultDetails),
      'note': note,
    };
  }

  // Create LabResult from Map (SQLite result)
  factory LabResult.fromMap(Map<String, dynamic> map) {
    return LabResult(
      resultId: map['result_id'] as int?,
      admissionId: map['admission_id'] as int,
      testName: map['test_name'] as String,
      specimenDateTime: map['specimen_date_time'] != null 
          ? DateTime.parse(map['specimen_date_time'] as String)
          : null,
      resultDateTime: map['result_date_time'] != null 
          ? DateTime.parse(map['result_date_time'] as String)
          : null,
      resultDetails: map['result_details'] != null
          ? jsonDecode(map['result_details'] as String) as Map<String, dynamic>
          : {},
      note: map['note'] as String?,
    );
  }

  // JSON serialization
  factory LabResult.fromJson(Map<String, dynamic> json) => _$LabResultFromJson(json);
  Map<String, dynamic> toJson() => _$LabResultToJson(this);

  // CopyWith method
  LabResult copyWith({
    int? resultId,
    int? admissionId,
    String? testName,
    DateTime? specimenDateTime,
    DateTime? resultDateTime,
    Map<String, dynamic>? resultDetails,
    String? note,
  }) {
    return LabResult(
      resultId: resultId ?? this.resultId,
      admissionId: admissionId ?? this.admissionId,
      testName: testName ?? this.testName,
      specimenDateTime: specimenDateTime ?? this.specimenDateTime,
      resultDateTime: resultDateTime ?? this.resultDateTime,
      resultDetails: resultDetails ?? this.resultDetails,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'LabResult(resultId: $resultId, admissionId: $admissionId, testName: $testName, specimenDateTime: $specimenDateTime, resultDateTime: $resultDateTime, resultDetails: $resultDetails, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LabResult &&
        other.resultId == resultId &&
        other.admissionId == admissionId &&
        other.testName == testName &&
        other.specimenDateTime == specimenDateTime &&
        other.resultDateTime == resultDateTime &&
        _mapEquals(other.resultDetails, resultDetails) &&
        other.note == note;
  }

  @override
  int get hashCode {
    return resultId.hashCode ^
        admissionId.hashCode ^
        testName.hashCode ^
        specimenDateTime.hashCode ^
        resultDateTime.hashCode ^
        resultDetails.hashCode ^
        note.hashCode;
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
