import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact_model.dart';

class FirebaseContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'contacts';

  Future<List<ContactModel>> getAllContacts() async {
    final snapshot = await _firestore.collection(_collection).orderBy('name').get();
    return snapshot.docs.map((doc) => ContactModel.fromFirestore(doc.data())).toList();
  }

  Future<ContactModel?> getContactById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return ContactModel.fromFirestore(doc.data()!);
  }

  Future<void> addContact(ContactModel contact) async {
    await _firestore.collection(_collection).doc(contact.id).set(contact.toFirestore());
  }

  Future<void> updateContact(ContactModel contact) async {
    await _firestore.collection(_collection).doc(contact.id).update(contact.toFirestore());
  }

  Future<void> deleteContact(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
