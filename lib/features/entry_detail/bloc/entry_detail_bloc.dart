import 'dart:async';
import 'package:brag_doc_manager/data/models/brag_entry_model.dart';
import 'package:brag_doc_manager/data/repositories/brag_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'entry_detail_event.dart';
part 'entry_detail_state.dart';

class EntryDetailBloc extends Bloc<EntryDetailEvent, EntryDetailState> {
  final BragRepository _bragRepository;

  EntryDetailBloc({required BragRepository bragRepository})
      : _bragRepository = bragRepository,
        super(const EntryDetailState()) {
    on<LoadEntryDetail>(_onLoadEntryDetail);
  }

  Future<void> _onLoadEntryDetail(
    LoadEntryDetail event,
    Emitter<EntryDetailState> emit,
  ) async {
    emit(state.copyWith(status: EntryDetailStatus.loading));
    try {
      final entry = await _bragRepository.getEntryById(event.entryId);
      if (entry != null) {
        emit(state.copyWith(status: EntryDetailStatus.success, entry: entry));
      } else {
        emit(state.copyWith(
          status: EntryDetailStatus.failure,
          errorMessage: 'Entry not found.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EntryDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
