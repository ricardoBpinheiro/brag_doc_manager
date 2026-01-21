import 'dart:async';

import 'package:brag_doc_manager/data/models/brag_entry_model.dart';
import 'package:brag_doc_manager/data/repositories/brag_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final BragRepository _bragRepository;
  StreamSubscription<List<BragEntryModel>>? _entriesSubscription;

  TimelineBloc({required BragRepository bragRepository})
    : _bragRepository = bragRepository,
      super(const TimelineState()) {
    on<LoadTimeline>(_onLoadTimeline);
    on<_EntriesUpdated>(_onEntriesUpdated);
    on<DeleteEntry>(_onDeleteEntry);
    on<YearFilterChanged>(_onYearFilterChanged);
    on<MonthFilterChanged>(_onMonthFilterChanged);
    on<TypeFilterChanged>(_onTypeFilterChanged);
    on<ClearFilters>(_onClearFilters);
  }

  @override
  Future<void> close() {
    _entriesSubscription?.cancel();
    return super.close();
  }

  void _onLoadTimeline(LoadTimeline event, Emitter<TimelineState> emit) {
    emit(state.copyWith(status: TimelineStatus.loading));
    _entriesSubscription?.cancel();
    _entriesSubscription = _bragRepository.getAllEntries().listen(
      (entries) => add(_EntriesUpdated(entries)),
      onError: (error) => emit(
        state.copyWith(
          status: TimelineStatus.failure,
          errorMessage: error.toString(),
        ),
      ),
    );
  }

  void _onEntriesUpdated(_EntriesUpdated event, Emitter<TimelineState> emit) {
    final years = event.entries.map((e) => e.createdAt.year).toSet().toList()
      ..sort();
    final newState = state.copyWith(
      status: TimelineStatus.success,
      allEntries: event.entries,
      availableYears: years,
    );
    emit(_applyFilters(newState));
  }

  Future<void> _onDeleteEntry(
    DeleteEntry event,
    Emitter<TimelineState> emit,
  ) async {
    try {
      await _bragRepository.deleteEntry(event.id);
    } catch (_) {}
  }

  void _onYearFilterChanged(
    YearFilterChanged event,
    Emitter<TimelineState> emit,
  ) {
    final newState = state.copyWith(
      selectedYears: event.years,
      clearSelectedMonth: true,
    );
    emit(_applyFilters(newState));
  }

  void _onMonthFilterChanged(
    MonthFilterChanged event,
    Emitter<TimelineState> emit,
  ) {
    final newState = state.copyWith(selectedMonths: event.months);
    emit(_applyFilters(newState));
  }

  void _onTypeFilterChanged(
    TypeFilterChanged event,
    Emitter<TimelineState> emit,
  ) {
    final newState = state.copyWith(selectedTypes: event.types);
    emit(_applyFilters(newState));
  }

  void _onClearFilters(ClearFilters event, Emitter<TimelineState> emit) {
    final newState = state.copyWith(
      clearSelectedYear: true,
      clearSelectedMonth: true,
      clearSelectedType: true,
    );
    emit(_applyFilters(newState));
  }

  TimelineState _applyFilters(TimelineState state) {
    List<BragEntryModel> filteredEntries = List.from(state.allEntries);

    if (state.selectedYears != null && state.selectedYears!.isNotEmpty) {
      filteredEntries = filteredEntries
          .where((entry) => state.selectedYears!.contains(entry.createdAt.year))
          .toList();
    }

    if (state.selectedMonths != null && state.selectedMonths!.isNotEmpty) {
      filteredEntries = filteredEntries
          .where(
            (entry) => state.selectedMonths!.contains(entry.createdAt.month),
          )
          .toList();
    }

    if (state.selectedTypes != null && state.selectedTypes!.isNotEmpty) {
      filteredEntries = filteredEntries
          .where((entry) => state.selectedTypes!.contains(entry.type))
          .toList();
    }

    return state.copyWith(entries: filteredEntries);
  }
}
