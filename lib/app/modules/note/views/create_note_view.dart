import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/note_editor_body.dart';
import '../controllers/note_controller.dart';

class CreateNoteView extends GetView<NoteController> {
  const CreateNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return NoteEditorBody(
      title: 'Catatan Baru',
      buttonLabel: 'Simpan Catatan',
      onSubmit: controller.createNote,
    );
  }
}
