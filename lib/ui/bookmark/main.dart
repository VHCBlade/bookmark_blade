import 'package:bookmark_blade/bloc/bookmark.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/model/bookmark.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_modals/event_modals.dart';
import 'package:flutter/material.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BookmarkListScreen();
  }
}

class BookmarkListScreen extends StatelessWidget {
  const BookmarkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<BookmarkBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookmarks"),
      ),
      body: ReorderableListView.builder(
        itemBuilder: (context, index) {
          if (index >= bloc.bookmarkList.list.length) {
            return const SizedBox(key: ValueKey("Padding"), height: 30);
          }
          final bookmarkCollection = bloc.bookmarkCollectionAt(index)!;

          return BookmarkListWidget(
            key: ValueKey(bookmarkCollection.id),
            bookmark: bookmarkCollection,
          );
        },
        itemCount: bloc.bookmarkList.list.length + 1,
        onReorder: (int oldIndex, int newIndex) {
          print(oldIndex);
          print(newIndex);
        },
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

  const BookmarkListWidget({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(bookmark.bookmarkName));
  }
}
