import 'package:bookmark_blade/bloc/bookmark/bookmark.dart';
import 'package:bookmark_blade/bloc/bookmark/edit.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/ui/bookmark.dart';
import 'package:bookmark_blade/ui/bookmark/bookmark_modal.dart';
import 'package:bookmark_blade/ui/bookmark/share_collection.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
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
          if (bloc.hasModel) ...[
            IconButton(
                onPressed: () {
                  context.fireEvent(
                      BookmarkEvent.shareBookmarkCollection.event, bloc.model!);
                  showDialog(
                      context: context,
                      builder: (_) =>
                          ShareCollectionDialog(model: bloc.model!));
                },
                icon: const Icon(Icons.share)),
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
          ]
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
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final bookmarkCollection = bloc.model!;
                if (index >= bookmarkCollection.bookmarkOrder.length) {
                  return const SizedBox(key: ValueKey("Padding"), height: 30);
                }
                final bookmark = bookmarkCollection
                    .bookmarkMap[bookmarkCollection.bookmarkOrder[index]]!;

                return BookmarkLinkWidget(
                  key: ValueKey(bookmark.id),
                  bookmark: bookmark,
                  showReorderable: true,
                  index: index,
                );
              },
              itemCount: bloc.model!.bookmarkOrder.length,
              onReorder: (int oldIndex, int newIndex) {
                final selectedModel = bloc
                    .model!.bookmarkMap[bloc.model!.bookmarkOrder[oldIndex]]!;
                context.fireEvent(BookmarkEvent.reorderBookmarks.event,
                    ListMovement(selectedModel, newIndex));
              },
            ),
    );
  }
}
