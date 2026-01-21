part of 'entry_editor_bloc.dart';

abstract class EntryEditorEvent {
  const EntryEditorEvent();
}

class LoadEntry extends EntryEditorEvent {
  final String id;
  const LoadEntry(this.id);
}

class SaveEntry extends EntryEditorEvent {
  final String title;
  final String content;
  final String? entryId;
  final EntryType type;
  final DateTime createdAt;

  const SaveEntry({
    required this.title,
    required this.content,
    this.entryId,
    required this.type,
    required this.createdAt,
  });
}
