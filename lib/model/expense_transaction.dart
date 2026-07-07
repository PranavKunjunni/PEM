import 'package:equatable/equatable.dart';

class ExpenseTransaction extends Equatable {
  final String id;
  final double amount;
  final String note;
  final String type;
  final String categoryId;
  final String categoryName;
  final String timestamp;
  final bool isSynced;
  final bool isDeleted;

  const ExpenseTransaction({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.timestamp,
    this.isSynced = false,
    this.isDeleted = false,
  });

  bool get isDebit => type.toLowerCase() == 'debit';

  bool get isCredit => type.toLowerCase() == 'credit';

  ExpenseTransaction copyWith({
    String? id,
    double? amount,
    String? note,
    String? type,
    String? categoryId,
    String? categoryName,
    String? timestamp,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory ExpenseTransaction.fromMap(Map<String, Object?> map) {
    return ExpenseTransaction(
      id: map['id'] as String,
      amount: map['amount'] is int ? (map['amount'] as int).toDouble() : map['amount'] as double,
      note: map['note'] as String,
      type: map['type'] as String,
      categoryId: map['category_id'] as String,
      categoryName: map['category_name'] as String? ?? 'Uncategorized',
      timestamp: map['timestamp'] as String,
      isSynced: (map['is_synced'] as int) == 1,
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type,
      'category_id': categoryId,
      'timestamp': timestamp,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        note,
        type,
        categoryId,
        categoryName,
        timestamp,
        isSynced,
        isDeleted,
      ];
}
