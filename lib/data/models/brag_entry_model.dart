import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class BragEntryModel {
  final String? id;
  final String title;
  final String content;
  final EntryType type;
  final DateTime createdAt;

  BragEntryModel({
    this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  factory BragEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return BragEntryModel(
      id: snapshot.id,
      title: data?['title'],
      content: data?['content'],
      type: EntryTypeExtension.fromValue(data?['type']),
      createdAt: (data?['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'type': type.value,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  BragEntryModel copyWith({
    String? id,
    String? title,
    String? content,
    EntryType? type,
    DateTime? createdAt,
  }) {
    return BragEntryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum EntryType {
  newLearning, // Novo aprendizado
  reinforcement, // Reforço de algo que já sabia
  achievement, // Conquista - entrega
  improvement, // Melhoria contínua
}

extension EntryTypeExtension on EntryType {
  String get label {
    switch (this) {
      case EntryType.newLearning:
        return 'Novo aprendizado';
      case EntryType.reinforcement:
        return 'Reforço';
      case EntryType.achievement:
        return 'Conquista';
      case EntryType.improvement:
        return 'Melhoria';
    }
  }

  String get value {
    switch (this) {
      case EntryType.newLearning:
        return 'new_learning';
      case EntryType.reinforcement:
        return 'reinforcement';
      case EntryType.achievement:
        return 'achievement';
      case EntryType.improvement:
        return 'improvement';
    }
  }

  static EntryType fromValue(String value) {
    switch (value) {
      case 'new_learning':
        return EntryType.newLearning;
      case 'reinforcement':
        return EntryType.reinforcement;
      case 'achievement':
        return EntryType.achievement;
      case 'improvement':
        return EntryType.improvement;
      default:
        return EntryType.newLearning;
    }
  }

  Color get color {
    switch (this) {
      case EntryType.newLearning:
        return const Color(0xFF1E88E5);
      case EntryType.reinforcement:
        return const Color(0xFF5E35B1);
      case EntryType.achievement:
        return const Color(0xFF43A047);
      case EntryType.improvement:
        return const Color(0xFFFB8C00);
    }
  }
}
