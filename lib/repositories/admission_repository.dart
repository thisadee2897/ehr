import '../services/database_service.dart';
import '../models/admission.dart';

class AdmissionRepository {
  final DatabaseService _databaseService;

  AdmissionRepository(this._databaseService);

  // สร้าง admission ใหม่
  Future<int> createAdmission(Admission admission) async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    
    final admissionData = admission.copyWith(
      createdAt: now,
    ).toMap();
    
    return await db.insert('admissions', admissionData);
  }

  // ค้นหา admission ตาม ID
  Future<Admission?> getAdmissionById(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admissions',
      where: 'admission_id = ?',
      whereArgs: [admissionId],
    );

    if (maps.isNotEmpty) {
      return Admission.fromMap(maps.first);
    }
    return null;
  }

  // ค้นหา admission ตาม AN
  Future<Admission?> getAdmissionByAN(String admissionNumber) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admissions',
      where: 'admission_number = ?',
      whereArgs: [admissionNumber],
    );

    if (maps.isNotEmpty) {
      return Admission.fromMap(maps.first);
    }
    return null;
  }

  // ดึงรายการ admissions ของผู้ป่วย
  Future<List<Admission>> getAdmissionsByPatientId(int patientId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admissions',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'admission_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return Admission.fromMap(maps[i]);
    });
  }

  // ดึง admission ปัจจุบัน (ยังไม่จำหน่าย) ของผู้ป่วย
  Future<Admission?> getCurrentAdmissionByPatientId(int patientId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admissions',
      where: 'patient_id = ? AND discharge_date_time IS NULL',
      whereArgs: [patientId],
      orderBy: 'admission_date_time DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Admission.fromMap(maps.first);
    }
    return null;
  }

  // ดึงรายการ admissions ที่ยังไม่จำหน่าย
  Future<List<Admission>> getActiveAdmissions() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admissions',
      where: 'discharge_date_time IS NULL',
      orderBy: 'admission_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return Admission.fromMap(maps[i]);
    });
  }

  // ดึงรายการ admissions ทั้งหมด (มี pagination)
  Future<List<Admission>> getAllAdmissions({int? limit, int? offset}) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admissions',
      orderBy: 'admission_date_time DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return Admission.fromMap(maps[i]);
    });
  }

  // นับจำนวน admissions ทั้งหมด
  Future<int> getAdmissionCount() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM admissions',
    );
    return result.first['count'] as int;
  }

  // นับจำนวน admissions ที่ยังไม่จำหน่าย
  Future<int> getActiveAdmissionCount() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM admissions WHERE discharge_date_time IS NULL',
    );
    return result.first['count'] as int;
  }

  // อัพเดทข้อมูล admission
  Future<int> updateAdmission(Admission admission) async {
    final db = await _databaseService.database;
    final admissionData = admission.toMap();

    return await db.update(
      'admissions',
      admissionData,
      where: 'admission_id = ?',
      whereArgs: [admission.admissionId],
    );
  }

  // จำหน่ายผู้ป่วย
  Future<int> dischargePatient(
    int admissionId,
    DateTime dischargeDateTime,
    DischargeType dischargeType, {
    String? finalDiagnosis,
  }) async {
    final db = await _databaseService.database;
    
    Map<String, dynamic> updateData = {
      'discharge_date_time': dischargeDateTime.toIso8601String(),
      'discharge_type': dischargeType.name,
    };

    if (finalDiagnosis != null) {
      updateData['final_diagnosis'] = finalDiagnosis;
    }

    return await db.update(
      'admissions',
      updateData,
      where: 'admission_id = ?',
      whereArgs: [admissionId],
    );
  }

  // ลบ admission
  Future<int> deleteAdmission(int admissionId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'admissions',
      where: 'admission_id = ?',
      whereArgs: [admissionId],
    );
  }

  // ตรวจสอบว่า AN ซ้ำหรือไม่
  Future<bool> isANExists(String admissionNumber, {int? excludeAdmissionId}) async {
    final db = await _databaseService.database;
    String whereClause = 'admission_number = ?';
    List<dynamic> whereArgs = [admissionNumber];

    if (excludeAdmissionId != null) {
      whereClause += ' AND admission_id != ?';
      whereArgs.add(excludeAdmissionId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'admissions',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }

  // สร้าง AN อัตโนมัติ
  Future<String> generateNextAN() async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    final year = now.year.toString().substring(2); // ใช้ปี 2 หลัก
    
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT admission_number FROM admissions WHERE admission_number LIKE ? ORDER BY admission_number DESC LIMIT 1',
      ['$year%'],
    );

    if (result.isEmpty) {
      return '${year}0000001'; // AN แรกของปี
    }

    final lastAN = result.first['admission_number'] as String;
    final lastNumber = int.tryParse(lastAN.substring(2)) ?? 0;
    final nextNumber = lastNumber + 1;
    
    return '$year${nextNumber.toString().padLeft(7, '0')}';
  }

  // ค้นหา admissions ด้วยเงื่อนไขหลายอย่าง
  Future<List<Admission>> searchAdmissions({
    String? admissionNumber,
    int? patientId,
    String? ward,
    DateTime? admissionDateFrom,
    DateTime? admissionDateTo,
    DateTime? dischargeDateFrom,
    DateTime? dischargeDateTo,
    bool? isActive,
    int? limit,
    int? offset,
  }) async {
    final db = await _databaseService.database;
    
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (admissionNumber != null && admissionNumber.isNotEmpty) {
      whereConditions.add('admission_number LIKE ?');
      whereArgs.add('%$admissionNumber%');
    }

    if (patientId != null) {
      whereConditions.add('patient_id = ?');
      whereArgs.add(patientId);
    }

    if (ward != null && ward.isNotEmpty) {
      whereConditions.add('ward LIKE ?');
      whereArgs.add('%$ward%');
    }

    if (admissionDateFrom != null) {
      whereConditions.add('admission_date_time >= ?');
      whereArgs.add(admissionDateFrom.toIso8601String());
    }

    if (admissionDateTo != null) {
      whereConditions.add('admission_date_time <= ?');
      whereArgs.add(admissionDateTo.toIso8601String());
    }

    if (dischargeDateFrom != null) {
      whereConditions.add('discharge_date_time >= ?');
      whereArgs.add(dischargeDateFrom.toIso8601String());
    }

    if (dischargeDateTo != null) {
      whereConditions.add('discharge_date_time <= ?');
      whereArgs.add(dischargeDateTo.toIso8601String());
    }

    if (isActive != null) {
      if (isActive) {
        whereConditions.add('discharge_date_time IS NULL');
      } else {
        whereConditions.add('discharge_date_time IS NOT NULL');
      }
    }

    String? whereClause = whereConditions.isNotEmpty 
        ? whereConditions.join(' AND ') 
        : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'admissions',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'admission_date_time DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return Admission.fromMap(maps[i]);
    });
  }

  // ดึงข้อมูล admission พร้อมข้อมูลผู้ป่วย
  Future<Map<String, dynamic>?> getAdmissionWithPatient(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        a.*,
        p.hospital_number,
        p.first_name,
        p.last_name,
        p.date_of_birth,
        p.gender,
        p.national_id,
        p.phone_number
      FROM admissions a
      JOIN patients p ON a.patient_id = p.patient_id
      WHERE a.admission_id = ?
    ''', [admissionId]);

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // สถิติ admissions ตามช่วงเวลา
  Future<Map<String, int>> getAdmissionStatsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    
    final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM admissions 
      WHERE admission_date_time BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final dischargedResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM admissions 
      WHERE admission_date_time BETWEEN ? AND ?
      AND discharge_date_time IS NOT NULL
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    final activeResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM admissions 
      WHERE admission_date_time BETWEEN ? AND ?
      AND discharge_date_time IS NULL
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return {
      'total': totalResult.first['count'] as int,
      'discharged': dischargedResult.first['count'] as int,
      'active': activeResult.first['count'] as int,
    };
  }
}
