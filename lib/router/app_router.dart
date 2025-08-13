import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/patients/patient_list_screen.dart';
import '../screens/patients/patient_detail_screen.dart';
import '../screens/patients/patient_form_screen.dart';
import '../screens/admissions/admission_list_screen.dart';
import '../screens/admissions/admission_detail_screen.dart';
import '../screens/admissions/admission_form_screen.dart';
import '../screens/vital_signs/vital_signs_screen.dart';
import '../screens/vital_signs/vital_signs_form_screen.dart';
import '../screens/doctor_orders/doctor_order_list_screen.dart';
import '../screens/doctor_orders/doctor_order_form_screen.dart';
import '../screens/progress_notes/progress_note_list_screen.dart';
import '../screens/progress_notes/progress_note_form_screen.dart';
import '../screens/lab_results/lab_result_list_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Shell Route with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          
          // Patients Routes
          GoRoute(
            path: '/patients',
            name: 'patients',
            builder: (context, state) => const PatientListScreen(),
            routes: [
              GoRoute(
                path: '/new',
                name: 'patient-new',
                builder: (context, state) => const PatientFormScreen(),
              ),
              GoRoute(
                path: '/:patientId',
                name: 'patient-detail',
                builder: (context, state) {
                  final patientId = int.parse(state.pathParameters['patientId']!);
                  return PatientDetailScreen(patientId: patientId);
                },
                routes: [
                  GoRoute(
                    path: '/edit',
                    name: 'patient-edit',
                    builder: (context, state) {
                      final patientId = int.parse(state.pathParameters['patientId']!);
                      return PatientFormScreen(patientId: patientId);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Admissions Routes
          GoRoute(
            path: '/admissions',
            name: 'admissions',
            builder: (context, state) => const AdmissionListScreen(),
            routes: [
              GoRoute(
                path: '/new',
                name: 'admission-new',
                builder: (context, state) {
                  final patientId = state.uri.queryParameters['patientId'];
                  return AdmissionFormScreen(
                    patientId: patientId != null ? int.parse(patientId) : null,
                  );
                },
              ),
              GoRoute(
                path: '/:admissionId',
                name: 'admission-detail',
                builder: (context, state) {
                  final admissionId = int.parse(state.pathParameters['admissionId']!);
                  return AdmissionDetailScreen(admissionId: admissionId);
                },
                routes: [
                  GoRoute(
                    path: '/edit',
                    name: 'admission-edit',
                    builder: (context, state) {
                      final admissionId = int.parse(state.pathParameters['admissionId']!);
                      return AdmissionFormScreen(admissionId: admissionId);
                    },
                  ),
                  GoRoute(
                    path: '/vital-signs',
                    name: 'vital-signs',
                    builder: (context, state) {
                      final admissionId = int.parse(state.pathParameters['admissionId']!);
                      return VitalSignsScreen(admissionId: admissionId);
                    },
                    routes: [
                      GoRoute(
                        path: '/new',
                        name: 'vital-signs-new',
                        builder: (context, state) {
                          final admissionId = int.parse(state.pathParameters['admissionId']!);
                          return VitalSignsFormScreen(admissionId: admissionId);
                        },
                      ),
                      GoRoute(
                        path: '/:vitalSignId/edit',
                        name: 'vital-signs-edit',
                        builder: (context, state) {
                          final admissionId = int.parse(state.pathParameters['admissionId']!);
                          final vitalSignId = int.parse(state.pathParameters['vitalSignId']!);
                          return VitalSignsFormScreen(
                            admissionId: admissionId,
                            vitalSignId: vitalSignId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('ข้อผิดพลาด')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'ไม่พบหน้าที่ต้องการ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('กลับหน้าหลัก'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Main Shell with Bottom Navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'ผู้ป่วย',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'การรักษา',
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/patients')) {
      return 1;
    }
    if (location.startsWith('/admissions')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/patients');
        break;
      case 2:
        context.go('/admissions');
        break;
    }
  }
}

// Route Extensions for easy navigation
extension AppRouterExtension on BuildContext {
  // Patient Routes
  void goToPatientList() => go('/patients');
  void goToPatientDetail(int patientId) => go('/patients/$patientId');
  void goToPatientNew() => go('/patients/new');
  void goToPatientEdit(int patientId) => go('/patients/$patientId/edit');

  // Admission Routes
  void goToAdmissionList() => go('/admissions');
  void goToAdmissionDetail(int admissionId) => go('/admissions/$admissionId');
  void goToAdmissionNew({int? patientId}) {
    if (patientId != null) {
      go('/admissions/new?patientId=$patientId');
    } else {
      go('/admissions/new');
    }
  }
  void goToAdmissionEdit(int admissionId) => go('/admissions/$admissionId/edit');

  // Vital Signs Routes
  void goToVitalSigns(int admissionId) => go('/admissions/$admissionId/vital-signs');
  void goToVitalSignsNew(int admissionId) => go('/admissions/$admissionId/vital-signs/new');
  void goToVitalSignsEdit(int admissionId, int vitalSignId) => 
      go('/admissions/$admissionId/vital-signs/$vitalSignId/edit');

  // Navigation helpers
  void goHome() => go('/');
  void goBack() => pop();
}
