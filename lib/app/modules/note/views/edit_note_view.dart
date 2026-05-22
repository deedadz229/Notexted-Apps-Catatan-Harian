import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/empty_state.dart';
import '../../../widgets/note_editor_body.dart';
import '../controllers/note_controller.dart';

class EditNoteView extends StatefulWidget {
  const EditNoteView({super.key});

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  late final NoteController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NoteController>();
    final note = controller.noteArgument;
    if (note != null) controller.fillFromNote(note);
  }

  @override
  Widget build(BuildContext context) {
    final note = controller.noteArgument;
    if (note == null) {
      return const Scaffold(
        body: EmptyState(
          title: 'Catatan tidak ditemukan',
          message: 'Kembali dan pilih catatan yang ingin diedit.',
        ),
      );
    }

    return NoteEditorBody(
      title: 'Edit Catatan',
      buttonLabel: 'Update Catatan',
      onSubmit: () => controller.updateNote(note),
    );
  }
}
