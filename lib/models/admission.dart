import 'package:json_annotation/json_annotation.dart';

part 'admission.g.dart';

enum DischargeType { improved, againstAdvice, transfer, deceased }

@JsonSerializable()
class Admission {
  final int? admissionId;
  final String admissionNumber; // AN
  final int patientId;
  final DateTime admissionDateTime;
  final DateTime? dischargeDateTime;
  final int? admittingDoctorId;
  final String? chiefComplaint;
  final String? presentIllness;
  final String? provisionalDiagnosis;
  final String? finalDiagnosis;
  final String? ward;
  final String? bedNumber;
  final String? insuranceRight;
  final DischargeType? dischargeType;
  final DateTime? createdAt;

  const Admission({
    this.admissionId,
    required this.admissionNumber,
    required this.patientId,
    required this.admissionDateTime,
    this.dischargeDateTime,
    this.admittingDoctorId,
    this.chiefComplaint,
    this.presentIllness,
    this.provisionalDiagnosis,
    this.finalDiagnosis,
    this.ward,
    this.bedNumber,
    this.insuranceRight,
    this.dischargeType,
    this.createdAt,
  });

  // คำนวณระยะเวลาที่อยู่ในโรงพยาบาล
  int get lengthOfStay {
    final endDate = dischargeDateTime ?? DateTime.now();
    return endDate.difference(admissionDateTime).inDays;
  }

  // สถานะการรักษา
  bool get isActive => dischargeDateTime == null;

  // แปลงข้อมูลเป็น Map สำหรับ SQLite
  Map<String, dynamic> toMap() {
    return {
      'admission_id': admissionId,
      'admission_number': admissionNumber,
      'patient_id': patientId,
      'admission_date_time': admissionDateTime.toIso8601String(),
      'discharge_date_time': dischargeDateTime?.toIso8601String(),
      'admitting_doctor_id': admittingDoctorId,
      'chief_complaint': chiefComplaint,
      'present_illness': presentIllness,
      'provisional_diagnosis': provisionalDiagnosis,
      'final_diagnosis': finalDiagnosis,
      'ward': ward,
      'bed_number': bedNumber,
      'insurance_right': insuranceRight,
      'discharge_type': dischargeType?.name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // สร้าง Admission จาก Map (SQLite result)
  factory Admission.fromMap(Map<String, dynamic> map) {
    return Admission(
      admissionId: map['admission_id'] as int?,
      admissionNumber: map['admission_number'] as String,
      patientId: map['patient_id'] as int,
      admissionDateTime: DateTime.parse(map['admission_date_time'] as String),
      dischargeDateTime: map['discharge_date_time'] != null
          ? DateTime.parse(map['discharge_date_time'] as String)
          : null,
      admittingDoctorId: map['admitting_doctor_id'] as int?,
      chiefComplaint: map['chief_complaint'] as String?,
      presentIllness: map['present_illness'] as String?,
      provisionalDiagnosis: map['provisional_diagnosis'] as String?,
      finalDiagnosis: map['final_diagnosis'] as String?,
      ward: map['ward'] as String?,
      bedNumber: map['bed_number'] as String?,
      insuranceRight: map['insurance_right'] as String?,
      dischargeType: map['discharge_type'] != null
          ? DischargeType.values.firstWhere(
              (e) => e.name == map['discharge_type'],
              orElse: () => DischargeType.improved,
            )
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  // JSON serialization
  factory Admission.fromJson(Map<String, dynamic> json) => _$AdmissionFromJson(json);
  Map<String, dynamic> toJson() => _$AdmissionToJson(this);

  // CopyWith method
  Admission copyWith({
    int? admissionId,
    String? admissionNumber,
    int? patientId,
    DateTime? admissionDateTime,
    DateTime? dischargeDateTime,
    int? admittingDoctorId,
    String? chiefComplaint,
    String? presentIllness,
    String? provisionalDiagnosis,
    String? finalDiagnosis,
    String? ward,
    String? bedNumber,
    String? insuranceRight,
    DischargeType? dischargeType,
    DateTime? createdAt,
  }) {
    return Admission(
      admissionId: admissionId ?? this.admissionId,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      patientId: patientId ?? this.patientId,
      admissionDateTime: admissionDateTime ?? this.admissionDateTime,
      dischargeDateTime: dischargeDateTime ?? this.dischargeDateTime,
      admittingDoctorId: admittingDoctorId ?? this.admittingDoctorId,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      presentIllness: presentIllness ?? this.presentIllness,
      provisionalDiagnosis: provisionalDiagnosis ?? this.provisionalDiagnosis,
      finalDiagnosis: finalDiagnosis ?? this.finalDiagnosis,
      ward: ward ?? this.ward,
      bedNumber: bedNumber ?? this.bedNumber,
      insuranceRight: insuranceRight ?? this.insuranceRight,
      dischargeType: dischargeType ?? this.dischargeType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Admission && other.admissionId == admissionId;
  }

  @override
  int get hashCode => admissionId.hashCode;

  @override
  String toString() {
    return 'Admission(admissionId: $admissionId, admissionNumber: $admissionNumber, patientId: $patientId)';
  }
}
