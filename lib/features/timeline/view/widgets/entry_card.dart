import 'dart:convert';

import 'package:brag_doc_manager/data/models/brag_entry_model.dart';
import 'package:brag_doc_manager/features/timeline/bloc/timeline_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.entry, required this.onDelete});

  final BragEntryModel entry;
  final VoidCallback onDelete;

  String _extractPlainText(String deltaJson) {
    try {
      final document = Document.fromJson(jsonDecode(deltaJson));
      String plainText = document.toPlainText().trim();
      if (plainText.length > 100) {
        return '${plainText.substring(0, 100)}...';
      }
      return plainText;
    } catch (e) {
      return 'Error parsing content.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String contentPreview = _extractPlainText(entry.content);

    return InkWell(
      onTap: () async {
        await context.push('/entry/${entry.id}');
        // ignore: use_build_context_synchronously
        context.read<TimelineBloc>().add(const LoadTimeline());
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMMd().format(entry.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (contentPreview.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                contentPreview,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
