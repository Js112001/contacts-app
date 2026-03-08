import 'package:contacts_app/features/contacts/domain/entities/contact_entity.dart';

abstract class ContactState {}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactLoaded extends ContactState {
  final List<ContactEntity> contacts;
  final bool hasMore;
  final int currentPage;
  final String searchQuery;
  final bool isSyncing;
  final int unsyncedCount;
  final bool isFirestoreEmpty;
  
  ContactLoaded(
    this.contacts, {
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery = '',
    this.isSyncing = false,
    this.unsyncedCount = 0,
    this.isFirestoreEmpty = false,
  });
  
  ContactLoaded copyWith({
    List<ContactEntity>? contacts,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    bool? isSyncing,
    int? unsyncedCount,
    bool? isFirestoreEmpty,
  }) {
    return ContactLoaded(
      contacts ?? this.contacts,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      isSyncing: isSyncing ?? this.isSyncing,
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
      isFirestoreEmpty: isFirestoreEmpty ?? this.isFirestoreEmpty,
    );
  }
}

class ContactError extends ContactState {
  final String message;
  ContactError(this.message);
}

class ContactOperationSuccess extends ContactState {}
