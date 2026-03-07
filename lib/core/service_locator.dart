import 'package:get_it/get_it.dart';
import '../../features/contacts/data/services/firebase_contact_service.dart';
import '../../features/contacts/data/services/local_database_service.dart';
import '../../features/contacts/data/repository/contact_repository_impl.dart';
import '../../features/contacts/domain/repository/contact_repository.dart';
import '../../features/contacts/domain/usecases/get_all_contacts_usecase.dart';
import '../../features/contacts/domain/usecases/add_contact_usecase.dart';
import '../../features/contacts/domain/usecases/update_contact_usecase.dart';
import '../../features/contacts/domain/usecases/delete_contact_usecase.dart';
import '../../features/contacts/domain/usecases/sync_contacts_usecase.dart';
import '../../features/contacts/presentation/bloc/contact_bloc.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  sl.registerLazySingleton(() => FirebaseContactService());
  sl.registerLazySingleton(() => LocalDatabaseService());

  // Repository
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(sl(), sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllContactsUseCase(sl()));
  sl.registerLazySingleton(() => AddContactUseCase(sl()));
  sl.registerLazySingleton(() => UpdateContactUseCase(sl()));
  sl.registerLazySingleton(() => DeleteContactUseCase(sl()));
  sl.registerLazySingleton(() => SyncContactsUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => ContactBloc(
      getAllContactsUseCase: sl(),
      addContactUseCase: sl(),
      updateContactUseCase: sl(),
      deleteContactUseCase: sl(),
      syncContactsUseCase: sl(),
    ),
  );
}
