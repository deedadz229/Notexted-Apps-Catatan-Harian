import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../data/models/note_model.dart';
import 'auth_service.dart';

class NoteService extends GetxService {
  static NoteService get to => Get.find<NoteService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  String get _requiredUid {
    final uid = AuthService.to.uid;
    if (uid == null) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        message: 'User belum login.',
      );
    }
    return uid;
  }

  Stream<List<NoteModel>> watchNotes() {
    final uid = AuthService.to.uid;
    if (uid == null) return Stream.value(<NoteModel>[]);

    return _notesRef(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(NoteModel.fromSnapshot).toList();
    });
  }

  Future<void> createNote({
    required NoteModel note,
  }) {
    return _notesRef(_requiredUid).add(note.toCreateMap());
  }

  Future<void> updateNote(NoteModel note) {
    return _notesRef(_requiredUid).doc(note.id).update(note.toUpdateMap());
  }

  Future<void> deleteNote(String id) {
    return _notesRef(_requiredUid).doc(id).delete();
  }

  Future<void> toggleFavorite(NoteModel note) {
    return _notesRef(_requiredUid).doc(note.id).update({
      'isFavorite': !note.isFavorite,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> togglePin(NoteModel note) {
    return _notesRef(_requiredUid).doc(note.id).update({
      'isPinned': !note.isPinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
