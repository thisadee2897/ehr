import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'ehr_database.db';
  static const int _databaseVersion = 1;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  // Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Create Patients table
    await db.execute('''
      CREATE TABLE patients (
        patient_id INTEGER PRIMARY KEY AUTOINCREMENT,
        hospital_number TEXT UNIQUE NOT NULL,
        national_id TEXT UNIQUE,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        address TEXT,
        phone_number TEXT,
        religion TEXT,
        marital_status TEXT,
        nationality TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create HealthcareProviders table
    await db.execute('''
      CREATE TABLE healthcare_providers (
        provider_id INTEGER PRIMARY KEY AUTOINCREMENT,
        license_number TEXT UNIQUE NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        provider_type TEXT NOT NULL,
        specialty TEXT
      )
    ''');

    // Create Admissions table
    await db.execute('''
      CREATE TABLE admissions (
        admission_id INTEGER PRIMARY KEY AUTOINCREMENT,
        admission_number TEXT UNIQUE NOT NULL,
        patient_id INTEGER NOT NULL,
        admission_date_time TEXT NOT NULL,
        discharge_date_time TEXT,
        admitting_doctor_id INTEGER,
        chief_complaint TEXT,
        present_illness TEXT,
        provisional_diagnosis TEXT,
        final_diagnosis TEXT,
        ward TEXT,
        bed_number TEXT,
        insurance_right TEXT,
        discharge_type TEXT,
        created_at TEXT,
        FOREIGN KEY (patient_id) REFERENCES patients (patient_id),
        FOREIGN KEY (admitting_doctor_id) REFERENCES healthcare_providers (provider_id)
      )
    ''');

    // Create VitalSigns table
    await db.execute('''
      CREATE TABLE vital_signs (
        vital_sign_id INTEGER PRIMARY KEY AUTOINCREMENT,
        admission_id INTEGER NOT NULL,
        recorded_at TEXT NOT NULL,
        body_temperature REAL,
        pulse_rate INTEGER,
        respiratory_rate INTEGER,
        bp_systolic INTEGER,
        bp_diastolic INTEGER,
        oxygen_saturation INTEGER,
        pain_score INTEGER,
        recorded_by_provider_id INTEGER,
        FOREIGN KEY (admission_id) REFERENCES admissions (admission_id),
        FOREIGN KEY (recorded_by_provider_id) REFERENCES healthcare_providers (provider_id)
      )
    ''');

    // Create DoctorOrders table
    await db.execute('''
      CREATE TABLE doctor_orders (
        order_id INTEGER PRIMARY KEY AUTOINCREMENT,
        admission_id INTEGER NOT NULL,
        order_date_time TEXT NOT NULL,
        ordering_provider_id INTEGER NOT NULL,
        order_type TEXT NOT NULL,
        order_text TEXT NOT NULL,
        is_continuous INTEGER DEFAULT 0,
        status TEXT DEFAULT 'Active',
        FOREIGN KEY (admission_id) REFERENCES admissions (admission_id),
        FOREIGN KEY (ordering_provider_id) REFERENCES healthcare_providers (provider_id)
      )
    ''');

    // Create ProgressNotes table
    await db.execute('''
      CREATE TABLE progress_notes (
        note_id INTEGER PRIMARY KEY AUTOINCREMENT,
        admission_id INTEGER NOT NULL,
        note_date_time TEXT NOT NULL,
        author_provider_id INTEGER NOT NULL,
        problem TEXT,
        subjective TEXT,
        objective TEXT,
        assessment TEXT,
        plan TEXT,
        FOREIGN KEY (admission_id) REFERENCES admissions (admission_id),
        FOREIGN KEY (author_provider_id) REFERENCES healthcare_providers (provider_id)
      )
    ''');

    // Create LabResults table
    await db.execute('''
      CREATE TABLE lab_results (
        result_id INTEGER PRIMARY KEY AUTOINCREMENT,
        admission_id INTEGER NOT NULL,
        test_name TEXT NOT NULL,
        specimen_date_time TEXT,
        result_date_time TEXT,
        result_details TEXT,
        note TEXT,
        FOREIGN KEY (admission_id) REFERENCES admissions (admission_id)
      )
    ''');

    // Create AssessmentForms table
    await db.execute('''
      CREATE TABLE assessment_forms (
        form_id INTEGER PRIMARY KEY AUTOINCREMENT,
        form_name TEXT UNIQUE NOT NULL,
        form_details TEXT
      )
    ''');

    // Create AssessmentScores table
    await db.execute('''
      CREATE TABLE assessment_scores (
        score_id INTEGER PRIMARY KEY AUTOINCREMENT,
        admission_id INTEGER NOT NULL,
        form_id INTEGER NOT NULL,
        assessment_date_time TEXT NOT NULL,
        assessor_provider_id INTEGER NOT NULL,
        total_score INTEGER NOT NULL,
        results_data TEXT NOT NULL,
        interpretation TEXT,
        FOREIGN KEY (admission_id) REFERENCES admissions (admission_id),
        FOREIGN KEY (form_id) REFERENCES assessment_forms (form_id),
        FOREIGN KEY (assessor_provider_id) REFERENCES healthcare_providers (provider_id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_patients_hn ON patients (hospital_number)');
    await db.execute('CREATE INDEX idx_patients_national_id ON patients (national_id)');
    await db.execute('CREATE INDEX idx_admissions_patient_id ON admissions (patient_id)');
    await db.execute('CREATE INDEX idx_admissions_an ON admissions (admission_number)');
    await db.execute('CREATE INDEX idx_vital_signs_admission_id ON vital_signs (admission_id)');
    await db.execute('CREATE INDEX idx_vital_signs_recorded_at ON vital_signs (recorded_at)');

    // Insert default healthcare providers
    await _insertDefaultData(db);
  }

  // Database upgrade handler
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations here
    // For now, we'll recreate the database
    // In production, you should handle migrations properly
    
    if (oldVersion < newVersion) {
      // Drop all tables and recreate
      await db.execute('DROP TABLE IF EXISTS assessment_scores');
      await db.execute('DROP TABLE IF EXISTS assessment_forms');
      await db.execute('DROP TABLE IF EXISTS lab_results');
      await db.execute('DROP TABLE IF EXISTS progress_notes');
      await db.execute('DROP TABLE IF EXISTS doctor_orders');
      await db.execute('DROP TABLE IF EXISTS vital_signs');
      await db.execute('DROP TABLE IF EXISTS admissions');
      await db.execute('DROP TABLE IF EXISTS healthcare_providers');
      await db.execute('DROP TABLE IF EXISTS patients');
      
      await _createDatabase(db, newVersion);
    }
  }

  // Insert default data
  Future<void> _insertDefaultData(Database db) async {
    // Insert default healthcare providers
    await db.insert('healthcare_providers', {
      'license_number': 'DOC001',
      'first_name': 'สมศักดิ์',
      'last_name': 'ใจดี',
      'provider_type': 'doctor',
      'specialty': 'อายุรกรรม',
    });

    await db.insert('healthcare_providers', {
      'license_number': 'NUR001',
      'first_name': 'สมหญิง',
      'last_name': 'ดูแลดี',
      'provider_type': 'nurse',
      'specialty': null,
    });

    // Insert sample patients
    await db.insert('patients', {
      'hospital_number': 'HN001',
      'national_id': '1234567890123',
      'first_name': 'สมศรี',
      'last_name': 'รักษาไทย',
      'date_of_birth': '1980-05-15',
      'gender': 'female',
      'address': '123 ถ.สุขใจ ต.สุขใจ อ.สุขใจ จ.กรุงเทพฯ 10100',
      'phone_number': '0812345678',
      'religion': 'พุทธ',
      'marital_status': 'married',
      'nationality': 'ไทย',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('patients', {
      'hospital_number': 'HN002',
      'national_id': '9876543210987',
      'first_name': 'สมชาย',
      'last_name': 'สุขใจ',
      'date_of_birth': '1975-08-20',
      'gender': 'male',
      'address': '456 ถ.รื่นรมย์ ต.รื่นรมย์ อ.รื่นรมย์ จ.นนทบุรี 11000',
      'phone_number': '0898765432',
      'religion': 'พุทธ',
      'marital_status': 'single',
      'nationality': 'ไทย',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert sample admissions
    await db.insert('admissions', {
      'admission_number': 'AN001',
      'patient_id': 1,
      'admission_date_time': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'admitting_doctor_id': 1,
      'chief_complaint': 'ปวดท้อง คลื่นไส้ อาเจียน',
      'present_illness': 'ผู้ป่วยมีอาการปวดท้องตั้งแต่เมื่อวาน ปวดมากขึ้นเรื่อยๆ มีคลื่นไส้ อาเจียน 2 ครั้ง',
      'provisional_diagnosis': 'Acute gastritis',
      'ward': 'Medical Ward A',
      'bed_number': 'A101',
      'insurance_right': 'หลักประกันสุขภาพถ้วนหน้า',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('admissions', {
      'admission_number': 'AN002',
      'patient_id': 2,
      'admission_date_time': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'admitting_doctor_id': 1,
      'chief_complaint': 'เจ็บหน้าอก หายใจลำบาก',
      'present_illness': 'ผู้ป่วยมีอาการเจ็บหน้าอกเหมือนมีคนบีบ หายใจลำบาก เหงื่อออก',
      'provisional_diagnosis': 'Chest pain, rule out MI',
      'ward': 'CCU',
      'bed_number': 'CCU01',
      'insurance_right': 'ประกันสังคม',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert default assessment forms
    await db.insert('assessment_forms', {
      'form_name': 'Fall Risk Assessment Tool',
      'form_details': '{"questions": [{"id": 1, "text": "มีประวัติหกล้มใน 6 เดือนที่ผ่านมา", "type": "boolean", "score": 25}, {"id": 2, "text": "การใช้ยาที่ทำให้เซา/งง", "type": "boolean", "score": 25}, {"id": 3, "text": "ความบกพร่องทางร่างกาย", "type": "boolean", "score": 25}, {"id": 4, "text": "การใช้อุปกรณ์ช่วยเดิน", "type": "boolean", "score": 25}]}',
    });

    await db.insert('assessment_forms', {
      'form_name': 'Pain Assessment Scale',
      'form_details': '{"questions": [{"id": 1, "text": "ระดับความปวด (0-10)", "type": "scale", "min": 0, "max": 10}]}',
    });
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Reset database (for development/testing)
  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    await deleteDatabase(path);
    _database = null;
  }

  // Check if database exists
  Future<bool> databaseExists() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await databaseFactory.databaseExists(path);
  }

  // Get database file size
  Future<int> getDatabaseSize() async {
    String path = join(await getDatabasesPath(), _databaseName);
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
}
