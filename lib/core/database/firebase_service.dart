import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
  }

  static FirebaseFirestore get instance {
    if (_firestore == null) {
      throw Exception('FirebaseService not initialized');
    }
    return _firestore!;
  }
}
