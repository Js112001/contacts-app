import '../entities/contact_entity.dart';

abstract class ContactRepository {
  Future<List<ContactEntity>> getAllContacts();
  Future<ContactEntity?> getContactById(String id);
  Future<void> addContact(ContactEntity contact);
  Future<void> updateContact(ContactEntity contact);
  Future<void> deleteContact(String id);
  Future<void> syncContacts();
}
