import 'package:contacts_app/features/contacts/domain/entities/contact_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/get_all_contacts_usecase.dart';
import '../../domain/usecases/add_contact_usecase.dart';
import '../../domain/usecases/update_contact_usecase.dart';
import '../../domain/usecases/delete_contact_usecase.dart';
import '../../domain/usecases/sync_contacts_usecase.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final GetAllContactsUseCase getAllContactsUseCase;
  final AddContactUseCase addContactUseCase;
  final UpdateContactUseCase updateContactUseCase;
  final DeleteContactUseCase deleteContactUseCase;
  final SyncContactsUseCase syncContactsUseCase;

  List<ContactEntity> _allContacts = [];

  ContactBloc({
    required this.getAllContactsUseCase,
    required this.addContactUseCase,
    required this.updateContactUseCase,
    required this.deleteContactUseCase,
    required this.syncContactsUseCase,
  }) : super(ContactInitial()) {
    on<LoadContactsEvent>(_onLoadContacts);
    on<LoadMoreContactsEvent>(_onLoadMoreContacts);
    on<SearchContactsEvent>(_onSearchContacts);
    on<CheckFirestoreStatusEvent>(_onCheckFirestoreStatus);
    on<AddContactEvent>(_onAddContact);
    on<UpdateContactEvent>(_onUpdateContact);
    on<DeleteContactEvent>(_onDeleteContact);
    on<SyncContactsEvent>(_onSyncContacts);
  }

  Future<void> _onCheckFirestoreStatus(CheckFirestoreStatusEvent event, Emitter<ContactState> emit) async {
    if (state is ContactLoaded) {
      final currentState = state as ContactLoaded;
      try {
        final firebaseContacts = await FirebaseFirestore.instance.collection('contacts').limit(1).get();
        final isFirestoreEmpty = firebaseContacts.docs.isEmpty && _allContacts.isNotEmpty;
        emit(currentState.copyWith(isFirestoreEmpty: isFirestoreEmpty));
      } catch (e) {
        // Ignore error
      }
    }
  }

  Future<void> _onLoadContacts(LoadContactsEvent event, Emitter<ContactState> emit) async {
    emit(ContactLoading());
    try {
      _allContacts = await getAllContactsUseCase();
      final paginatedContacts = _allContacts.take(event.limit).toList();
      final unsyncedCount = _allContacts.where((c) => !c.isSynced).length;
      emit(ContactLoaded(
        paginatedContacts,
        hasMore: _allContacts.length > event.limit,
        currentPage: event.page,
        unsyncedCount: unsyncedCount,
      ));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }

  Future<void> _onLoadMoreContacts(LoadMoreContactsEvent event, Emitter<ContactState> emit) async {
    if (state is ContactLoaded) {
      final currentState = state as ContactLoaded;
      final nextPage = currentState.currentPage + 1;
      final startIndex = currentState.contacts.length;
      final endIndex = startIndex + 20;
      
      final moreContacts = _allContacts.skip(startIndex).take(20).toList();
      final updatedContacts = [...currentState.contacts, ...moreContacts];
      
      emit(currentState.copyWith(
        contacts: updatedContacts,
        hasMore: endIndex < _allContacts.length,
        currentPage: nextPage,
      ));
    }
  }

  Future<void> _onSearchContacts(SearchContactsEvent event, Emitter<ContactState> emit) async {
    try {
      final unsyncedCount = _allContacts.where((c) => !c.isSynced).length;
      if (event.query.isEmpty) {
        final paginatedContacts = _allContacts.take(20).toList();
        emit(ContactLoaded(
          paginatedContacts,
          hasMore: _allContacts.length > 20,
          currentPage: 1,
          unsyncedCount: unsyncedCount,
        ));
      } else {
        final filteredContacts = _allContacts.where((contact) {
          return contact.name.toLowerCase().contains(event.query.toLowerCase()) ||
              contact.phone.contains(event.query) ||
              (contact.email?.toLowerCase().contains(event.query.toLowerCase()) ?? false);
        }).toList();
        emit(ContactLoaded(
          filteredContacts,
          hasMore: false,
          currentPage: 1,
          searchQuery: event.query,
          unsyncedCount: unsyncedCount,
        ));
      }
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }

  Future<void> _onAddContact(AddContactEvent event, Emitter<ContactState> emit) async {
    try {
      await addContactUseCase(event.contact);
      emit(ContactOperationSuccess());
      _allContacts = await getAllContactsUseCase();
      final paginatedContacts = _allContacts.take(20).toList();
      final unsyncedCount = _allContacts.where((c) => !c.isSynced).length;
      emit(ContactLoaded(
        paginatedContacts,
        hasMore: _allContacts.length > 20,
        currentPage: 1,
        unsyncedCount: unsyncedCount,
      ));
    } catch (e) {
      if (e.toString().contains('already exists')) {
        emit(ContactError('Contact with same name or phone already exists'));
        if (state is ContactLoaded) {
          emit(state as ContactLoaded);
        }
      } else {
        emit(ContactError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateContact(UpdateContactEvent event, Emitter<ContactState> emit) async {
    try {
      await updateContactUseCase(event.contact);
      _allContacts = await getAllContactsUseCase();
      if (state is ContactLoaded) {
        final currentState = state as ContactLoaded;
        final paginatedContacts = _allContacts.take(currentState.contacts.length).toList();
        final unsyncedCount = _allContacts.where((c) => !c.isSynced).length;
        emit(currentState.copyWith(
          contacts: paginatedContacts,
          hasMore: currentState.contacts.length < _allContacts.length,
          unsyncedCount: unsyncedCount,
        ));
      }
    } catch (e) {
      if (e.toString().contains('already exists')) {
        emit(ContactError('Contact with same name or phone already exists'));
        if (state is ContactLoaded) {
          emit(state as ContactLoaded);
        }
      } else {
        emit(ContactError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteContact(DeleteContactEvent event, Emitter<ContactState> emit) async {
    try {
      await deleteContactUseCase(event.id);
      _allContacts = await getAllContactsUseCase();
      final paginatedContacts = _allContacts.take(20).toList();
      final unsyncedCount = _allContacts.where((c) => !c.isSynced).length;
      emit(ContactLoaded(
        paginatedContacts,
        hasMore: _allContacts.length > 20,
        currentPage: 1,
        unsyncedCount: unsyncedCount,
      ));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }

  Future<void> _onSyncContacts(SyncContactsEvent event, Emitter<ContactState> emit) async {
    if (state is ContactLoaded) {
      final currentState = state as ContactLoaded;
      emit(currentState.copyWith(isSyncing: true));
    }
    
    try {
      await syncContactsUseCase();
      _allContacts = await getAllContactsUseCase();
      final paginatedContacts = _allContacts.take(20).toList();
      emit(ContactLoaded(
        paginatedContacts,
        hasMore: _allContacts.length > 20,
        currentPage: 1,
        unsyncedCount: 0,
      ));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }
}
