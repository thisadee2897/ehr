import '../services/database_service.dart';
import '../models/patient.dart';

class PatientRepository {
  final DatabaseService _databaseService;

  PatientRepository(this._databaseService);

  // สร้างผู้ป่วยใหม่
  Future<int> createPatient(Patient patient) async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    
    final patientData = patient.copyWith(
      createdAt: now,
      updatedAt: now,
    ).toMap();
    
    return await db.insert('patients', patientData);
  }

  // ค้นหาผู้ป่วยตาม ID
  Future<Patient?> getPatientById(int patientId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );

    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  // ค้นหาผู้ป่วยตาม HN
  Future<Patient?> getPatientByHN(String hospitalNumber) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'hospital_number = ?',
      whereArgs: [hospitalNumber],
    );

    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  // ค้นหาผู้ป่วยตามเลขประจำตัวประชาชน
  Future<Patient?> getPatientByNationalId(String nationalId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'national_id = ?',
      whereArgs: [nationalId],
    );

    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  // ค้นหาผู้ป่วยตามชื่อ
  Future<List<Patient>> searchPatientsByName(String searchTerm) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'first_name LIKE ? OR last_name LIKE ?',
      whereArgs: ['%$searchTerm%', '%$searchTerm%'],
      orderBy: 'first_name, last_name',
    );

    return List.generate(maps.length, (i) {
      return Patient.fromMap(maps[i]);
    });
  }

  // ดึงรายการผู้ป่วยทั้งหมด (มี pagination)
  Future<List<Patient>> getAllPatients({int? limit, int? offset}) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return Patient.fromMap(maps[i]);
    });
  }

  // นับจำนวนผู้ป่วยทั้งหมด
  Future<int> getPatientCount() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM patients',
    );
    return result.first['count'] as int;
  }

  // อัพเดทข้อมูลผู้ป่วย
  Future<int> updatePatient(Patient patient) async {
    final db = await _databaseService.database;
    final patientData = patient.copyWith(
      updatedAt: DateTime.now(),
    ).toMap();

    return await db.update(
      'patients',
      patientData,
      where: 'patient_id = ?',
      whereArgs: [patient.patientId],
    );
  }

  // ลบผู้ป่วย
  Future<int> deletePatient(int patientId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'patients',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  // ตรวจสอบว่า HN ซ้ำหรือไม่
  Future<bool> isHNExists(String hospitalNumber, {int? excludePatientId}) async {
    final db = await _databaseService.database;
    String whereClause = 'hospital_number = ?';
    List<dynamic> whereArgs = [hospitalNumber];

    if (excludePatientId != null) {
      whereClause += ' AND patient_id != ?';
      whereArgs.add(excludePatientId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }

  // ตรวจสอบว่าเลขประจำตัวประชาชนซ้ำหรือไม่
  Future<bool> isNationalIdExists(String nationalId, {int? excludePatientId}) async {
    final db = await _databaseService.database;
    String whereClause = 'national_id = ?';
    List<dynamic> whereArgs = [nationalId];

    if (excludePatientId != null) {
      whereClause += ' AND patient_id != ?';
      whereArgs.add(excludePatientId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }

  // สร้าง HN อัตโนมัติ
  Future<String> generateNextHN() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT hospital_number FROM patients ORDER BY CAST(hospital_number AS INTEGER) DESC LIMIT 1',
    );

    if (result.isEmpty) {
      return '0000001'; // HN แรก
    }

    final lastHN = result.first['hospital_number'] as String;
    final lastNumber = int.tryParse(lastHN) ?? 0;
    final nextNumber = lastNumber + 1;
    
    return nextNumber.toString().padLeft(7, '0');
  }

  // ค้นหาผู้ป่วยด้วยเงื่อนไขหลายอย่าง
  Future<List<Patient>> searchPatients({
    String? hospitalNumber,
    String? nationalId,
    String? firstName,
    String? lastName,
    Gender? gender,
    DateTime? dateOfBirthFrom,
    DateTime? dateOfBirthTo,
    int? limit,
    int? offset,
  }) async {
    final db = await _databaseService.database;
    
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (hospitalNumber != null && hospitalNumber.isNotEmpty) {
      whereConditions.add('hospital_number LIKE ?');
      whereArgs.add('%$hospitalNumber%');
    }

    if (nationalId != null && nationalId.isNotEmpty) {
      whereConditions.add('national_id LIKE ?');
      whereArgs.add('%$nationalId%');
    }

    if (firstName != null && firstName.isNotEmpty) {
      whereConditions.add('first_name LIKE ?');
      whereArgs.add('%$firstName%');
    }

    if (lastName != null && lastName.isNotEmpty) {
      whereConditions.add('last_name LIKE ?');
      whereArgs.add('%$lastName%');
    }

    if (gender != null) {
      whereConditions.add('gender = ?');
      whereArgs.add(gender.name);
    }

    if (dateOfBirthFrom != null) {
      whereConditions.add('date_of_birth >= ?');
      whereArgs.add(dateOfBirthFrom.toIso8601String());
    }

    if (dateOfBirthTo != null) {
      whereConditions.add('date_of_birth <= ?');
      whereArgs.add(dateOfBirthTo.toIso8601String());
    }

    String? whereClause = whereConditions.isNotEmpty 
        ? whereConditions.join(' AND ') 
        : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return Patient.fromMap(maps[i]);
    });
  }
}
