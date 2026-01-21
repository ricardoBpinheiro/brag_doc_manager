part of 'timeline_bloc.dart';

enum TimelineStatus { initial, loading, success, failure }

class TimelineState {
  const TimelineState({
    this.status = TimelineStatus.initial,
    this.entries = const [],
    this.allEntries = const [],
    this.availableYears = const [],
    this.selectedYears,
    this.selectedMonths,
    this.selectedTypes,
    this.errorMessage,
  });

  final TimelineStatus status;
  final List<BragEntryModel> entries;
  final List<BragEntryModel> allEntries;
  final List<int> availableYears;
  final List<int>? selectedYears;
  final List<int>? selectedMonths;
  final List<EntryType>? selectedTypes;
  final String? errorMessage;

  TimelineState copyWith({
    TimelineStatus? status,
    List<BragEntryModel>? entries,
    List<BragEntryModel>? allEntries,
    List<int>? availableYears,
    List<int>? selectedYears,
    List<int>? selectedMonths,
    List<EntryType>? selectedTypes,
    bool clearSelectedYear = false,
    bool clearSelectedMonth = false,
    bool clearSelectedType = false,
    String? errorMessage,
  }) {
    return TimelineState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      allEntries: allEntries ?? this.allEntries,
      availableYears: availableYears ?? this.availableYears,
      selectedYears: clearSelectedYear
          ? null
          : selectedYears ?? this.selectedYears,
      selectedMonths: clearSelectedMonth
          ? null
          : selectedMonths ?? this.selectedMonths,
      selectedTypes: clearSelectedType
          ? null
          : selectedTypes ?? this.selectedTypes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
