import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/note_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/empty_state.dart';
import '../controllers/note_controller.dart';

class DetailNoteView extends GetView<NoteController> {
  const DetailNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    final note = controller.noteArgument;
    if (note == null) {
      return const Scaffold(
        body: EmptyState(
          title: 'Catatan tidak ditemukan',
          message: 'Kembali dan pilih catatan yang ingin dibaca.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
        actions: [
          IconButton(
            tooltip: note.isPinned ? 'Lepas pin' : 'Pin catatan',
            onPressed: () => controller.togglePin(note),
            icon: Icon(
              note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
            ),
          ),
          IconButton(
            tooltip: note.isFavorite ? 'Hapus favorit' : 'Tambah favorit',
            onPressed: () => controller.toggleFavorite(note),
            icon: Icon(
              note.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: note.isFavorite ? AppTheme.notesYellow : null,
            ),
          ),
          IconButton(
            tooltip: 'Edit catatan',
            onPressed: () => Get.toNamed(AppRoutes.editNote, arguments: note),
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Hapus catatan',
            onPressed: () => _showDeleteSheet(note),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 32),
          children: [
            _DetailMeta(note: note),
            const SizedBox(height: 28),
            Text(
              note.title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    height: 1.05,
                  ),
            ),
            const SizedBox(height: 18),
            if (note.type == NoteType.finance) _FinanceSummary(note: note),
            if (note.type == NoteType.todo) _TodoSummary(note: note),
            if (note.content.trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      height: 1.62,
                      letterSpacing: 0,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteSheet(NoteModel note) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Get.theme.dividerColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(
                'Hapus catatan?',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Catatan yang dihapus tidak bisa dikembalikan.'),
              const SizedBox(height: 20),
              Obx(
                () => FilledButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.deleteNote(note),
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline_rounded),
                  label: const Text('Hapus'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              TextButton(
                onPressed: Get.back,
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _DetailMeta extends StatelessWidget {
  const _DetailMeta({required this.note});

  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    final icon = switch (note.type) {
      NoteType.regular => Icons.description_outlined,
      NoteType.finance => Icons.payments_outlined,
      NoteType.todo => Icons.checklist_rounded,
    };
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.softYellow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppTheme.ink, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${note.type.label} - ${DateFormat('dd MMM yyyy').format(note.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.greyText,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                note.reminderAt == null
                    ? 'Update ${DateFormat('HH:mm').format(note.updatedAt)}'
                    : 'Pengingat ${DateFormat('dd MMM, HH:mm').format(note.reminderAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.greyText,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinanceSummary extends StatelessWidget {
  const _FinanceSummary({required this.note});

  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    final color =
        note.financeType == FinanceType.income ? Colors.green : Colors.redAccent;
    final amount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(note.amount ?? 0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            note.financeType == FinanceType.income
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${note.financeType.label} - $amount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoSummary extends StatelessWidget {
  const _TodoSummary({required this.note});

  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    final done = note.todos.where((item) => item.isDone).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$done/${note.todos.length} selesai',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        ...note.todos.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
              ),
            ),
            child: CheckboxListTile(
              value: item.isDone,
              onChanged: null,
              title: Text(
                item.title,
                style: TextStyle(
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }),
      ],
    );
  }
}
