import 'dart:async';

import 'package:get/get.dart';

import '../../../data/models/note_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/note_service.dart';

class HomeController extends GetxController {
  final notes = <NoteModel>[].obs;
  final searchQuery = ''.obs;
  final selectedType = Rxn<NoteType>();
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  StreamSubscription<List<NoteModel>>? _notesSubscription;

  List<NoteModel> get filteredNotes {
    final query = searchQuery.value.trim().toLowerCase();
    final type = selectedType.value;
    final filtered = notes.where((note) {
      final todoText = note.todos.map((item) => item.title).join(' ');
      final matchesQuery = query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          todoText.toLowerCase().contains(query);
      final matchesType = type == null || note.type == type;
      return matchesQuery && matchesType;
    }).toList();

    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return filtered;
  }

  Map<NoteType, int> get typeCounts {
    final counts = <NoteType, int>{};
    for (final note in notes) {
      counts[note.type] = (counts[note.type] ?? 0) + 1;
    }
    return counts;
  }

  @override
  void onInit() {
    super.onInit();
    _listenToNotes();
  }

  void _listenToNotes() {
    isLoading.value = true;
    _notesSubscription = NoteService.to.watchNotes().listen(
      (items) {
        notes.assignAll(items);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        Get.snackbar('Gagal', 'Tidak bisa memuat catatan.');
      },
    );
  }

  Future<void> refreshNotes() async {
    isRefreshing.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 450));
    notes.refresh();
    isRefreshing.value = false;
  }

  void openCreateNote() => Get.toNamed(AppRoutes.createNote);

  void openDetail(NoteModel note) {
    Get.toNamed(AppRoutes.detailNote, arguments: note);
  }

  Future<void> toggleFavorite(NoteModel note) async {
    try {
      await NoteService.to.toggleFavorite(note);
    } catch (_) {
      Get.snackbar('Gagal', 'Status favorit belum tersimpan.');
    }
  }

  Future<void> togglePin(NoteModel note) async {
    try {
      await NoteService.to.togglePin(note);
    } catch (_) {
      Get.snackbar('Gagal', 'Status pin belum tersimpan.');
    }
  }

  Future<void> logout() async {
    await AuthService.to.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    _notesSubscription?.cancel();
    super.onClose();
  }
}
