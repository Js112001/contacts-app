import '../repository/contact_repository.dart';

class SyncContactsUseCase {
  final ContactRepository repository;

  SyncContactsUseCase(this.repository);

  Future<void> call() async {
    await repository.syncContacts();
  }
}
