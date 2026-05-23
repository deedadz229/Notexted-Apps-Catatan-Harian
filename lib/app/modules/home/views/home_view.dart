import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/note_model.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/app_loading.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/note_card.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah catatan',
        onPressed: controller.openCreateNote,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator(
            color: AppTheme.notesYellow,
            onRefresh: controller.refreshNotes,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _HomeHeader(controller: controller),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SearchAndFilters(controller: controller),
                  ),
                ),
                if (controller.isLoading.value)
                  const SliverFillRemaining(child: AppLoading())
                else if (controller.filteredNotes.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      title: 'Belum ada catatan',
                      message:
                          'Buat catatan biasa, catatan keuangan, atau to-do list pertamamu.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final count = width >= 900
                            ? 3
                            : width >= 620
                                ? 2
                                : 1;
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final note = controller.filteredNotes[index];
                              return NoteCard(
                                note: note,
                                onTap: () => controller.openDetail(note),
                                onFavorite: () =>
                                    controller.toggleFavorite(note),
                                onPin: () => controller.togglePin(note),
                              );
                            },
                            childCount: controller.filteredNotes.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: count,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: count == 1 ? 1.9 : 1.35,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang di Catatan!',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  '${controller.notes.length} catatan tersimpan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.greyText,
                      ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => IconButton.filledTonal(
            tooltip: ThemeService.to.isDarkMode.value
                ? 'Mode terang'
                : 'Mode gelap',
            onPressed: ThemeService.to.toggleTheme,
            icon: Icon(
              ThemeService.to.isDarkMode.value
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Logout',
          onPressed: controller.logout,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) => controller.searchQuery.value = value,
          decoration: const InputDecoration(
            hintText: 'Cari catatan...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: NoteType.values.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final type = index == 0 ? null : NoteType.values[index - 1];
              return Obx(() {
                final selected = controller.selectedType.value == type;
                return ChoiceChip(
                  selected: selected,
                  showCheckmark: false,
                  avatar: type == null ? null : Icon(_typeIcon(type), size: 18),
                  label: Text(type?.label ?? 'Semua'),
                  onSelected: (_) => controller.selectedType.value = type,
                  selectedColor: AppTheme.notesYellow,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide(
                    color: selected
                        ? AppTheme.notesYellow
                        : Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.35),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  IconData _typeIcon(NoteType type) {
    return switch (type) {
      NoteType.regular => Icons.description_outlined,
      NoteType.finance => Icons.payments_outlined,
      NoteType.todo => Icons.checklist_rounded,
    };
  }
}
