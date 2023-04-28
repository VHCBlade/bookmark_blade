import 'package:bookmark_blade/bloc/external/external_bookmark.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/events/external_bookmark.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_modals/event_modals.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

class ExternalBookmarkCollectionListScreen extends StatelessWidget {
  const ExternalBookmarkCollectionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<ExternalBookmarkBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("External Bookmarks"),
      ),
      body: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          final bookmarkCollection = bloc.bookmarkCollectionAt(index)!;
          return BookmarkListWidget(
            key: ValueKey(bookmarkCollection.id),
            bookmark: bookmarkCollection,
            showReorderable: true,
            index: index,
          );
        },
        itemCount: bloc.bookmarkList.list.length,
        onReorder: (int oldIndex, int newIndex) => context.fireEvent(
          BookmarkEvent.reorderBookmarkCollections.event,
          ListMovement(bloc.bookmarkCollectionAt(oldIndex)!, newIndex),
        ),
      ),
    );
  }
}

class BookmarkListWidget extends StatelessWidget {
  final BookmarkCollectionModel bookmark;
  final bool showReorderable;
  final int? index;

  const BookmarkListWidget({
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
        onTap: () => context.fireEvent(NavigationEvent.pushDeepNavigation.event,
            bookmark.id!.split("::")[1]),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(bookmark.bookmarkName),
              Expanded(child: Container()),
              IconButton(
                  onPressed: () => showEventDialog<bool>(
                        context: context,
                        builder: (_) => const ConfirmationDialog(
                            title: Text(
                                "Are you sure you want to delete this external bookmark collection?")),
                        onResponse: (BlocEventChannel eventChannel, response) =>
                            response
                                ? eventChannel.fireEvent(
                                    ExternalBookmarkEvent
                                        .deleteBookmarkCollection.event,
                                    bookmark)
                                : null,
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
