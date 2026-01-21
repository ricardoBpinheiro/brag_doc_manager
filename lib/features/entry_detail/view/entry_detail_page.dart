import 'dart:convert';
import 'package:brag_doc_manager/data/models/brag_entry_model.dart';
import 'package:brag_doc_manager/features/entry_detail/bloc/entry_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EntryDetailPage extends StatelessWidget {
  const EntryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entry Detail')),
      body: BlocBuilder<EntryDetailBloc, EntryDetailState>(
        builder: (context, state) {
          if (state.status == EntryDetailStatus.loading ||
              state.status == EntryDetailStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == EntryDetailStatus.failure ||
              state.entry == null) {
            return Center(
              child: Text(state.errorMessage ?? 'Failed to load entry.'),
            );
          }

          final entry = state.entry!;
          final quillController = QuillController(
            document: Document.fromJson(jsonDecode(entry.content)),
            selection: const TextSelection.collapsed(offset: 0),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(entry.createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry.type.label,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: entry.type.color),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                QuillEditor.basic(
                  controller: quillController,
                  config: QuillEditorConfig(
                    // readOnly: true,
                    showCursor: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<EntryDetailBloc, EntryDetailState>(
        builder: (context, state) {
          if (state.status == EntryDetailStatus.success &&
              state.entry != null) {
            return FloatingActionButton(
              onPressed: () async {
                final result = await context.push(
                  '/entry/${state.entry!.id}/edit',
                );
                if (result == true) {
                  // ignore: use_build_context_synchronously
                  context.read<EntryDetailBloc>().add(
                    LoadEntryDetail(state.entry!.id!),
                  );
                }
              },
              child: const Icon(Icons.edit),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
