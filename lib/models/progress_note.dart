import 'package:json_annotation/json_annotation.dart';

part 'progress_note.g.dart';

@JsonSerializable()
class ProgressNote {
  @JsonKey(name: 'note_id')
  final int? noteId;
  
  @JsonKey(name: 'admission_id')
  final int admissionId;
  
  @JsonKey(name: 'note_date_time')
  final DateTime noteDateTime;
  
  @JsonKey(name: 'author_provider_id')
  final int authorProviderId;
  
  final String? problem;
  final String? subjective;  // S - ข้อมูลจากผู้ป่วย
  final String? objective;   // O - ข้อมูลที่ตรวจวัดได้
  final String? assessment;  // A - การประเมิน
  final String? plan;        // P - แผนการรักษา

  const ProgressNote({
    this.noteId,
    required this.admissionId,
    required this.noteDateTime,
    required this.authorProviderId,
    this.problem,
    this.subjective,
    this.objective,
    this.assessment,
    this.plan,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'note_id': noteId,
      'admission_id': admissionId,
      'note_date_time': noteDateTime.toIso8601String(),
      'author_provider_id': authorProviderId,
      'problem': problem,
      'subjective': subjective,
      'objective': objective,
      'assessment': assessment,
      'plan': plan,
    };
  }

  // Create ProgressNote from Map (SQLite result)
  factory ProgressNote.fromMap(Map<String, dynamic> map) {
    return ProgressNote(
      noteId: map['note_id'] as int?,
      admissionId: map['admission_id'] as int,
      noteDateTime: DateTime.parse(map['note_date_time'] as String),
      authorProviderId: map['author_provider_id'] as int,
      problem: map['problem'] as String?,
      subjective: map['subjective'] as String?,
      objective: map['objective'] as String?,
      assessment: map['assessment'] as String?,
      plan: map['plan'] as String?,
    );
  }

  // JSON serialization
  factory ProgressNote.fromJson(Map<String, dynamic> json) => _$ProgressNoteFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressNoteToJson(this);

  // CopyWith method
  ProgressNote copyWith({
    int? noteId,
    int? admissionId,
    DateTime? noteDateTime,
    int? authorProviderId,
    String? problem,
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
  }) {
    return ProgressNote(
      noteId: noteId ?? this.noteId,
      admissionId: admissionId ?? this.admissionId,
      noteDateTime: noteDateTime ?? this.noteDateTime,
      authorProviderId: authorProviderId ?? this.authorProviderId,
      problem: problem ?? this.problem,
      subjective: subjective ?? this.subjective,
      objective: objective ?? this.objective,
      assessment: assessment ?? this.assessment,
      plan: plan ?? this.plan,
    );
  }

  @override
  String toString() {
    return 'ProgressNote(noteId: $noteId, admissionId: $admissionId, noteDateTime: $noteDateTime, authorProviderId: $authorProviderId, problem: $problem, subjective: $subjective, objective: $objective, assessment: $assessment, plan: $plan)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgressNote &&
        other.noteId == noteId &&
        other.admissionId == admissionId &&
        other.noteDateTime == noteDateTime &&
        other.authorProviderId == authorProviderId &&
        other.problem == problem &&
        other.subjective == subjective &&
        other.objective == objective &&
        other.assessment == assessment &&
        other.plan == plan;
  }

  @override
  int get hashCode {
    return noteId.hashCode ^
        admissionId.hashCode ^
        noteDateTime.hashCode ^
        authorProviderId.hashCode ^
        problem.hashCode ^
        subjective.hashCode ^
        objective.hashCode ^
        assessment.hashCode ^
        plan.hashCode;
  }
}
