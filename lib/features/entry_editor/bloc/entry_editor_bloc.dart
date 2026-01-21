import 'dart:async';

import 'package:brag_doc_manager/data/models/brag_entry_model.dart';
import 'package:brag_doc_manager/data/repositories/brag_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'entry_editor_event.dart';
part 'entry_editor_state.dart';

class EntryEditorBloc extends Bloc<EntryEditorEvent, EntryEditorState> {
  final BragRepository _bragRepository;

  EntryEditorBloc({required BragRepository bragRepository})
      : _bragRepository = bragRepository,
        super(const EntryEditorState()) {
    on<LoadEntry>(_onLoadEntry);
    on<SaveEntry>(_onSaveEntry);
  }

  Future<void> _onLoadEntry(
    LoadEntry event,
    Emitter<EntryEditorState> emit,
  ) async {
    emit(state.copyWith(status: EntryEditorStatus.loading));
    try {
      final entry = await _bragRepository.getEntryById(event.id);
      if (entry != null) {
        emit(state.copyWith(status: EntryEditorStatus.success, entry: entry));
      } else {
        emit(state.copyWith(
            status: EntryEditorStatus.failure,
            errorMessage: 'Entry not found.'));
      }
    } catch (e) {
      emit(state.copyWith(
          status: EntryEditorStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onSaveEntry(
    SaveEntry event,
    Emitter<EntryEditorState> emit,
  ) async {
    emit(state.copyWith(status: EntryEditorStatus.saving));
    try {
      final entry = BragEntryModel(
        id: event.entryId,
        title: event.title,
        content: event.content,
        type: event.type,
        createdAt: event.createdAt,
      );

      if (event.entryId == null) {
        await _bragRepository.createEntry(entry);
      } else {
        await _bragRepository.updateEntry(entry);
      }
      emit(state.copyWith(status: EntryEditorStatus.saved));
    } catch (e) {
      emit(state.copyWith(
          status: EntryEditorStatus.failure, errorMessage: e.toString()));
    }
  }
}
