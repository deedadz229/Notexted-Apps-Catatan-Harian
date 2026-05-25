import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/models/note_model.dart';
import '../modules/note/controllers/note_controller.dart';
import '../services/theme_service.dart';
import 'apple_button.dart';
import 'app_text_field.dart';

class NoteEditorBody extends StatelessWidget {
  const NoteEditorBody({
    required this.title,
    required this.buttonLabel,
    required this.onSubmit,
    super.key,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NoteController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _TypeSelector(controller: controller),
            const SizedBox(height: 18),
            AppTextField(
              controller: controller.titleC,
              hint: 'Judul catatan',
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 14),
            Obx(
              () => AppTextField(
                controller: controller.contentC,
                hint: controller.selectedType.value == NoteType.finance
                    ? 'Keterangan transaksi'
                    : 'Tulis catatan...',
                icon: Icons.notes_rounded,
                maxLines:
                    controller.selectedType.value == NoteType.todo ? 4 : 8,
              ),
            ),
            const SizedBox(height: 18),
            Obx(() {
              if (controller.selectedType.value == NoteType.finance) {
                return _FinanceFields(controller: controller);
              }
              if (controller.selectedType.value == NoteType.todo) {
                return _TodoFields(controller: controller);
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 18),
            _ReminderCard(controller: controller),
            const SizedBox(height: 28),
            Obx(
              () => AppleButton(
                label: buttonLabel,
                icon: Icons.check_rounded,
                isLoading: controller.isLoading.value,
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.controller});
  final NoteController controller;
  @override
  Widget build(BuildContext context) {
    return Obx(() => SegmentedButton<NoteType>(
        segments: const [
          ButtonSegment(value: NoteType.regular, icon: Icon(Icons.description_outlined), label: Text('Catatan')),
          ButtonSegment(value: NoteType.finance, icon: Icon(Icons.payments_outlined), label: Text('Keuangan')),
          ButtonSegment(value: NoteType.todo, icon: Icon(Icons.checklist_rounded), label: Text('To-do')),
        ],
        selected: {controller.selectedType.value},
        onSelectionChanged: (value) => controller.selectedType.value = value.first,
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        ),
      ));
  }
}

class _FinanceFields extends StatelessWidget {
  const _FinanceFields({required this.controller});
  final NoteController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: controller.amountC,
          hint: 'Nominal',
          icon: Icons.attach_money_rounded,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Obx(() => SegmentedButton<FinanceType>(
            segments: const [
              ButtonSegment(value: FinanceType.income, icon: Icon(Icons.trending_up_rounded), label: Text('Masuk')),
              ButtonSegment(value: FinanceType.expense, icon: Icon(Icons.trending_down_rounded), label: Text('Keluar')),
            ],
            selected: {controller.financeType.value},
            onSelectionChanged: (value) => controller.financeType.value = value.first,
            showSelectedIcon: false,
          )),
      ],
    );
  }
}

class _TodoFields extends StatelessWidget {
  const _TodoFields({required this.controller});
  final NoteController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: controller.todoC,
                hint: 'Tambah item to-do disini...', 
                icon: Icons.add_task_rounded,
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: 'Tambah to-do',
              onPressed: controller.addTodo,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: List.generate(controller.todos.length, (index) {
                final item = controller.todos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.35)),
                  ),
                  child: CheckboxListTile(
                    value: item.isDone,
                    onChanged: (value) => controller.toggleTodo(index, value ?? false),
                    title: Text(item.title, style: TextStyle(decoration: item.isDone ? TextDecoration.lineThrough : null)),
                    secondary: IconButton(
                      tooltip: 'Hapus item',
                      onPressed: () => controller.removeTodo(index),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              }),
            )),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.controller});
  final NoteController controller;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reminder = controller.reminderAt.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.softYellow.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.14 : 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: AppTheme.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reminder == null ? 'Belum ada pengingat' : 'Pengingat ${DateFormat('dd MMM yyyy, HH:mm').format(reminder)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ),
            if (reminder != null)
              IconButton(tooltip: 'Hapus pengingat', onPressed: controller.clearReminder, icon: const Icon(Icons.close_rounded)),
            TextButton(style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            onPressed: () => controller.pickReminder(context),
            child: Text(
              reminder == null ? 'Atur' : 'Ubah',
            ),),
          ],
        ),
      );
    });
  }
}