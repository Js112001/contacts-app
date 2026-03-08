import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../../domain/entities/contact_entity.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_event.dart';
import '../bloc/contact_state.dart';
import 'add_edit_contact_screen.dart';

class ContactDetailsScreen extends StatelessWidget {
  final String contactId;

  const ContactDetailsScreen({super.key, required this.contactId});

  Future<void> _makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  void _deleteContact(BuildContext context, ContactEntity contact) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ContactBloc>().add(DeleteContactEvent(contact.id));
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
      ),
      body: BlocBuilder<ContactBloc, ContactState>(
        builder: (context, state) {
          if (state is ContactLoaded) {
            final contact = state.contacts.firstWhere(
              (c) => c.id == contactId,
              orElse: () => state.contacts.first,
            );

            return ListView(
              children: [
                const SizedBox(height: 32),
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 48,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    contact.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(contact.phone),
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditContactScreen(contact: contact),
                          ),
                        );
                        if (context.mounted) {
                          context.read<ContactBloc>().add(LoadContactsEvent());
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteContact(context, contact),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone'),
                  subtitle: Text(contact.phone),
                ),
                if (contact.email != null && contact.email!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(contact.email!),
                  ),
                ListTile(
                  leading: Icon(
                    contact.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: contact.isFavorite ? Colors.red : null,
                  ),
                  title: Text(contact.isFavorite ? 'Favorite' : 'Not a favorite'),
                  trailing: Switch(
                    value: contact.isFavorite,
                    onChanged: (value) {
                      final updatedContact = ContactEntity(
                        id: contact.id,
                        name: contact.name,
                        phone: contact.phone,
                        email: contact.email,
                        isFavorite: value,
                        isSynced: contact.isSynced,
                        createdAt: contact.createdAt,
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      );
                      context.read<ContactBloc>().add(UpdateContactEvent(updatedContact));
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
