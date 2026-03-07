import '../entities/contact_entity.dart';
import '../repository/contact_repository.dart';

class GetAllContactsUseCase {
  final ContactRepository repository;

  GetAllContactsUseCase(this.repository);

  Future<List<ContactEntity>> call() async {
    return await repository.getAllContacts();
  }
}
