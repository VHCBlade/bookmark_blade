import 'package:bookmark_blade/bloc/bookmark/bookmark.dart';
import 'package:bookmark_blade/bloc/bookmark/edit.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/model/bookmark.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

class MainBookmarkCollectionScreen extends StatelessWidget {
  const MainBookmarkCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationBloc = context.watchBloc<MainNavigationBloc<String>>();
    final node = navigationBloc.deepNavigationMap["bookmark"];
    if (node != null) {
      final id = BookmarkCollectionModel().prefixTypeForId(node.value);
      final selectedBookmark =
          context.selectBloc<BookmarkBloc, BookmarkCollectionModel?>(
              (bloc) => bloc.bookmarkMap.map[id]);
      Future.delayed(Duration.zero).then((_) => context.fireEvent(
          BookmarkEvent.selectBookmarkCollection.event, selectedBookmark));
    }

    return const BookmarkCollectionScreen();
  }
}

class BookmarkCollectionScreen extends StatelessWidget {
  const BookmarkCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<BookmarkEditBloc>();
    return Scaffold(
      appBar: AppBar(
        leading: const BlocBackButton(),
        title: Text(bloc.model?.bookmarkName ?? "Unknown"),
      ),
    );
  }
}
