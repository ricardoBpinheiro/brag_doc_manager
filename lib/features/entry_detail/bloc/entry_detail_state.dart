part of 'entry_detail_bloc.dart';

enum EntryDetailStatus { initial, loading, success, failure }

class EntryDetailState {
  final EntryDetailStatus status;
  final BragEntryModel? entry;
  final String? errorMessage;

  const EntryDetailState({
    this.status = EntryDetailStatus.initial,
    this.entry,
    this.errorMessage,
  });

  EntryDetailState copyWith({
    EntryDetailStatus? status,
    BragEntryModel? entry,
    String? errorMessage,
  }) {
    return EntryDetailState(
      status: status ?? this.status,
      entry: entry ?? this.entry,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
