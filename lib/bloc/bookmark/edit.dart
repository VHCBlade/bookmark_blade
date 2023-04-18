import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/model/bookmark.dart';
import 'package:event_bloc/event_bloc.dart';

class BookmarkEditBloc extends Bloc {
  BookmarkEditBloc({required super.parentChannel}) {
    eventChannel.addEventListener<BookmarkCollectionModel?>(
        BookmarkEvent.selectBookmarkCollection.event, (p0, p1) => model = p1);
    eventChannel.addEventListener<String>(
        BookmarkEvent.changeBookmarkName.event, (p0, p1) => setName(p1));
    eventChannel.addEventListener<BookmarkModel>(
        BookmarkEvent.addBookmark.event, (p0, p1) => addBookmark(p1));
  }

  BookmarkCollectionModel? _model;
  BookmarkCollectionModel? get model => _model;
  set model(BookmarkCollectionModel? model) {
    if (model == _model) {
      return;
    }
    _model = model;
    updateBloc();
  }

  bool get hasModel => model != null;

  void update() {
    if (hasModel) {
      eventChannel.fireEvent(
          BookmarkEvent.updateBookmarkCollection.event, model!);
    }
    updateBloc();
  }

  void setName(String name) {
    if (!hasModel) {
      return;
    }
    final newName = name.trim();

    if (newName.isEmpty || newName == model!.bookmarkName) {
      return;
    }

    model!.bookmarkName = newName;
    update();
  }

  void addBookmark(BookmarkModel bookmark) {
    if (!hasModel) {
      return;
    }

    if (bookmark.url.trim().isEmpty || bookmark.name.trim().isEmpty) {
      return;
    }
    bookmark.url = bookmark.url.trim();
    bookmark.name = bookmark.name.trim();
    model!.bookmarkMap[bookmark.autoGenId] = bookmark;
    model!.bookmarkOrder = [
      bookmark.autoGenId,
      ...model!.bookmarkOrder.where((element) => element != bookmark.autoGenId)
    ];

    update();
  }
}
