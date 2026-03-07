import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final contactsRef = firestore.collection('contacts');

  final dummyContacts = [
    {
      'id': '1',
      'name': 'John Doe',
      'phone': '+1234567890',
      'email': 'john.doe@example.com',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'phone': '+1234567891',
      'email': 'jane.smith@example.com',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    },
    {
      'id': '3',
      'name': 'Bob Johnson',
      'phone': '+1234567892',
      'email': 'bob.johnson@example.com',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    },
    {
      'id': '4',
      'name': 'Alice Williams',
      'phone': '+1234567893',
      'email': 'alice.williams@example.com',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    },
    {
      'id': '5',
      'name': 'Charlie Brown',
      'phone': '+1234567894',
      'email': 'charlie.brown@example.com',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    },
  ];

  for (var contact in dummyContacts) {
    await contactsRef.doc(contact['id'] as String).set(contact);
    print('Added: ${contact['name']}');
  }

  print('All dummy contacts added successfully!');
}
