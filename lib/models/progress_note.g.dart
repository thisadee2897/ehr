// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressNote _$ProgressNoteFromJson(Map<String, dynamic> json) => ProgressNote(
  noteId: (json['note_id'] as num?)?.toInt(),
  admissionId: (json['admission_id'] as num).toInt(),
  noteDateTime: DateTime.parse(json['note_date_time'] as String),
  authorProviderId: (json['author_provider_id'] as num).toInt(),
  problem: json['problem'] as String?,
  subjective: json['subjective'] as String?,
  objective: json['objective'] as String?,
  assessment: json['assessment'] as String?,
  plan: json['plan'] as String?,
);

Map<String, dynamic> _$ProgressNoteToJson(ProgressNote instance) =>
    <String, dynamic>{
      'note_id': instance.noteId,
      'admission_id': instance.admissionId,
      'note_date_time': instance.noteDateTime.toIso8601String(),
      'author_provider_id': instance.authorProviderId,
      'problem': instance.problem,
      'subjective': instance.subjective,
      'objective': instance.objective,
      'assessment': instance.assessment,
      'plan': instance.plan,
    };
