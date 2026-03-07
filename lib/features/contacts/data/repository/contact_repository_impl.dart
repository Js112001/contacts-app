import 'package:flutter/foundation.dart';
import '../../domain/entities/contact_entity.dart';
import '../../domain/repository/contact_repository.dart';
import '../services/firebase_contact_service.dart';
import '../services/local_database_service.dart';

class ContactRepositoryImpl implements ContactRepository {
  final FirebaseContactService _firebaseService;
  final LocalDatabaseService _localService;

  ContactRepositoryImpl(this._firebaseService, this._localService);

  @override
  Future<List<ContactEntity>> getAllContacts() async {
    try {
      final firebaseContacts = await _firebaseService.getAllContacts();
      for (var contact in firebaseContacts) {
        await _localService.insertContact(contact);
      }
    } catch (e) {
      debugPrint('Firebase sync failed: $e');
    }
    final localContacts = await _localService.getAllContacts();
    return localContacts.map((model) => ContactEntity.fromModel(model)).toList();
  }

  @override
  Future<ContactEntity?> getContactById(String id) async {
    final contact = await _localService.getContactById(id);
    return contact != null ? ContactEntity.fromModel(contact) : null;
  }

  @override
  Future<void> addContact(ContactEntity contact) async {
    final model = contact.toModel();
    
    // Check for duplicates
    final existingContacts = await _localService.getAllContacts();
    final isDuplicate = existingContacts.any((c) => 
      (c.name.toLowerCase() == model.name.toLowerCase() || c.phone == model.phone) && c.id != model.id
    );
    
    if (isDuplicate) {
      throw Exception('Contact with same name or phone already exists');
    }
    
    await _localService.insertContact(model);
    try {
      await _firebaseService.addContact(model);
      await _localService.markAsSynced(contact.id);
    } catch (e) {
      debugPrint('Firebase add failed, will sync later: $e');
    }
  }

  @override
  Future<void> updateContact(ContactEntity contact) async {
    final model = contact.toModel();
    
    // Check for duplicates (excluding current contact)
    final existingContacts = await _localService.getAllContacts();
    final isDuplicate = existingContacts.any((c) => 
      (c.name.toLowerCase() == model.name.toLowerCase() || c.phone == model.phone) && c.id != model.id
    );
    
    if (isDuplicate) {
      throw Exception('Contact with same name or phone already exists');
    }
    
    await _localService.updateContact(model);
    try {
      await _firebaseService.updateContact(model);
      await _localService.markAsSynced(contact.id);
    } catch (e) {
      debugPrint('Firebase update failed, will sync later: $e');
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    await _localService.deleteContact(id);
    try {
      await _firebaseService.deleteContact(id);
    } catch (e) {
      debugPrint('Firebase delete failed: $e');
    }
  }

  @override
  Future<void> syncContacts() async {
    try {
      final firestoreSnapshot = await _firebaseService.getAllContacts();
      final isFirestoreEmpty = firestoreSnapshot.isEmpty;
      
      if (isFirestoreEmpty) {
        final allLocalContacts = await _localService.getAllContacts();
        for (var contact in allLocalContacts) {
          try {
            await _firebaseService.addContact(contact);
            await _localService.markAsSynced(contact.id);
          } catch (e) {
            debugPrint('Failed to sync contact ${contact.id}: $e');
          }
        }
      } else {
        final unsyncedContacts = await _localService.getUnsyncedContacts();
        for (var contact in unsyncedContacts) {
          try {
            await _firebaseService.addContact(contact);
            await _localService.markAsSynced(contact.id);
          } catch (e) {
            debugPrint('Failed to sync contact ${contact.id}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Sync operation failed: $e');
      rethrow;
    }
  }
}
