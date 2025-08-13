import '../models/healthcare_provider.dart';
import '../services/database_service.dart';

class HealthcareProviderRepository {
  final DatabaseService _databaseService;

  HealthcareProviderRepository(this._databaseService);

  Future<List<HealthcareProvider>> getAllHealthcareProviders() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('healthcare_providers');
    
    return List.generate(maps.length, (i) {
      return HealthcareProvider.fromJson(maps[i]);
    });
  }

  Future<HealthcareProvider?> getHealthcareProviderById(int providerId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'healthcare_providers',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );

    if (maps.isNotEmpty) {
      return HealthcareProvider.fromJson(maps.first);
    }
    return null;
  }

  Future<List<HealthcareProvider>> getHealthcareProvidersByType(ProviderType type) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'healthcare_providers',
      where: 'provider_type = ?',
      whereArgs: [type.toString().split('.').last],
    );
    
    return List.generate(maps.length, (i) {
      return HealthcareProvider.fromJson(maps[i]);
    });
  }

  Future<int> insertHealthcareProvider(HealthcareProvider provider) async {
    final db = await _databaseService.database;
    return await db.insert(
      'healthcare_providers',
      provider.toJson()..remove('provider_id'), // Remove ID for auto-increment
    );
  }

  Future<void> updateHealthcareProvider(HealthcareProvider provider) async {
    final db = await _databaseService.database;
    await db.update(
      'healthcare_providers',
      provider.toJson(),
      where: 'provider_id = ?',
      whereArgs: [provider.providerId],
    );
  }

  Future<void> deleteHealthcareProvider(int providerId) async {
    final db = await _databaseService.database;
    await db.delete(
      'healthcare_providers',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
  }

  Future<List<HealthcareProvider>> searchHealthcareProviders(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'healthcare_providers',
      where: 'first_name LIKE ? OR last_name LIKE ? OR license_number LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    
    return List.generate(maps.length, (i) {
      return HealthcareProvider.fromJson(maps[i]);
    });
  }
}
