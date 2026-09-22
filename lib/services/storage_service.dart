import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/structure_record.dart';

class StorageService {
  static const String _storageKey = 'italika_structure_records';

  Future<List<StructureRecord>> getRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => StructureRecord.fromJson(item)).toList()
        ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveRecord(StructureRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentRecords = await getRecords();
      currentRecords.insert(0, record);
      
      final encoded = jsonEncode(currentRecords.map((r) => r.toJson()).toList());
      return await prefs.setString(_storageKey, encoded);
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentRecords = await getRecords();
      currentRecords.removeWhere((r) => r.id == id);
      
      final encoded = jsonEncode(currentRecords.map((r) => r.toJson()).toList());
      return await prefs.setString(_storageKey, encoded);
    } catch (e) {
      return false;
    }
  }
}
