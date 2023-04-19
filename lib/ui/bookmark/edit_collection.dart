import 'package:bookmark_blade/bloc/bookmark/bookmark.dart';
import 'package:bookmark_blade/bloc/bookmark/edit.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/model/bookmark.dart';
import 'package:bookmark_blade/ui/bookmark/bookmark_modal.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_essay/event_essay.dart';
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

class BookmarkLinkWidget extends StatelessWidget {
  final BookmarkModel bookmark;
  final bool showReorderable;
  final int? index;

  const BookmarkLinkWidget({
    super.key,
    required this.bookmark,
    required this.showReorderable,
    this.index,
  }) : assert(!showReorderable || index != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: GestureDetector(
        onTap: () => showEventDialog<BookmarkModel>(
          context: context,
          onResponse: (BlocEventChannel eventChannel, BookmarkModel response) {
            eventChannel.fireEvent<BookmarkModel>(
              BookmarkEvent.updateBookmark.event,
              bookmark
                ..name = response.name
                ..url = response.url,
            );
          },
          builder: (_) => BookmarkModal(initialValue: bookmark),
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.name,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(bookmark.url, textAlign: TextAlign.start),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                  onPressed: () =>
                      context.fireEvent(EssayEvent.url.event, bookmark.url),
                  child: const Text("Launch")),
              IconButton(
                  onPressed: () => showEventDialog<bool>(
                        context: context,
                        builder: (_) => const ConfirmationDialog(
                            title: Text(
                                "Are you sure you want to delete this bookmark?")),
                        onResponse: (BlocEventChannel eventChannel, response) =>
                            response ? null : null,
                      ),
                  icon: const Icon(Icons.delete)),
              if (showReorderable)
                ReorderableDragStartListener(
                  index: index!,
                  child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Icon(Icons.reorder)),
                )
            ]),
          ),
        ),
      ),
    );
  }
}
