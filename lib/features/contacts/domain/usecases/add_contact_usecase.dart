import '../entities/contact_entity.dart';
import '../repository/contact_repository.dart';

class AddContactUseCase {
  final ContactRepository repository;

  AddContactUseCase(this.repository);

  Future<void> call(ContactEntity contact) async {
    await repository.addContact(contact);
  }
}
