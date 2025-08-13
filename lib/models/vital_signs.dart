import 'package:json_annotation/json_annotation.dart';

part 'vital_signs.g.dart';

@JsonSerializable()
class VitalSigns {
  final int? vitalSignId;
  final int admissionId;
  final DateTime recordedAt;
  final double? bodyTemperature; // °C
  final int? pulseRate; // /min
  final int? respiratoryRate; // /min
  final int? bpSystolic; // mmHg
  final int? bpDiastolic; // mmHg
  final int? oxygenSaturation; // %
  final int? painScore; // 0-10
  final int? recordedByProviderId;

  const VitalSigns({
    this.vitalSignId,
    required this.admissionId,
    required this.recordedAt,
    this.bodyTemperature,
    this.pulseRate,
    this.respiratoryRate,
    this.bpSystolic,
    this.bpDiastolic,
    this.oxygenSaturation,
    this.painScore,
    this.recordedByProviderId,
  });

  // แสดงความดันโลหิตในรูปแบบ "120/80"
  String get bloodPressure {
    if (bpSystolic != null && bpDiastolic != null) {
      return '$bpSystolic/$bpDiastolic';
    }
    return '-';
  }

  // ตรวจสอบความผิดปกติของสัญญาณชีพ
  bool get hasAbnormalVitals {
    // ตัวอย่างการตรวจสอบ (ค่าปกติเป็นแนวทาง)
    if (bodyTemperature != null && (bodyTemperature! < 36.0 || bodyTemperature! > 37.5)) return true;
    if (pulseRate != null && (pulseRate! < 60 || pulseRate! > 100)) return true;
    if (respiratoryRate != null && (respiratoryRate! < 12 || respiratoryRate! > 20)) return true;
    if (bpSystolic != null && (bpSystolic! < 90 || bpSystolic! > 140)) return true;
    if (bpDiastolic != null && (bpDiastolic! < 60 || bpDiastolic! > 90)) return true;
    if (oxygenSaturation != null && oxygenSaturation! < 95) return true;
    return false;
  }

  // แปลงข้อมูลเป็น Map สำหรับ SQLite
  Map<String, dynamic> toMap() {
    return {
      'vital_sign_id': vitalSignId,
      'admission_id': admissionId,
      'recorded_at': recordedAt.toIso8601String(),
      'body_temperature': bodyTemperature,
      'pulse_rate': pulseRate,
      'respiratory_rate': respiratoryRate,
      'bp_systolic': bpSystolic,
      'bp_diastolic': bpDiastolic,
      'oxygen_saturation': oxygenSaturation,
      'pain_score': painScore,
      'recorded_by_provider_id': recordedByProviderId,
    };
  }

  // สร้าง VitalSigns จาก Map (SQLite result)
  factory VitalSigns.fromMap(Map<String, dynamic> map) {
    return VitalSigns(
      vitalSignId: map['vital_sign_id'] as int?,
      admissionId: map['admission_id'] as int,
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      bodyTemperature: map['body_temperature'] as double?,
      pulseRate: map['pulse_rate'] as int?,
      respiratoryRate: map['respiratory_rate'] as int?,
      bpSystolic: map['bp_systolic'] as int?,
      bpDiastolic: map['bp_diastolic'] as int?,
      oxygenSaturation: map['oxygen_saturation'] as int?,
      painScore: map['pain_score'] as int?,
      recordedByProviderId: map['recorded_by_provider_id'] as int?,
    );
  }

  // JSON serialization
  factory VitalSigns.fromJson(Map<String, dynamic> json) => _$VitalSignsFromJson(json);
  Map<String, dynamic> toJson() => _$VitalSignsToJson(this);

  // CopyWith method
  VitalSigns copyWith({
    int? vitalSignId,
    int? admissionId,
    DateTime? recordedAt,
    double? bodyTemperature,
    int? pulseRate,
    int? respiratoryRate,
    int? bpSystolic,
    int? bpDiastolic,
    int? oxygenSaturation,
    int? painScore,
    int? recordedByProviderId,
  }) {
    return VitalSigns(
      vitalSignId: vitalSignId ?? this.vitalSignId,
      admissionId: admissionId ?? this.admissionId,
      recordedAt: recordedAt ?? this.recordedAt,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      pulseRate: pulseRate ?? this.pulseRate,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      bpSystolic: bpSystolic ?? this.bpSystolic,
      bpDiastolic: bpDiastolic ?? this.bpDiastolic,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      painScore: painScore ?? this.painScore,
      recordedByProviderId: recordedByProviderId ?? this.recordedByProviderId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VitalSigns && other.vitalSignId == vitalSignId;
  }

  @override
  int get hashCode => vitalSignId.hashCode;

  @override
  String toString() {
    return 'VitalSigns(vitalSignId: $vitalSignId, admissionId: $admissionId, recordedAt: $recordedAt)';
  }
}
