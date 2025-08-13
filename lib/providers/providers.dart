import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/database_service.dart';
import '../repositories/patient_repository.dart';
import '../repositories/admission_repository.dart';
import '../repositories/vital_signs_repository.dart';

part 'providers.g.dart';

// Database Service Provider
@Riverpod(keepAlive: true)
DatabaseService databaseService(DatabaseServiceRef ref) {
  return DatabaseService();
}

// Repository Providers
@Riverpod(keepAlive: true)
PatientRepository patientRepository(PatientRepositoryRef ref) {
  return PatientRepository(ref.watch(databaseServiceProvider));
}

@Riverpod(keepAlive: true)
AdmissionRepository admissionRepository(AdmissionRepositoryRef ref) {
  return AdmissionRepository(ref.watch(databaseServiceProvider));
}

@Riverpod(keepAlive: true)
VitalSignsRepository vitalSignsRepository(VitalSignsRepositoryRef ref) {
  return VitalSignsRepository(ref.watch(databaseServiceProvider));
}
