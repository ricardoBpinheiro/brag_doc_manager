import 'package:brag_doc_manager/data/models/brag_entry_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BragRepository {
  final FirebaseFirestore _firestore;

  BragRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  late final CollectionReference<BragEntryModel> _entriesRef =
      _firestore.collection('brag_entries').withConverter<BragEntryModel>(
            fromFirestore: BragEntryModel.fromFirestore,
            toFirestore: (BragEntryModel entry, _) => entry.toFirestore(),
          );

  Stream<List<BragEntryModel>> getAllEntries() {
    return _entriesRef
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<BragEntryModel?> getEntryById(String id) async {
    final snapshot = await _entriesRef.doc(id).get();
    return snapshot.data();
  }

  Future<void> createEntry(BragEntryModel entry) async {
    await _entriesRef.add(entry);
  }

  Future<void> updateEntry(BragEntryModel entry) async {
    if (entry.id == null) {
      throw Exception("Cannot update an entry without an ID.");
    }
    await _entriesRef.doc(entry.id).update(entry.toFirestore());
  }

  Future<void> deleteEntry(String id) async {
    await _entriesRef.doc(id).delete();
  }
}
