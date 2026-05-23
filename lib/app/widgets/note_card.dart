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
    final isFinance = note.type == NoteType.finance;

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
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEDEDF2),
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
                          ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onPin,
                    icon: Icon(
                      note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      size: 20,
                      color: note.isPinned ? AppTheme.notesYellow : null,
                    ),
                  ),
                ],
              ),
              
              if (isFinance) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.show_chart_rounded, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Text(
                        '${note.financeType.label} - ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(note.amount ?? 0)}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),
              Text(
                note.content,
                maxLines: isFinance ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : AppTheme.greyText,
                      height: 1.42,
                    ),
              ),
              const Spacer(),
              if (note.reminderAt != null) ...[
                const SizedBox(height: 10),
                _MetaLine(icon: Icons.notifications_active_outlined, text: 'Pengingat ${DateFormat('dd MMM, HH:mm').format(note.reminderAt!)}'),
              ],
              const SizedBox(height: 10),
              _MetaLine(icon: Icons.schedule_rounded, text: dateText),
            ],
          ),
        ),
      ),
    );
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
      width: 36, height: 36,
      decoration: BoxDecoration(color: AppTheme.softYellow, borderRadius: BorderRadius.circular(12)),
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
        Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white54 : AppTheme.greyText))),
      ],
    );
  }
}