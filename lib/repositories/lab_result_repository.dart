import '../models/lab_result.dart';
import '../services/database_service.dart';

class LabResultRepository {
  final DatabaseService _databaseService;

  LabResultRepository(this._databaseService);

  // สร้างผล Lab ใหม่
  Future<int> createLabResult(LabResult labResult) async {
    final db = await _databaseService.database;
    return await db.insert('lab_results', labResult.toMap());
  }

  // ดึงผล Lab ทั้งหมดของ admission
  Future<List<LabResult>> getLabResultsByAdmissionId(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lab_results',
      where: 'admission_id = ?',
      whereArgs: [admissionId],
      orderBy: 'result_date_time DESC, specimen_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return LabResult.fromMap(maps[i]);
    });
  }

  // ดึงผล Lab ตาม ID
  Future<LabResult?> getLabResultById(int resultId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lab_results',
      where: 'result_id = ?',
      whereArgs: [resultId],
    );

    if (maps.isNotEmpty) {
      return LabResult.fromMap(maps.first);
    }
    return null;
  }

  // ดึงผล Lab ตาม test name
  Future<List<LabResult>> getLabResultsByTestName(int admissionId, String testName) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lab_results',
      where: 'admission_id = ? AND test_name = ?',
      whereArgs: [admissionId, testName],
      orderBy: 'result_date_time DESC, specimen_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return LabResult.fromMap(maps[i]);
    });
  }

  // ดึงผล Lab ตามช่วงวันที่
  Future<List<LabResult>> getLabResultsByDateRange(
    int admissionId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lab_results',
      where: 'admission_id = ? AND result_date_time BETWEEN ? AND ?',
      whereArgs: [
        admissionId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'result_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return LabResult.fromMap(maps[i]);
    });
  }

  // ดึงชื่อการตรวจที่ไม่ซ้ำกัน
  Future<List<String>> getUniqueTestNames(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lab_results',
      columns: ['DISTINCT test_name'],
      where: 'admission_id = ?',
      whereArgs: [admissionId],
      orderBy: 'test_name',
    );

    return maps.map((map) => map['test_name'] as String).toList();
  }

  // ดึงผล Lab ล่าสุดของแต่ละการตรวจ
  Future<List<LabResult>> getLatestLabResults(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM lab_results 
      WHERE admission_id = ? AND result_id IN (
        SELECT result_id FROM lab_results lr1
        WHERE lr1.admission_id = ? AND lr1.test_name = lab_results.test_name
        ORDER BY lr1.result_date_time DESC, lr1.specimen_date_time DESC
        LIMIT 1
      )
      ORDER BY test_name
    ''', [admissionId, admissionId]);

    return List.generate(maps.length, (i) {
      return LabResult.fromMap(maps[i]);
    });
  }

  // อัพเดทผล Lab
  Future<int> updateLabResult(LabResult labResult) async {
    final db = await _databaseService.database;
    return await db.update(
      'lab_results',
      labResult.toMap(),
      where: 'result_id = ?',
      whereArgs: [labResult.resultId],
    );
  }

  // ลบผล Lab
  Future<int> deleteLabResult(int resultId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'lab_results',
      where: 'result_id = ?',
      whereArgs: [resultId],
    );
  }

  // ค้นหาผล Lab
  Future<List<LabResult>> searchLabResults(int admissionId, String searchText) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lab_results',
      where: 'admission_id = ? AND (test_name LIKE ? OR note LIKE ?)',
      whereArgs: [admissionId, '%$searchText%', '%$searchText%'],
      orderBy: 'result_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return LabResult.fromMap(maps[i]);
    });
  }

  // นับจำนวนผล Lab
  Future<int> countLabResults(int admissionId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lab_results WHERE admission_id = ?',
      [admissionId],
    );
    return result.first['count'] as int;
  }

  // ดึงผล Lab ที่รอผล (ไม่มี result_date_time)
  Future<List<LabResult>> getPendingLabResults(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lab_results',
      where: 'admission_id = ? AND result_date_time IS NULL',
      whereArgs: [admissionId],
      orderBy: 'specimen_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return LabResult.fromMap(maps[i]);
    });
  }

  // ดึงประวัติผล Lab ของการตรวจเดียวกัน
  Future<List<LabResult>> getLabHistoryByTestName(
    int admissionId,
    String testName, {
    int limit = 10,
  }) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lab_results',
      where: 'admission_id = ? AND test_name = ?',
      whereArgs: [admissionId, testName],
      orderBy: 'result_date_time DESC, specimen_date_time DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return LabResult.fromMap(maps[i]);
    });
  }

  // ดึงผล Lab ตามประเภท (CBC, Chemistry, etc.)
  Future<List<LabResult>> getLabResultsByCategory(int admissionId, String category) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lab_results',
      where: 'admission_id = ? AND test_name LIKE ?',
      whereArgs: [admissionId, '%$category%'],
      orderBy: 'result_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return LabResult.fromMap(maps[i]);
    });
  }
}
