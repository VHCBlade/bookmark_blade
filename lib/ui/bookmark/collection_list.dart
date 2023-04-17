import 'package:bookmark_blade/bloc/bookmark.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/model/bookmark.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_modals/event_modals.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

class BookmarkCollectionListScreen extends StatelessWidget {
  const BookmarkCollectionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<BookmarkBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookmarks"),
      ),
      body: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          if (index >= bloc.bookmarkList.list.length) {
            return const SizedBox(key: ValueKey("Padding"), height: 30);
          }
          final bookmarkCollection = bloc.bookmarkCollectionAt(index)!;

          return BookmarkListWidget(
            key: ValueKey(bookmarkCollection.id),
            bookmark: bookmarkCollection,
            showReorderable: true,
            index: index,
          );
        },
        itemCount: bloc.bookmarkList.list.length + 1,
        onReorder: (int oldIndex, int newIndex) => context.fireEvent(
          BookmarkEvent.reorderBookmarkCollections.event,
          ListMovement(bloc.bookmarkCollectionAt(oldIndex)!, newIndex),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,
            color: Theme.of(context).textTheme.displayMedium?.color),
        onPressed: () => showEventDialog(
          context: context,
          onResponse: (BlocEventChannel eventChannel, response) {
            final title = (response as String).trim();
            if (title.isEmpty) {
              return;
            }
            eventChannel.fireEvent<BookmarkCollectionModel>(
                BookmarkEvent.addBookmarkCollection.event,
                BookmarkCollectionModel()
                  ..lastEdited = DateTime.now()
                  ..bookmarkName = title);
          },
          builder: (_) => const StringEditModal(title: Text("Set Title")),
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
                                "Are you sure you want to delete this bookmark collection?")),
                        onResponse: (BlocEventChannel eventChannel, response) =>
                            response
                                ? eventChannel.fireEvent(
                                    BookmarkEvent
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
