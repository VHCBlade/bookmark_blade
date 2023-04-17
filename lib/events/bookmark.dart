import 'package:bookmark_blade/model/bookmark.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';

enum BookmarkEvent<T> {
  loadAll<void>(),
  addBookmarkCollection<BookmarkCollectionModel>(),
  updateBookmarkCollection<BookmarkCollectionModel>(),
  deleteBookmarkCollection<BookmarkCollectionModel>(),
  reorderBookmarkCollections<ListMovement<BookmarkCollectionModel>>(),

  selectBookmarkCollection<BookmarkCollectionModel?>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
