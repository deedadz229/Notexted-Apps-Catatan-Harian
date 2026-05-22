import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/note_model.dart';
import '../services/theme_service.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.note,
    required this.onTap,
    required this.onFavorite,
    required this.onPin,
    super.key,
  });

  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onPin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateText = DateFormat('dd MMM yyyy, HH:mm').format(note.updatedAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFEDEDF2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TypeBadge(type: note.type),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: note.isPinned ? 'Lepas pin' : 'Pin catatan',
                    onPressed: onPin,
                    icon: Icon(
                      note.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      size: 20,
                      color: note.isPinned ? AppTheme.notesYellow : null,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip:
                        note.isFavorite ? 'Hapus favorit' : 'Tambah favorit',
                    onPressed: onFavorite,
                    icon: Icon(
                      note.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 22,
                      color: note.isFavorite ? AppTheme.notesYellow : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _previewText(note),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : AppTheme.greyText,
                      height: 1.42,
                    ),
              ),
              const Spacer(),
              if (note.reminderAt != null) ...[
                const SizedBox(height: 10),
                _MetaLine(
                  icon: Icons.notifications_active_outlined,
                  text:
                      'Pengingat ${DateFormat('dd MMM, HH:mm').format(note.reminderAt!)}',
                ),
              ],
              const SizedBox(height: 10),
              _MetaLine(icon: Icons.schedule_rounded, text: dateText),
            ],
          ),
        ),
      ),
    );
  }

  String _previewText(NoteModel note) {
    switch (note.type) {
      case NoteType.finance:
        final value = note.amount == null
            ? 'Nominal belum diisi'
            : NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(note.amount);
        return '${note.financeType.label} - $value\n${note.content}';
      case NoteType.todo:
        final done = note.todos.where((item) => item.isDone).length;
        final items = note.todos.map((item) => item.title).take(3).join(', ');
        return '$done/${note.todos.length} selesai\n$items';
      case NoteType.regular:
        return note.content;
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final NoteType type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      NoteType.regular => Icons.description_outlined,
      NoteType.finance => Icons.payments_outlined,
      NoteType.todo => Icons.checklist_rounded,
    };
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.softYellow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: AppTheme.ink),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 15, color: isDark ? Colors.white54 : AppTheme.greyText),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : AppTheme.greyText,
                ),
          ),
        ),
      ],
    );
  }
}
