import 'package:bookmark_blade/bloc/bookmark/bookmark.dart';
import 'package:bookmark_blade/bloc/bookmark/edit.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/model/bookmark.dart';
import 'package:bookmark_blade/ui/bookmark/bookmark_modal.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_modals/event_modals.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

class BookmarkCollectionScreen extends StatelessWidget {
  const BookmarkCollectionScreen({super.key});

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

    return const EditBookmarkCollectionScreen();
  }
}

class EditBookmarkCollectionScreen extends StatelessWidget {
  const EditBookmarkCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<BookmarkEditBloc>();
    return Scaffold(
      appBar: AppBar(
        leading: const BlocBackButton(),
        title: Text(bloc.model?.bookmarkName ?? "Unknown"),
        actions: [
          if (bloc.hasModel)
            IconButton(
                onPressed: () => showEventDialog<String>(
                      context: context,
                      onResponse: (BlocEventChannel eventChannel, response) =>
                          eventChannel.fireEvent<String>(
                              BookmarkEvent.changeBookmarkName.event, response),
                      builder: (_) => StringEditModal(
                        title: const Text("Set Title"),
                        initialValue: bloc.model!.bookmarkName,
                      ),
                    ),
                icon: const Icon(Icons.edit)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,
            color: Theme.of(context).textTheme.displayMedium?.color),
        onPressed: () => showEventDialog<BookmarkModel>(
          context: context,
          onResponse: (BlocEventChannel eventChannel, BookmarkModel response) {
            eventChannel.fireEvent<BookmarkModel>(
                BookmarkEvent.addBookmark.event, response);
          },
          builder: (_) => const BookmarkModal(),
        ),
      ),
      body: !bloc.hasModel
          ? const Text(
              "Unable to find the given Bookmark Collection",
              textAlign: TextAlign.center,
            )
          : ListView.builder(
              itemBuilder: (context, index) => Text(bloc
                  .model!.bookmarkMap[bloc.model!.bookmarkOrder[index]]!.name),
              itemCount: bloc.model!.bookmarkOrder.length,
            ),
    );
  }
}
