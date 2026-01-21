import 'package:brag_doc_manager/core/utils/snackbar_helper.dart';
import 'package:brag_doc_manager/data/models/brag_entry_model.dart';
import 'package:brag_doc_manager/features/timeline/bloc/timeline_bloc.dart';
import 'package:brag_doc_manager/features/timeline/view/widgets/entry_card.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brag Doc')),
      body: BlocConsumer<TimelineBloc, TimelineState>(
        listener: (context, state) {
          if (state.status == TimelineStatus.failure) {
            showError(context, state.errorMessage ?? 'Not found');
          }
        },
        builder: (context, state) {
          if (state.status == TimelineStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _FilterControls(),
              Expanded(child: _TimelineContent()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/entry/new');
          // ignore: use_build_context_synchronously
          context.read<TimelineBloc>().add(const LoadTimeline());
        },
        icon: const Icon(Icons.add),
        label: const Text('New entry'),
      ),
    );
  }
}

class _FilterControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineBloc, TimelineState>(
      builder: (context, state) {
        if (state.allEntries.isEmpty) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return Padding(
              padding: const EdgeInsets.all(12),
              child: isMobile
                  ? _MobileFilters(state: state)
                  : _DesktopFilters(state: state),
            );
          },
        );
      },
    );
  }
}

class _MobileFilters extends StatefulWidget {
  final TimelineState state;

  const _MobileFilters({required this.state});

  @override
  State<_MobileFilters> createState() => _MobileFiltersState();
}

class _MobileFiltersState extends State<_MobileFilters> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 8,
              ),
              _YearFilter(widget.state),
              const SizedBox(height: 12),
              _MonthFilter(widget.state),
              const SizedBox(height: 12),
              _TypeFilter(widget.state),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Limpar filtros'),
                onPressed: () {
                  context.read<TimelineBloc>().add(const ClearFilters());
                },
              ),
            ],
          )
      ],
    );
  }
}

class _TypeFilter extends StatelessWidget {
  final TimelineState state;

  const _TypeFilter(this.state);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<EntryType>.multiSelection(
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Types',
          border: OutlineInputBorder(),
        ),
      ),
      selectedItems: state.selectedTypes ?? [],
      itemAsString: (type) => type.label,
      compareFn: (i1, i2) => i1 == i2,
      onChanged: (types) {
        context.read<TimelineBloc>().add(TypeFilterChanged(types));
      },
      items: (filter, loadProps) => EntryType.values,
    );
  }
}

class _MonthFilter extends StatelessWidget {
  final TimelineState state;

  const _MonthFilter(this.state);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<int>.multiSelection(
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Month',
          border: OutlineInputBorder(),
        ),
      ),
      selectedItems: state.selectedMonths ?? [],
      itemAsString: (month) => DateFormat.MMMM().format(DateTime(0, month)),
      compareFn: (i1, i2) => i1 == i2,
      onChanged: (months) {
        context.read<TimelineBloc>().add(MonthFilterChanged(months));
      },
      items: (filter, loadProps) => List.generate(12, (index) => index + 1),
    );
  }
}

class _YearFilter extends StatelessWidget {
  final TimelineState state;

  const _YearFilter(this.state);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<int>.multiSelection(
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Year',
          border: OutlineInputBorder(),
        ),
      ),
      selectedItems: state.selectedYears ?? [],
      itemAsString: (year) => year.toString(),
      compareFn: (i1, i2) => i1 == i2,
      items: (filter, loadProps) => state.availableYears,
      onChanged: (years) {
        context.read<TimelineBloc>().add(YearFilterChanged(years));
      },
    );
  }
}

class _DesktopFilters extends StatelessWidget {
  final TimelineState state;

  const _DesktopFilters({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _YearFilter(state)),
        const SizedBox(width: 12),
        Expanded(child: _MonthFilter(state)),
        const SizedBox(width: 12),
        Expanded(child: _TypeFilter(state)),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Limpar filtros',
          icon: const Icon(Icons.filter_alt_off),
          onPressed: () {
            context.read<TimelineBloc>().add(const ClearFilters());
          },
        ),
      ],
    );
  }
}

class _TimelineContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineBloc, TimelineState>(
      builder: (context, state) {
        if (state.allEntries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No entries yet.\nTap the + button to create one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        if (state.entries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No entries found for the selected filter.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<TimelineBloc>().add(const LoadTimeline());
          },
          child: ListView.builder(
            itemCount: state.entries.length,
            itemBuilder: (context, index) {
              final entry = state.entries[index];
              final isFirst = index == 0;
              final isLast = index == state.entries.length - 1;

              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.15,
                isFirst: isFirst,
                isLast: isLast,
                indicatorStyle: IndicatorStyle(
                  width: 20,
                  color: entry
                      .type
                      .color, // Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.all(6),
                ),
                beforeLineStyle: LineStyle(
                  color: Theme.of(context).colorScheme.primary,
                  thickness: 2,
                ),
                endChild: Card(
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8,
                  ),
                  child: EntryCard(
                    entry: entry,
                    onDelete: () {
                      if (entry.id != null) {
                        _showDeleteDialog(context, entry.id!);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

void _showDeleteDialog(BuildContext context, String id) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text(
          'Are you sure you want to delete this entry? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<TimelineBloc>().add(DeleteEntry(id));
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
