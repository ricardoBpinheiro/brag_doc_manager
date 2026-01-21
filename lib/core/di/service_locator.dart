import 'package:brag_doc_manager/data/repositories/brag_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<BragRepository>(
    () => BragRepository(firestore: getIt<FirebaseFirestore>()),
  );
}
