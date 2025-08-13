import '../models/progress_note.dart';
import '../services/database_service.dart';

class ProgressNoteRepository {
  final DatabaseService _databaseService;

  ProgressNoteRepository(this._databaseService);

  // สร้าง Progress Note ใหม่
  Future<int> createProgressNote(ProgressNote progressNote) async {
    final db = await _databaseService.database;
    return await db.insert('progress_notes', progressNote.toMap());
  }

  // ดึง Progress Notes ทั้งหมดของ admission
  Future<List<ProgressNote>> getProgressNotesByAdmissionId(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress_notes',
      where: 'admission_id = ?',
      whereArgs: [admissionId],
      orderBy: 'note_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return ProgressNote.fromMap(maps[i]);
    });
  }

  // ดึง Progress Note ตาม ID
  Future<ProgressNote?> getProgressNoteById(int noteId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress_notes',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );

    if (maps.isNotEmpty) {
      return ProgressNote.fromMap(maps.first);
    }
    return null;
  }

  // ดึง Progress Notes ตาม problem
  Future<List<ProgressNote>> getProgressNotesByProblem(int admissionId, String problem) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress_notes',
      where: 'admission_id = ? AND problem LIKE ?',
      whereArgs: [admissionId, '%$problem%'],
      orderBy: 'note_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return ProgressNote.fromMap(maps[i]);
    });
  }

  // ดึง Progress Notes ตาม author (provider)
  Future<List<ProgressNote>> getProgressNotesByAuthor(int admissionId, int authorProviderId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress_notes',
      where: 'admission_id = ? AND author_provider_id = ?',
      whereArgs: [admissionId, authorProviderId],
      orderBy: 'note_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return ProgressNote.fromMap(maps[i]);
    });
  }

  // ดึง Progress Notes ตามช่วงวันที่
  Future<List<ProgressNote>> getProgressNotesByDateRange(
    int admissionId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress_notes',
      where: 'admission_id = ? AND note_date_time BETWEEN ? AND ?',
      whereArgs: [
        admissionId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'note_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return ProgressNote.fromMap(maps[i]);
    });
  }

  // อัพเดท Progress Note
  Future<int> updateProgressNote(ProgressNote progressNote) async {
    final db = await _databaseService.database;
    return await db.update(
      'progress_notes',
      progressNote.toMap(),
      where: 'note_id = ?',
      whereArgs: [progressNote.noteId],
    );
  }

  // ลบ Progress Note
  Future<int> deleteProgressNote(int noteId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'progress_notes',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }

  // ค้นหา Progress Notes
  Future<List<ProgressNote>> searchProgressNotes(int admissionId, String searchText) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress_notes',
      where: '''admission_id = ? AND (
        problem LIKE ? OR 
        subjective LIKE ? OR 
        objective LIKE ? OR 
        assessment LIKE ? OR 
        plan LIKE ?
      )''',
      whereArgs: [
        admissionId,
        '%$searchText%',
        '%$searchText%',
        '%$searchText%',
        '%$searchText%',
        '%$searchText%',
      ],
      orderBy: 'note_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return ProgressNote.fromMap(maps[i]);
    });
  }

  // นับจำนวน Progress Notes
  Future<int> countProgressNotes(int admissionId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM progress_notes WHERE admission_id = ?',
      [admissionId],
    );
    return result.first['count'] as int;
  }

  // ดึง Progress Notes ล่าสุด
  Future<List<ProgressNote>> getRecentProgressNotes(int admissionId, {int limit = 10}) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress_notes',
      where: 'admission_id = ?',
      whereArgs: [admissionId],
      orderBy: 'note_date_time DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return ProgressNote.fromMap(maps[i]);
    });
  }

  // ดึง problems ที่ไม่ซ้ำกัน
  Future<List<String>> getUniqueProblems(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress_notes',
      columns: ['DISTINCT problem'],
      where: 'admission_id = ? AND problem IS NOT NULL AND problem != ""',
      whereArgs: [admissionId],
      orderBy: 'problem',
    );

    return maps.map((map) => map['problem'] as String).toList();
  }
}
