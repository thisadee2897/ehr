import '../models/assessment_form.dart';
import '../models/assessment_score.dart';
import '../services/database_service.dart';

class AssessmentRepository {
  final DatabaseService _databaseService;

  AssessmentRepository(this._databaseService);

  // ============= Assessment Forms =============

  // สร้าง Assessment Form ใหม่
  Future<int> createAssessmentForm(AssessmentForm assessmentForm) async {
    final db = await _databaseService.database;
    return await db.insert('assessment_forms', assessmentForm.toMap());
  }

  // ดึง Assessment Forms ทั้งหมด
  Future<List<AssessmentForm>> getAllAssessmentForms() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_forms',
      orderBy: 'form_name',
    );

    return List.generate(maps.length, (i) {
      return AssessmentForm.fromMap(maps[i]);
    });
  }

  // ดึง Assessment Form ตาม ID
  Future<AssessmentForm?> getAssessmentFormById(int formId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_forms',
      where: 'form_id = ?',
      whereArgs: [formId],
    );

    if (maps.isNotEmpty) {
      return AssessmentForm.fromMap(maps.first);
    }
    return null;
  }

  // ดึง Assessment Form ตามชื่อ
  Future<AssessmentForm?> getAssessmentFormByName(String formName) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_forms',
      where: 'form_name = ?',
      whereArgs: [formName],
    );

    if (maps.isNotEmpty) {
      return AssessmentForm.fromMap(maps.first);
    }
    return null;
  }

  // อัพเดท Assessment Form
  Future<int> updateAssessmentForm(AssessmentForm assessmentForm) async {
    final db = await _databaseService.database;
    return await db.update(
      'assessment_forms',
      assessmentForm.toMap(),
      where: 'form_id = ?',
      whereArgs: [assessmentForm.formId],
    );
  }

  // ลบ Assessment Form
  Future<int> deleteAssessmentForm(int formId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'assessment_forms',
      where: 'form_id = ?',
      whereArgs: [formId],
    );
  }

  // ============= Assessment Scores =============

  // สร้าง Assessment Score ใหม่
  Future<int> createAssessmentScore(AssessmentScore assessmentScore) async {
    final db = await _databaseService.database;
    return await db.insert('assessment_scores', assessmentScore.toMap());
  }

  // ดึง Assessment Scores ทั้งหมดของ admission
  Future<List<AssessmentScore>> getAssessmentScoresByAdmissionId(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_scores',
      where: 'admission_id = ?',
      whereArgs: [admissionId],
      orderBy: 'assessment_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return AssessmentScore.fromMap(maps[i]);
    });
  }

  // ดึง Assessment Score ตาม ID
  Future<AssessmentScore?> getAssessmentScoreById(int scoreId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_scores',
      where: 'score_id = ?',
      whereArgs: [scoreId],
    );

    if (maps.isNotEmpty) {
      return AssessmentScore.fromMap(maps.first);
    }
    return null;
  }

  // ดึง Assessment Scores ตาม form
  Future<List<AssessmentScore>> getAssessmentScoresByForm(int admissionId, int formId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_scores',
      where: 'admission_id = ? AND form_id = ?',
      whereArgs: [admissionId, formId],
      orderBy: 'assessment_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return AssessmentScore.fromMap(maps[i]);
    });
  }

  // ดึง Assessment Score ล่าสุดของแต่ละ form
  Future<List<AssessmentScore>> getLatestAssessmentScores(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM assessment_scores 
      WHERE admission_id = ? AND score_id IN (
        SELECT score_id FROM assessment_scores as1
        WHERE as1.admission_id = ? AND as1.form_id = assessment_scores.form_id
        ORDER BY as1.assessment_date_time DESC
        LIMIT 1
      )
      ORDER BY assessment_date_time DESC
    ''', [admissionId, admissionId]);

    return List.generate(maps.length, (i) {
      return AssessmentScore.fromMap(maps[i]);
    });
  }

  // ดึง Assessment Scores ตาม assessor (provider)
  Future<List<AssessmentScore>> getAssessmentScoresByAssessor(
    int admissionId,
    int assessorProviderId,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_scores',
      where: 'admission_id = ? AND assessor_provider_id = ?',
      whereArgs: [admissionId, assessorProviderId],
      orderBy: 'assessment_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return AssessmentScore.fromMap(maps[i]);
    });
  }

  // ดึง Assessment Scores ตามช่วงวันที่
  Future<List<AssessmentScore>> getAssessmentScoresByDateRange(
    int admissionId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_scores',
      where: 'admission_id = ? AND assessment_date_time BETWEEN ? AND ?',
      whereArgs: [
        admissionId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'assessment_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return AssessmentScore.fromMap(maps[i]);
    });
  }

  // อัพเดท Assessment Score
  Future<int> updateAssessmentScore(AssessmentScore assessmentScore) async {
    final db = await _databaseService.database;
    return await db.update(
      'assessment_scores',
      assessmentScore.toMap(),
      where: 'score_id = ?',
      whereArgs: [assessmentScore.scoreId],
    );
  }

  // ลบ Assessment Score
  Future<int> deleteAssessmentScore(int scoreId) async {
    final db = await _databaseService.database;
    return await db.delete(
      'assessment_scores',
      where: 'score_id = ?',
      whereArgs: [scoreId],
    );
  }

  // ============= Advanced Features =============

  // ดึงประวัติการประเมินของ form เดียวกัน
  Future<List<AssessmentScore>> getAssessmentHistory(
    int admissionId,
    int formId, {
    int limit = 10,
  }) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_scores',
      where: 'admission_id = ? AND form_id = ?',
      whereArgs: [admissionId, formId],
      orderBy: 'assessment_date_time DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return AssessmentScore.fromMap(maps[i]);
    });
  }

  // นับจำนวนการประเมินตาม form
  Future<int> countAssessmentsByForm(int admissionId, int formId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM assessment_scores WHERE admission_id = ? AND form_id = ?',
      [admissionId, formId],
    );
    return result.first['count'] as int;
  }

  // ดึง Assessment Scores พร้อม form details
  Future<List<Map<String, dynamic>>> getAssessmentScoresWithFormDetails(int admissionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        s.*,
        f.form_name,
        f.form_details
      FROM assessment_scores s
      INNER JOIN assessment_forms f ON s.form_id = f.form_id
      WHERE s.admission_id = ?
      ORDER BY s.assessment_date_time DESC
    ''', [admissionId]);

    return maps;
  }

  // ค้นหา Assessment Scores ตาม interpretation
  Future<List<AssessmentScore>> searchAssessmentsByInterpretation(
    int admissionId,
    String searchText,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_scores',
      where: 'admission_id = ? AND interpretation LIKE ?',
      whereArgs: [admissionId, '%$searchText%'],
      orderBy: 'assessment_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return AssessmentScore.fromMap(maps[i]);
    });
  }

  // ดึง Assessment Scores ที่มีความเสี่ยงสูง (score >= threshold)
  Future<List<AssessmentScore>> getHighRiskAssessments(
    int admissionId,
    int scoreThreshold,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessment_scores',
      where: 'admission_id = ? AND total_score >= ?',
      whereArgs: [admissionId, scoreThreshold],
      orderBy: 'total_score DESC, assessment_date_time DESC',
    );

    return List.generate(maps.length, (i) {
      return AssessmentScore.fromMap(maps[i]);
    });
  }

  // สถิติการประเมิน
  Future<Map<String, dynamic>> getAssessmentStatistics(int admissionId) async {
    final db = await _databaseService.database;
    
    // นับจำนวนการประเมินทั้งหมด
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM assessment_scores WHERE admission_id = ?',
      [admissionId],
    );
    
    // นับจำนวน forms ที่แตกต่างกัน
    final uniqueFormsResult = await db.rawQuery(
      'SELECT COUNT(DISTINCT form_id) as unique_forms FROM assessment_scores WHERE admission_id = ?',
      [admissionId],
    );
    
    // ค่าเฉลี่ยของ total_score
    final avgScoreResult = await db.rawQuery(
      'SELECT AVG(total_score) as avg_score FROM assessment_scores WHERE admission_id = ?',
      [admissionId],
    );

    return {
      'total_assessments': totalResult.first['total'] as int,
      'unique_forms': uniqueFormsResult.first['unique_forms'] as int,
      'average_score': avgScoreResult.first['avg_score'] as double? ?? 0.0,
    };
  }
}
