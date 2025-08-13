import '../services/database_service.dart';
import '../models/vital_signs.dart';

class VitalSignsRepository {
  final DatabaseService _databaseService;

  VitalSignsRepository(this._databaseService);

  // สร้าง vital signs ใหม่
  Future<int> createVitalSigns(VitalSigns vitalSigns) async {
    final db = await _databaseService.database;
    return await db.insert('vital_signs', vitalSigns.toMap());
  }

  // ค้นหา vital signs ตาม ID
  Future<VitalSigns?> getVitalSignsById(int vitalSignId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vital_signs',
      where: 'vital_sign_id = ?',
      whereArgs: [vitalSignId],
    );

    if (maps.isNotEmpty) {
      return VitalSigns.fromMap(maps.first);
    }
    return null;
  }

  // ดึงรายการ vital signs ของ admission
  Future<List<VitalSigns>> getVitalSignsByAdmissionId(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vital_signs',
      where: 'admission_id = ?',
      whereArgs: [admissionId],
      orderBy: 'recorded_at DESC',
    );

    return List.generate(maps.length, (i) {
      return VitalSigns.fromMap(maps[i]);
    });
  }

  // ดึง vital signs ล่าสุดของ admission
  Future<VitalSigns?> getLatestVitalSignsByAdmissionId(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vital_signs',
      where: 'admission_id = ?',
      whereArgs: [admissionId],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return VitalSigns.fromMap(maps.first);
    }
    return null;
  }

  // ดึง vital signs ในช่วงเวลาที่กำหนด
  Future<List<VitalSigns>> getVitalSignsByDateRange(
    int admissionId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vital_signs',
      where: 'admission_id = ? AND recorded_at BETWEEN ? AND ?',
      whereArgs: [
        admissionId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'recorded_at ASC',
    );

    return List.generate(maps.length, (i) {
      return VitalSigns.fromMap(maps[i]);
    });
  }

  // ดึง vital signs วันนี้
  Future<List<VitalSigns>> getTodayVitalSigns(int admissionId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return await getVitalSignsByDateRange(admissionId, startOfDay, endOfDay);
  }

  // อัพเดท vital signs
  Future<int> updateVitalSigns(VitalSigns vitalSigns) async {
    final db = await _databaseService.database;
    return await db.update(
      'vital_signs',
      vitalSigns.toMap(),
      where: 'vital_sign_id = ?',
      whereArgs: [vitalSigns.vitalSignId],
    );
  }

  // ลบ vital signs
  Future<int> deleteVitalSigns(int vitalSignId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'vital_signs',
      where: 'vital_sign_id = ?',
      whereArgs: [vitalSignId],
    );
  }

  // นับจำนวน vital signs ของ admission
  Future<int> getVitalSignsCount(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vital_signs WHERE admission_id = ?',
      [admissionId],
    );
    return result.first['count'] as int;
  }

  // ค้นหา vital signs ที่มีค่าผิดปกติ
  Future<List<VitalSigns>> getAbnormalVitalSigns(int admissionId) async {
    final db = await _databaseService.database;
    // ใช้เงื่อนไขค่าปกติตามมาตรฐาน
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM vital_signs 
      WHERE admission_id = ? 
      AND (
        body_temperature < 36.0 OR body_temperature > 37.5
        OR pulse_rate < 60 OR pulse_rate > 100
        OR respiratory_rate < 12 OR respiratory_rate > 20
        OR bp_systolic < 90 OR bp_systolic > 140
        OR bp_diastolic < 60 OR bp_diastolic > 90
        OR oxygen_saturation < 95
      )
      ORDER BY recorded_at DESC
    ''', [admissionId]);

    return List.generate(maps.length, (i) {
      return VitalSigns.fromMap(maps[i]);
    });
  }

  // สร้างกราฟข้อมูล vital signs สำหรับแสดงผล
  Future<Map<String, List<Map<String, dynamic>>>> getVitalSignsChartData(
    int admissionId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final vitalSigns = await getVitalSignsByDateRange(admissionId, startDate, endDate);
    
    Map<String, List<Map<String, dynamic>>> chartData = {
      'temperature': [],
      'pulseRate': [],
      'bloodPressure': [],
      'respiratoryRate': [],
      'oxygenSaturation': [],
    };

    for (var vital in vitalSigns) {
      final timestamp = vital.recordedAt.millisecondsSinceEpoch;
      
      if (vital.bodyTemperature != null) {
        chartData['temperature']!.add({
          'x': timestamp,
          'y': vital.bodyTemperature,
        });
      }
      
      if (vital.pulseRate != null) {
        chartData['pulseRate']!.add({
          'x': timestamp,
          'y': vital.pulseRate,
        });
      }
      
      if (vital.bpSystolic != null && vital.bpDiastolic != null) {
        chartData['bloodPressure']!.add({
          'x': timestamp,
          'systolic': vital.bpSystolic,
          'diastolic': vital.bpDiastolic,
        });
      }
      
      if (vital.respiratoryRate != null) {
        chartData['respiratoryRate']!.add({
          'x': timestamp,
          'y': vital.respiratoryRate,
        });
      }
      
      if (vital.oxygenSaturation != null) {
        chartData['oxygenSaturation']!.add({
          'x': timestamp,
          'y': vital.oxygenSaturation,
        });
      }
    }

    return chartData;
  }

  // ดึงสถิติ vital signs
  Future<Map<String, dynamic>> getVitalSignsStatistics(
    int admissionId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_records,
        AVG(body_temperature) as avg_temperature,
        MIN(body_temperature) as min_temperature,
        MAX(body_temperature) as max_temperature,
        AVG(pulse_rate) as avg_pulse_rate,
        MIN(pulse_rate) as min_pulse_rate,
        MAX(pulse_rate) as max_pulse_rate,
        AVG(bp_systolic) as avg_systolic,
        MIN(bp_systolic) as min_systolic,
        MAX(bp_systolic) as max_systolic,
        AVG(bp_diastolic) as avg_diastolic,
        MIN(bp_diastolic) as min_diastolic,
        MAX(bp_diastolic) as max_diastolic,
        AVG(respiratory_rate) as avg_respiratory_rate,
        MIN(respiratory_rate) as min_respiratory_rate,
        MAX(respiratory_rate) as max_respiratory_rate,
        AVG(oxygen_saturation) as avg_oxygen_saturation,
        MIN(oxygen_saturation) as min_oxygen_saturation,
        MAX(oxygen_saturation) as max_oxygen_saturation
      FROM vital_signs 
      WHERE admission_id = ? 
      AND recorded_at BETWEEN ? AND ?
    ''', [
      admissionId,
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);

    return result.first;
  }

  // ดึงแนวโน้ม vital signs (เปรียบเทียบกับค่าก่อนหน้า)
  Future<Map<String, String>> getVitalSignsTrends(int admissionId) async {
    final vitalSigns = await getVitalSignsByAdmissionId(admissionId);
    
    if (vitalSigns.length < 2) {
      return {};
    }

    final latest = vitalSigns.first;
    final previous = vitalSigns[1];
    
    Map<String, String> trends = {};

    if (latest.bodyTemperature != null && previous.bodyTemperature != null) {
      if (latest.bodyTemperature! > previous.bodyTemperature!) {
        trends['temperature'] = 'increasing';
      } else if (latest.bodyTemperature! < previous.bodyTemperature!) {
        trends['temperature'] = 'decreasing';
      } else {
        trends['temperature'] = 'stable';
      }
    }

    if (latest.pulseRate != null && previous.pulseRate != null) {
      if (latest.pulseRate! > previous.pulseRate!) {
        trends['pulseRate'] = 'increasing';
      } else if (latest.pulseRate! < previous.pulseRate!) {
        trends['pulseRate'] = 'decreasing';
      } else {
        trends['pulseRate'] = 'stable';
      }
    }

    if (latest.bpSystolic != null && previous.bpSystolic != null) {
      if (latest.bpSystolic! > previous.bpSystolic!) {
        trends['bloodPressure'] = 'increasing';
      } else if (latest.bpSystolic! < previous.bpSystolic!) {
        trends['bloodPressure'] = 'decreasing';
      } else {
        trends['bloodPressure'] = 'stable';
      }
    }

    return trends;
  }
}
