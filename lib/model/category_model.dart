import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final bool isSynced;
  final bool isDeleted;

  const CategoryModel({
    required this.id,
    required this.name,
    this.isSynced = false,
    this.isDeleted = false,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory CategoryModel.fromMap(Map<String, Object?> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isSynced: (map['is_synced'] as int) == 1,
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [id, name, isSynced, isDeleted];
}
