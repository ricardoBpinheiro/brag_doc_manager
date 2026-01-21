import 'dart:convert';
import 'package:brag_doc_manager/core/utils/snackbar_helper.dart';
import 'package:brag_doc_manager/data/models/brag_entry_model.dart';
import 'package:brag_doc_manager/features/entry_editor/bloc/entry_editor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EntryEditorPage extends StatefulWidget {
  const EntryEditorPage({super.key, this.entryId});

  final String? entryId;

  @override
  State<EntryEditorPage> createState() => _EntryEditorPageState();
}

class _EntryEditorPageState extends State<EntryEditorPage> {
  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  EntryType _selectedType = EntryType.newLearning;

  @override
  void initState() {
    super.initState();
    if (widget.entryId == null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  void _onSavePressed() {
    final plainTextContent = jsonEncode(
      _controller.document.toDelta().toJson(),
    );
    context.read<EntryEditorBloc>().add(
      SaveEntry(
        entryId: widget.entryId,
        title: _titleController.text,
        content: plainTextContent,
        createdAt: _selectedDate,
        type: _selectedType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EntryEditorBloc, EntryEditorState>(
      listener: (context, state) {
        if (state.status == EntryEditorStatus.saved) {
          context.pop(true);
        }
        if (state.status == EntryEditorStatus.failure) {
          showError(context, state.errorMessage ?? 'An error occurred.');
        }
        if (state.status == EntryEditorStatus.success && state.entry != null) {
          _titleController.text = state.entry!.title;
          _selectedDate = state.entry!.createdAt;
          _selectedType = state.entry!.type;
          _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
          final doc = Document.fromJson(jsonDecode(state.entry!.content));
          _controller.document = doc;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.entryId == null ? 'New Entry' : 'Edit Entry'),
          actions: [
            BlocBuilder<EntryEditorBloc, EntryEditorState>(
              builder: (context, state) {
                if (state.status == EntryEditorStatus.saving) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: CircularProgressIndicator(),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _onSavePressed,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<EntryEditorBloc, EntryEditorState>(
          builder: (context, state) {
            if (state.status == EntryEditorStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    children: EntryType.values.map((type) {
                      return ChoiceChip(
                        label: Text(type.label),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  QuillSimpleToolbar(
                    controller: _controller,
                    config: QuillSimpleToolbarConfig(
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        bold: QuillToolbarToggleStyleButtonOptions(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  QuillEditor.basic(
                    controller: _controller,
                    config: QuillEditorConfig(
                      scrollable: false,
                      // readOnly: state.status == EntryEditorStatus.saving,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
