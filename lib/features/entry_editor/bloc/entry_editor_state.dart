part of 'entry_editor_bloc.dart';

enum EntryEditorStatus { initial, loading, success, failure, saving, saved }

class EntryEditorState {
  const EntryEditorState({
    this.status = EntryEditorStatus.initial,
    this.entry,
    this.errorMessage,
  });

  final EntryEditorStatus status;
  final BragEntryModel? entry;
  final String? errorMessage;

  EntryEditorState copyWith({
    EntryEditorStatus? status,
    BragEntryModel? entry,
    String? errorMessage,
  }) {
    return EntryEditorState(
      status: status ?? this.status,
      entry: entry ?? this.entry,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
