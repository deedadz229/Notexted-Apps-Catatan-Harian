import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/note_model.dart';
import '../../../services/note_service.dart';

class NoteController extends GetxController {
  final titleC = TextEditingController();
  final contentC = TextEditingController();
  final amountC = TextEditingController();
  final todoC = TextEditingController();

  final selectedType = NoteType.regular.obs;
  final financeType = FinanceType.expense.obs;
  final reminderAt = Rxn<DateTime>();
  final todos = <TodoItem>[].obs;
  final isLoading = false.obs;

  NoteModel? get noteArgument {
    final argument = Get.arguments;
    if (argument is NoteModel) return argument;
    return null;
  }

  void fillFromNote(NoteModel note) {
    titleC.text = note.title;
    contentC.text = note.content;
    amountC.text = note.amount == null ? '' : _formatAmount(note.amount!);
    selectedType.value = note.type;
    financeType.value = note.financeType;
    reminderAt.value = note.reminderAt;
    todos.assignAll(note.todos);
  }

  Future<void> pickReminder(BuildContext context) async {
    final now = DateTime.now();
    final initial = reminderAt.value ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    reminderAt.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void clearReminder() => reminderAt.value = null;

  void addTodo() {
    final title = todoC.text.trim();
    if (title.isEmpty) return;
    todos.add(TodoItem(title: title));
    todoC.clear();
  }

  void toggleTodo(int index, bool value) {
    if (index < 0 || index >= todos.length) return;
    todos[index] = todos[index].copyWith(isDone: value);
  }

  void removeTodo(int index) {
    if (index < 0 || index >= todos.length) return;
    todos.removeAt(index);
  }

  Future<void> createNote() async {
    if (!_validate()) return;
    final now = DateTime.now();
    await _runNoteAction(
      action: () => NoteService.to.createNote(
        note: NoteModel(
          id: '',
          title: titleC.text,
          content: contentC.text,
          type: selectedType.value,
          isFavorite: false,
          isPinned: false,
          createdAt: now,
          updatedAt: now,
          reminderAt: reminderAt.value,
          amount: _amountValue,
          financeType: financeType.value,
          todos: todos.toList(),
        ),
      ),
      successMessage: 'Catatan baru tersimpan.',
    );
  }

  Future<void> updateNote(NoteModel note) async {
    if (!_validate()) return;
    await _runNoteAction(
      action: () => NoteService.to.updateNote(
        note.copyWith(
          title: titleC.text,
          content: contentC.text,
          type: selectedType.value,
          reminderAt: reminderAt.value,
          clearReminder: reminderAt.value == null,
          amount: _amountValue,
          clearAmount: selectedType.value != NoteType.finance,
          financeType: financeType.value,
          todos: selectedType.value == NoteType.todo ? todos.toList() : const [],
        ),
      ),
      successMessage: 'Catatan berhasil diperbarui.',
    );
  }

  Future<void> deleteNote(NoteModel note) async {
    try {
      isLoading.value = true;
      await NoteService.to.deleteNote(note.id);
      Get.back();
      Get.back();
      Get.snackbar('Terhapus', 'Catatan sudah dihapus.');
    } catch (_) {
      Get.snackbar('Gagal', 'Catatan belum bisa dihapus.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(NoteModel note) async {
    await NoteService.to.toggleFavorite(note);
    Get.snackbar('Tersimpan', 'Status favorit diperbarui.');
  }

  Future<void> togglePin(NoteModel note) async {
    await NoteService.to.togglePin(note);
    Get.snackbar('Tersimpan', 'Status pin diperbarui.');
  }

  Future<void> _runNoteAction({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    try {
      isLoading.value = true;
      await action().timeout(const Duration(seconds: 12));
      Get.back();
      Get.snackbar('Berhasil', successMessage);
    } on TimeoutException {
      Get.snackbar(
        'Gagal menyimpan',
        'Firestore terlalu lama merespons. Cek koneksi, Firestore Database, dan rules.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (error) {
      Get.snackbar(
        'Gagal menyimpan',
        _firestoreMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal menyimpan',
        'Perubahan belum tersimpan: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    if (titleC.text.trim().isEmpty) {
      Get.snackbar('Judul kosong', 'Tambahkan judul catatan dulu.');
      return false;
    }
    if (contentC.text.trim().isEmpty && selectedType.value != NoteType.todo) {
      Get.snackbar('Isi kosong', 'Tuliskan isi catatan dulu.');
      return false;
    }
    if (selectedType.value == NoteType.finance && _amountValue == null) {
      Get.snackbar('Nominal kosong', 'Masukkan nominal keuangan yang valid.');
      return false;
    }
    if (selectedType.value == NoteType.todo && todos.isEmpty) {
      Get.snackbar('To-do kosong', 'Tambahkan minimal satu item to-do.');
      return false;
    }
    return true;
  }

  double? get _amountValue {
    final clean = amountC.text.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(clean);
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  String _firestoreMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firestore rules menolak akses. Izinkan user login menulis ke users/{uid}/notes.';
      case 'not-found':
        return 'Firestore Database belum dibuat untuk project Firebase ini.';
      case 'unavailable':
        return 'Firestore sedang tidak tersedia atau koneksi bermasalah.';
      case 'unauthenticated':
        return 'User belum login. Silakan login ulang.';
      case 'failed-precondition':
        return 'Firestore belum siap atau konfigurasi database belum lengkap.';
      default:
        return '${error.code}: ${error.message ?? 'Firestore error.'}';
    }
  }

  @override
  void onClose() {
    titleC.dispose();
    contentC.dispose();
    amountC.dispose();
    todoC.dispose();
    super.onClose();
  }
}
