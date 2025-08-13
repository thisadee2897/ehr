import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/database_service.dart';
import '../repositories/patient_repository.dart';
import '../repositories/admission_repository.dart';
import '../repositories/vital_signs_repository.dart';
import '../repositories/doctor_order_repository.dart';
import '../repositories/progress_note_repository.dart';
import '../repositories/lab_result_repository.dart';
import '../repositories/assessment_repository.dart';
import '../repositories/healthcare_provider_repository.dart';

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
HealthcareProviderRepository healthcareProviderRepository(HealthcareProviderRepositoryRef ref) {
  return HealthcareProviderRepository(ref.watch(databaseServiceProvider));
}

@Riverpod(keepAlive: true)
VitalSignsRepository vitalSignsRepository(VitalSignsRepositoryRef ref) {
  return VitalSignsRepository(ref.watch(databaseServiceProvider));
}

@Riverpod(keepAlive: true)
DoctorOrderRepository doctorOrderRepository(DoctorOrderRepositoryRef ref) {
  return DoctorOrderRepository(ref.watch(databaseServiceProvider));
}

@Riverpod(keepAlive: true)
ProgressNoteRepository progressNoteRepository(ProgressNoteRepositoryRef ref) {
  return ProgressNoteRepository(ref.watch(databaseServiceProvider));
}

@Riverpod(keepAlive: true)
LabResultRepository labResultRepository(LabResultRepositoryRef ref) {
  return LabResultRepository(ref.watch(databaseServiceProvider));
}

@Riverpod(keepAlive: true)
AssessmentRepository assessmentRepository(AssessmentRepositoryRef ref) {
  return AssessmentRepository(ref.watch(databaseServiceProvider));
}
