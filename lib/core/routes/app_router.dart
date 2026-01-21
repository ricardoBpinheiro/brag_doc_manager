import 'package:brag_doc_manager/core/di/service_locator.dart';
import 'package:brag_doc_manager/data/repositories/brag_repository.dart';
import 'package:brag_doc_manager/features/entry_detail/bloc/entry_detail_bloc.dart';
import 'package:brag_doc_manager/features/entry_detail/view/entry_detail_page.dart';
import 'package:brag_doc_manager/features/entry_editor/bloc/entry_editor_bloc.dart';
import 'package:brag_doc_manager/features/entry_editor/view/entry_editor_page.dart';
import 'package:brag_doc_manager/features/timeline/bloc/timeline_bloc.dart';
import 'package:brag_doc_manager/features/timeline/view/timeline_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
              create: (context) => TimelineBloc(
                bragRepository: getIt<BragRepository>(),
              )..add(const LoadTimeline()),
              child: const TimelinePage(),
            ),
        routes: [
          GoRoute(
            path: 'entry/new',
            builder: (context, state) => BlocProvider(
              create: (context) => EntryEditorBloc(
                bragRepository: getIt<BragRepository>(),
              ),
              child: const EntryEditorPage(),
            ),
          ),
          GoRoute(
              path: 'entry/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return BlocProvider(
                  create: (context) => EntryDetailBloc(
                    bragRepository: getIt<BragRepository>(),
                  )..add(LoadEntryDetail(id)),
                  child: const EntryDetailPage(),
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return BlocProvider(
                      create: (context) => EntryEditorBloc(
                        bragRepository: getIt<BragRepository>(),
                      )..add(LoadEntry(id)),
                      child: EntryEditorPage(entryId: id),
                    );
                  },
                ),
              ]),
        ]),
  ],
);
