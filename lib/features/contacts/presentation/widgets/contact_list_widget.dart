import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_state.dart';
import '../bloc/contact_event.dart';
import '../../domain/entities/contact_entity.dart';
import 'contact_card_widget.dart';
import 'empty_state_widget.dart';
import '../view/contact_details_screen.dart';

class ContactListWidget extends StatefulWidget {
  final bool showFavoritesOnly;

  const ContactListWidget({super.key, required this.showFavoritesOnly});

  @override
  State<ContactListWidget> createState() => _ContactListWidgetState();
}

class _ContactListWidgetState extends State<ContactListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<ContactBloc>().state;
      if (state is ContactLoaded && state.hasMore && state.searchQuery.isEmpty) {
        context.read<ContactBloc>().add(LoadMoreContactsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        if (state is ContactLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ContactError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                ElevatedButton(
                  onPressed: () =>
                      context.read<ContactBloc>().add(LoadContactsEvent()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ContactLoaded) {
          final contacts = widget.showFavoritesOnly
              ? state.contacts.where((c) => c.isFavorite).toList()
              : state.contacts;

          if (contacts.isEmpty) {
            return EmptyStateWidget(
              message: widget.showFavoritesOnly
                  ? 'No favorite contacts yet'
                  : 'No contacts found',
              icon: widget.showFavoritesOnly ? Icons.favorite_border : Icons.contacts,
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: contacts.length + (state.hasMore && !widget.showFavoritesOnly ? 1 : 0),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              if (index == contacts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final contact = contacts[index];
              return ContactCardWidget(
                id: contact.id,
                name: contact.name,
                phone: contact.phone,
                email: contact.email,
                isFavorite: contact.isFavorite,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContactDetailsScreen(contactId: contact.id),
                    ),
                  );
                },
                onFavoriteToggle: () {
                  final updatedContact = ContactEntity(
                    id: contact.id,
                    name: contact.name,
                    phone: contact.phone,
                    email: contact.email,
                    isFavorite: !contact.isFavorite,
                    isSynced: contact.isSynced,
                    createdAt: contact.createdAt,
                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                  );
                  context.read<ContactBloc>().add(
                    UpdateContactEvent(updatedContact),
                  );
                },
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}
