import 'package:bookmark_blade/bloc/external/external_bookmark.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/events/external_bookmark.dart';
import 'package:bookmark_blade/ui/bookmark.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_modals/event_modals.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

class ExternalBookmarkCollectionScreen extends StatelessWidget {
  const ExternalBookmarkCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationBloc = context.watchBloc<MainNavigationBloc<String>>();
    final node = navigationBloc.deepNavigationMap["external"];
    if (node != null) {
      final id = BookmarkCollectionModel().prefixTypeForId(node.value);
      final selectedBookmark =
          context.selectBloc<ExternalBookmarkBloc, BookmarkCollectionModel?>(
              (bloc) => bloc.bookmarkMap.map[id]);
      Future.delayed(Duration.zero).then((_) => context.fireEvent(
          ExternalBookmarkEvent.selectBookmarkCollection.event,
          selectedBookmark));
    }

    return const EditBookmarkCollectionScreen();
  }
}

class EditBookmarkCollectionScreen extends StatelessWidget {
  const EditBookmarkCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<ExternalBookmarkBloc>();
    return Scaffold(
      appBar: AppBar(
        leading: const BlocBackButton(),
        title: Text(bloc.selected?.bookmarkName ?? "Unknown"),
        actions: [
          if (bloc.hasSelected) ...[
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => ShareLinkDialog(model: bloc.selected!));
                },
                icon: const Icon(Icons.share)),
            IconButton(
                onPressed: () {
                  showEventDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text("Copy Notice"),
                            content: const Text(
                                "This will copy this external bookmark into your bookmarks. This copy will no longer be related to this one, but you can edit it yourself."
                                "The app will navigate to the copied bookmark after you copy. Would you like to continue?",
                                textAlign: TextAlign.start),
                            actions: [
                              OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("No")),
                              ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Yes")),
                            ],
                          ),
                      onResponse: (eventChannel, val) {
                        if (!val) {
                          return;
                        }
                        final copied = BookmarkCollectionModel()
                          ..copy(bloc.selected!)
                          ..id = null
                          ..autoGenId;
                        eventChannel.fireEvent(
                            BookmarkEvent.addBookmarkCollection.event, copied);
                        eventChannel.fireEvent(
                            NavigationEvent.deepLinkNavigation.event,
                            "bookmark/${copied.idSuffix}");
                      });
                },
                icon: const Icon(Icons.copy)),
          ]
        ],
      ),
      body: !bloc.hasSelected
          ? const Text(
              "Unable to find the given Bookmark Collection",
              textAlign: TextAlign.center,
            )
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final bookmarkCollection = bloc.selected!;
                if (index >= bookmarkCollection.bookmarkOrder.length) {
                  return const SizedBox(key: ValueKey("Padding"), height: 30);
                }
                final bookmark = bookmarkCollection
                    .bookmarkMap[bookmarkCollection.bookmarkOrder[index]]!;

                return BookmarkLinkWidget(
                  key: ValueKey(bookmark.id),
                  bookmark: bookmark,
                  showReorderable: true,
                  external: false,
                  index: index,
                );
              },
              itemCount: bloc.selected!.bookmarkOrder.length,
              onReorder: (int oldIndex, int newIndex) {
                final selectedModel = bloc.selected!
                    .bookmarkMap[bloc.selected!.bookmarkOrder[oldIndex]]!;
                context.fireEvent(BookmarkEvent.reorderBookmarks.event,
                    ListMovement(selectedModel, newIndex));
              },
            ),
    );
  }
}
