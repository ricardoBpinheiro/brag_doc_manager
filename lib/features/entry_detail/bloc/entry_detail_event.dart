part of 'entry_detail_bloc.dart';

abstract class EntryDetailEvent {
  const EntryDetailEvent();
}

class LoadEntryDetail extends EntryDetailEvent {
  final String entryId;
  const LoadEntryDetail(this.entryId);
}
