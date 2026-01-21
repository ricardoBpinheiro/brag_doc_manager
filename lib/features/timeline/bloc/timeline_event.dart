part of 'timeline_bloc.dart';

abstract class TimelineEvent {
  const TimelineEvent();
}

class LoadTimeline extends TimelineEvent {
  const LoadTimeline();
}

class _EntriesUpdated extends TimelineEvent {
  final List<BragEntryModel> entries;
  const _EntriesUpdated(this.entries);
}

class DeleteEntry extends TimelineEvent {
  final String id;
  const DeleteEntry(this.id);
}

class YearFilterChanged extends TimelineEvent {
  final List<int>? years;
  const YearFilterChanged(this.years);
}

class MonthFilterChanged extends TimelineEvent {
  final List<int>? months;
  const MonthFilterChanged(this.months);
}

class TypeFilterChanged extends TimelineEvent {
  final List<EntryType>? types;
  const TypeFilterChanged(this.types);
}

class ClearFilters extends TimelineEvent {
  const ClearFilters();
}
