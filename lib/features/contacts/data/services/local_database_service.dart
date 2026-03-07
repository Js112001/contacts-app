import 'package:sqflite/sqflite.dart';
import '../../../../core/database/sqlite_database.dart';
import '../models/contact_model.dart';

class LocalDatabaseService {
  Future<List<ContactModel>> getAllContacts() async {
    final db = await SQLiteDatabase.instance;
    final result = await db.query('contacts', orderBy: 'name ASC');
    return result.map((json) => ContactModel.fromJson(json)).toList();
  }

  Future<ContactModel?> getContactById(String id) async {
    final db = await SQLiteDatabase.instance;
    final result = await db.query('contacts', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return ContactModel.fromJson(result.first);
  }

  Future<void> insertContact(ContactModel contact) async {
    final db = await SQLiteDatabase.instance;
    await db.insert('contacts', contact.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateContact(ContactModel contact) async {
    final db = await SQLiteDatabase.instance;
    final updateData = contact.toJson();
    updateData['isSynced'] = 0; // Mark as unsynced after update
    await db.update('contacts', updateData, where: 'id = ?', whereArgs: [contact.id]);
  }

  Future<void> deleteContact(String id) async {
    final db = await SQLiteDatabase.instance;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ContactModel>> getUnsyncedContacts() async {
    final db = await SQLiteDatabase.instance;
    final result = await db.query('contacts', where: 'isSynced = ?', whereArgs: [0]);
    return result.map((json) => ContactModel.fromJson(json)).toList();
  }

  Future<void> markAsSynced(String id) async {
    final db = await SQLiteDatabase.instance;
    await db.update('contacts', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
