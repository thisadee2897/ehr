import '../models/doctor_order.dart';
import '../services/database_service.dart';

class DoctorOrderRepository {
  final DatabaseService _databaseService;

  DoctorOrderRepository(this._databaseService);

  // สร้างคำสั่งแพทย์ใหม่
  Future<int> createDoctorOrder(DoctorOrder doctorOrder) async {
    final db = await _databaseService.database;
    return await db.insert('doctor_orders', doctorOrder.toMap());
  }

  // ดึงคำสั่งแพทย์ทั้งหมดของ admission
  Future<List<DoctorOrder>> getDoctorOrdersByAdmissionId(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_orders',
      where: 'admission_id = ?',
      whereArgs: [admissionId],
      orderBy: 'order_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return DoctorOrder.fromMap(maps[i]);
    });
  }

  // ดึงคำสั่งแพทย์ตาม status
  Future<List<DoctorOrder>> getDoctorOrdersByStatus(int admissionId, OrderStatus status) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_orders',
      where: 'admission_id = ? AND status = ?',
      whereArgs: [admissionId, status.name],
      orderBy: 'order_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return DoctorOrder.fromMap(maps[i]);
    });
  }

  // ดึงคำสั่งแพทย์ตาม type
  Future<List<DoctorOrder>> getDoctorOrdersByType(int admissionId, OrderType orderType) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_orders',
      where: 'admission_id = ? AND order_type = ?',
      whereArgs: [admissionId, orderType.name],
      orderBy: 'order_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return DoctorOrder.fromMap(maps[i]);
    });
  }

  // ดึงคำสั่งแพทย์ตาม ID
  Future<DoctorOrder?> getDoctorOrderById(int orderId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_orders',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    if (maps.isNotEmpty) {
      return DoctorOrder.fromMap(maps.first);
    }
    return null;
  }

  // อัพเดทคำสั่งแพทย์
  Future<int> updateDoctorOrder(DoctorOrder doctorOrder) async {
    final db = await _databaseService.database;
    return await db.update(
      'doctor_orders',
      doctorOrder.toMap(),
      where: 'order_id = ?',
      whereArgs: [doctorOrder.orderId],
    );
  }

  // อัพเดท status ของคำสั่งแพทย์
  Future<int> updateDoctorOrderStatus(int orderId, OrderStatus status) async {
    final db = await _databaseService.database;
    return await db.update(
      'doctor_orders',
      {'status': status.name},
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  // ลบคำสั่งแพทย์
  Future<int> deleteDoctorOrder(int orderId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'doctor_orders',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  // ดึงคำสั่งแพทย์แบบ continuous ที่ยังใช้งานอยู่
  Future<List<DoctorOrder>> getActiveContinuousOrders(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_orders',
      where: 'admission_id = ? AND is_continuous = 1 AND status = ?',
      whereArgs: [admissionId, OrderStatus.active.name],
      orderBy: 'order_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return DoctorOrder.fromMap(maps[i]);
    });
  }

  // ค้นหาคำสั่งแพทย์
  Future<List<DoctorOrder>> searchDoctorOrders(int admissionId, String searchText) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_orders',
      where: 'admission_id = ? AND order_text LIKE ?',
      whereArgs: [admissionId, '%$searchText%'],
      orderBy: 'order_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return DoctorOrder.fromMap(maps[i]);
    });
  }

  // นับจำนวนคำสั่งแพทย์ตาม status
  Future<int> countDoctorOrdersByStatus(int admissionId, OrderStatus status) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM doctor_orders WHERE admission_id = ? AND status = ?',
      [admissionId, status.name],
    );
    return result.first['count'] as int;
  }
}
