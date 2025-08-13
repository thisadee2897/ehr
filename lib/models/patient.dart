import 'package:json_annotation/json_annotation.dart';

part 'patient.g.dart';

enum Gender { male, female, other }

enum MaritalStatus { single, married, divorced, widowed }

@JsonSerializable()
class Patient {
  final int? patientId;
  final String hospitalNumber; // HN
  final String? nationalId; // เลขประจำตัวประชาชน
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String? address;
  final String? phoneNumber;
  final String? religion;
  final MaritalStatus? maritalStatus;
  final String? nationality;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    this.patientId,
    required this.hospitalNumber,
    this.nationalId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.address,
    this.phoneNumber,
    this.religion,
    this.maritalStatus,
    this.nationality,
    this.createdAt,
    this.updatedAt,
  });

  // คำนวณอายุจากวันเกิด
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // ชื่อเต็ม
  String get fullName => '$firstName $lastName';

  // แปลงข้อมูลเป็น Map สำหรับ SQLite
  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'hospital_number': hospitalNumber,
      'national_id': nationalId,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender.name,
      'address': address,
      'phone_number': phoneNumber,
      'religion': religion,
      'marital_status': maritalStatus?.name,
      'nationality': nationality,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // สร้าง Patient จาก Map (SQLite result)
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientId: map['patient_id'] as int?,
      hospitalNumber: map['hospital_number'] as String,
      nationalId: map['national_id'] as String?,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      dateOfBirth: DateTime.parse(map['date_of_birth'] as String),
      gender: Gender.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => Gender.other,
      ),
      address: map['address'] as String?,
      phoneNumber: map['phone_number'] as String?,
      religion: map['religion'] as String?,
      maritalStatus: map['marital_status'] != null
          ? MaritalStatus.values.firstWhere(
              (e) => e.name == map['marital_status'],
              orElse: () => MaritalStatus.single,
            )
          : null,
      nationality: map['nationality'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  // JSON serialization
  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
  Map<String, dynamic> toJson() => _$PatientToJson(this);

  // CopyWith method
  Patient copyWith({
    int? patientId,
    String? hospitalNumber,
    String? nationalId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    Gender? gender,
    String? address,
    String? phoneNumber,
    String? religion,
    MaritalStatus? maritalStatus,
    String? nationality,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      patientId: patientId ?? this.patientId,
      hospitalNumber: hospitalNumber ?? this.hospitalNumber,
      nationalId: nationalId ?? this.nationalId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      religion: religion ?? this.religion,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      nationality: nationality ?? this.nationality,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.patientId == patientId;
  }

  @override
  int get hashCode => patientId.hashCode;

  @override
  String toString() {
    return 'Patient(patientId: $patientId, hospitalNumber: $hospitalNumber, fullName: $fullName)';
  }
}
