import '../../domain/entities/contact_entity.dart';

abstract class ContactEvent {}

class LoadContactsEvent extends ContactEvent {
  final int page;
  final int limit;
  LoadContactsEvent({this.page = 1, this.limit = 20});
}

class LoadMoreContactsEvent extends ContactEvent {}

class SearchContactsEvent extends ContactEvent {
  final String query;
  SearchContactsEvent(this.query);
}

class CheckFirestoreStatusEvent extends ContactEvent {}

class AddContactEvent extends ContactEvent {
  final ContactEntity contact;
  AddContactEvent(this.contact);
}

class UpdateContactEvent extends ContactEvent {
  final ContactEntity contact;
  UpdateContactEvent(this.contact);
}

class DeleteContactEvent extends ContactEvent {
  final String id;
  DeleteContactEvent(this.id);
}

class SyncContactsEvent extends ContactEvent {}
