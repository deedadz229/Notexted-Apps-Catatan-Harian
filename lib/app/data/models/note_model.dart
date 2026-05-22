import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteType {
  regular,
  finance,
  todo;

  String get label {
    switch (this) {
      case NoteType.regular:
        return 'Catatan';
      case NoteType.finance:
        return 'Keuangan';
      case NoteType.todo:
        return 'To-do';
    }
  }

  static NoteType fromString(String? value) {
    return NoteType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => NoteType.regular,
    );
  }
}

enum FinanceType {
  income,
  expense;

  String get label => this == FinanceType.income ? 'Pemasukan' : 'Pengeluaran';

  static FinanceType fromString(String? value) {
    return FinanceType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => FinanceType.expense,
    );
  }
}

class TodoItem {
  const TodoItem({
    required this.title,
    this.isDone = false,
  });

  final String title;
  final bool isDone;

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      title: map['title'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'isDone': isDone,
    };
  }

  TodoItem copyWith({
    String? title,
    bool? isDone,
  }) {
    return TodoItem(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}

class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.isFavorite,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    this.reminderAt,
    this.amount,
    this.financeType = FinanceType.expense,
    this.todos = const [],
  });

  final String id;
  final String title;
  final String content;
  final NoteType type;
  final bool isFavorite;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reminderAt;
  final double? amount;
  final FinanceType financeType;
  final List<TodoItem> todos;

  factory NoteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NoteModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Tanpa Judul',
      content: data['content'] as String? ?? '',
      type: NoteType.fromString(data['type'] as String?),
      isFavorite: data['isFavorite'] as bool? ?? false,
      isPinned: data['isPinned'] as bool? ?? false,
      createdAt: _readDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _readDate(data['updatedAt']) ?? DateTime.now(),
      reminderAt: _readDate(data['reminderAt']),
      amount: _readAmount(data['amount']),
      financeType: FinanceType.fromString(data['financeType'] as String?),
      todos: _readTodos(data['todos']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'title': title.trim(),
      'content': content.trim(),
      'type': type.name,
      'isFavorite': isFavorite,
      'isPinned': isPinned,
      'reminderAt': reminderAt == null ? null : Timestamp.fromDate(reminderAt!),
      'amount': amount,
      'financeType': financeType.name,
      'todos': todos.map((item) => item.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title.trim(),
      'content': content.trim(),
      'type': type.name,
      'isFavorite': isFavorite,
      'isPinned': isPinned,
      'reminderAt': reminderAt == null ? null : Timestamp.fromDate(reminderAt!),
      'amount': amount,
      'financeType': financeType.name,
      'todos': todos.map((item) => item.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    NoteType? type,
    bool? isFavorite,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reminderAt,
    bool clearReminder = false,
    double? amount,
    bool clearAmount = false,
    FinanceType? financeType,
    List<TodoItem>? todos,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderAt: clearReminder ? null : reminderAt ?? this.reminderAt,
      amount: clearAmount ? null : amount ?? this.amount,
      financeType: financeType ?? this.financeType,
      todos: todos ?? this.todos,
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static double? _readAmount(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return null;
  }

  static List<TodoItem> _readTodos(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => TodoItem.fromMap(Map<String, dynamic>.from(item)))
        .where((item) => item.title.trim().isNotEmpty)
        .toList();
  }
}
