import 'package:contacts_app/features/contacts/presentation/bloc/contact_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../widgets/contact_list_widget.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_event.dart';
import 'add_edit_contact_screen.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isAddingContacts = false;

  @override
  void initState() {
    super.initState();
    // Check Firestore status after initial load
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.read<ContactBloc>().add(CheckFirestoreStatusEvent());
      }
    });
  }

  Future<void> _bulkAddContacts() async {
    setState(() => _isAddingContacts = true);
    
    final firestore = FirebaseFirestore.instance;
    final contactsRef = firestore.collection('contacts');
    final firstNames = ['John', 'Jane', 'Bob', 'Alice', 'Charlie', 'Emma', 'David', 'Sarah', 'Michael', 'Lisa'];
    final lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'];

    try {
      for (int i = 1; i <= 50; i++) {
        final firstName = firstNames[i % firstNames.length];
        final lastName = lastNames[(i ~/ firstNames.length) % lastNames.length];
        final name = '$firstName $lastName $i';
        
        final contact = {
          'id': 'contact_${DateTime.now().millisecondsSinceEpoch}_$i',
          'name': name,
          'phone': '+1${(2000000000 + DateTime.now().millisecondsSinceEpoch % 1000000 + i).toString()}',
          'email': '${firstName.toLowerCase()}.${lastName.toLowerCase()}$i@example.com',
          'isFavorite': i % 5 == 0,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        };

        await contactsRef.doc(contact['id'] as String).set(contact);
      }
      
      if (mounted) {
        context.read<ContactBloc>().add(LoadContactsEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully added 50 contacts!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingContacts = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search contacts...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            context.read<ContactBloc>().add(SearchContactsEvent(query));
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<ContactBloc>().add(SearchContactsEvent(''));
              },
            ),
          BlocBuilder<ContactBloc, ContactState>(
            builder: (context, state) {
              if (state is ContactLoaded && state.unsyncedCount > 0) {
                return Stack(
                  children: [
                    IconButton(
                      icon: state.isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      onPressed: state.isSyncing
                          ? null
                          : () => context.read<ContactBloc>().add(SyncContactsEvent()),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${state.unsyncedCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, currentTheme) {
              return PopupMenuButton<ThemeMode>(
                icon: const Icon(Icons.brightness_6),
                onSelected: (mode) {
                  context.read<ThemeCubit>().setTheme(mode);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: ThemeMode.light,
                    child: Row(
                      children: [
                        const Text('Light Theme'),
                        if (currentTheme == ThemeMode.light)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.check, size: 20),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.dark,
                    child: Row(
                      children: [
                        const Text('Dark Theme'),
                        if (currentTheme == ThemeMode.dark)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.check, size: 20),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.system,
                    child: Row(
                      children: [
                        const Text('System Default'),
                        if (currentTheme == ThemeMode.system)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.check, size: 20),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) {
              final state = context.read<ContactBloc>().state;
              final showRestore = state is ContactLoaded && state.isFirestoreEmpty;
              
              return [
                const PopupMenuItem(
                  value: 'add50',
                  child: Text('Add 50 Contacts'),
                ),
                if (showRestore)
                  const PopupMenuItem(
                    value: 'restore',
                    child: Text('Restore to Firebase'),
                  ),
              ];
            },
            onSelected: (value) {
              if (value == 'add50') {
                _bulkAddContacts();
              } else if (value == 'restore') {
                context.read<ContactBloc>().add(SyncContactsEvent());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restoring contacts to Firebase...')),
                );
              }
            },
          ),
        ],
      ),
      body: _isAddingContacts
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Adding 50 contacts...'),
                ],
              ),
            )
          : const ContactListWidget(showFavoritesOnly: false),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditContactScreen(),
            ),
          );
          if (context.mounted) {
            context.read<ContactBloc>().add(LoadContactsEvent());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
