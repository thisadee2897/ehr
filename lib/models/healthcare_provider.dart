import 'package:json_annotation/json_annotation.dart';

part 'healthcare_provider.g.dart';

enum ProviderType { doctor, nurse, therapist }

@JsonSerializable()
class HealthcareProvider {
  final int? providerId;
  final String licenseNumber;
  final String firstName;
  final String lastName;
  final ProviderType providerType;
  final String? specialty;

  const HealthcareProvider({
    this.providerId,
    required this.licenseNumber,
    required this.firstName,
    required this.lastName,
    required this.providerType,
    this.specialty,
  });

  // ชื่อเต็ม
  String get fullName => '$firstName $lastName';

  // ชื่อพร้อมตำแหน่ง
  String get displayName {
    String prefix = '';
    switch (providerType) {
      case ProviderType.doctor:
        prefix = 'นพ.';
        break;
      case ProviderType.nurse:
        prefix = 'พย.';
        break;
      case ProviderType.therapist:
        prefix = 'นักกายภาพ';
        break;
    }
    return '$prefix $fullName';
  }

  // แปลงข้อมูลเป็น Map สำหรับ SQLite
  Map<String, dynamic> toMap() {
    return {
      'provider_id': providerId,
      'license_number': licenseNumber,
      'first_name': firstName,
      'last_name': lastName,
      'provider_type': providerType.name,
      'specialty': specialty,
    };
  }

  // สร้าง HealthcareProvider จาก Map (SQLite result)
  factory HealthcareProvider.fromMap(Map<String, dynamic> map) {
    return HealthcareProvider(
      providerId: map['provider_id'] as int?,
      licenseNumber: map['license_number'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      providerType: ProviderType.values.firstWhere(
        (e) => e.name == map['provider_type'],
        orElse: () => ProviderType.doctor,
      ),
      specialty: map['specialty'] as String?,
    );
  }

  // JSON serialization
  factory HealthcareProvider.fromJson(Map<String, dynamic> json) => _$HealthcareProviderFromJson(json);
  Map<String, dynamic> toJson() => _$HealthcareProviderToJson(this);

  // CopyWith method
  HealthcareProvider copyWith({
    int? providerId,
    String? licenseNumber,
    String? firstName,
    String? lastName,
    ProviderType? providerType,
    String? specialty,
  }) {
    return HealthcareProvider(
      providerId: providerId ?? this.providerId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      providerType: providerType ?? this.providerType,
      specialty: specialty ?? this.specialty,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthcareProvider && other.providerId == providerId;
  }

  @override
  int get hashCode => providerId.hashCode;

  @override
  String toString() {
    return 'HealthcareProvider(providerId: $providerId, fullName: $fullName, type: $providerType)';
  }
}
