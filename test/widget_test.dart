import 'package:flutter_test/flutter_test.dart';
import 'package:notexted/app/data/models/note_model.dart';

void main() {
  test('NoteModel copyWith keeps unchanged fields', () {
    final created = DateTime(2026, 5, 22, 9);
    final updated = DateTime(2026, 5, 22, 10);

    final note = NoteModel(
      id: 'note-1',
      title: 'Pagi',
      content: 'Hari ini tenang.',
      type: NoteType.regular,
      isFavorite: false,
      isPinned: false,
      createdAt: created,
      updatedAt: updated,
    );

    final edited = note.copyWith(title: 'Pagi yang cerah', isFavorite: true);

    expect(edited.id, 'note-1');
    expect(edited.title, 'Pagi yang cerah');
    expect(edited.content, 'Hari ini tenang.');
    expect(edited.isFavorite, isTrue);
    expect(edited.createdAt, created);
  });
}
