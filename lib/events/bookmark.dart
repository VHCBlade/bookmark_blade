import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';

enum BookmarkEvent<T> {
  loadAll<void>(),
  addBookmarkCollection<BookmarkCollectionModel>(),
  updateBookmarkCollection<BookmarkCollectionModel>(),
  deleteBookmarkCollection<BookmarkCollectionModel>(),
  reorderBookmarkCollections<ListMovement<BookmarkCollectionModel>>(),

  // Edit
  selectBookmarkCollection<BookmarkCollectionModel?>(),
  changeBookmarkName<String>(),
  addBookmark<BookmarkModel>(),
  updateBookmark<BookmarkModel>(),
  reorderBookmarks<ListMovement<BookmarkModel>>(),
  deleteBookmark<BookmarkModel>(),

  // Share
  shareBookmarkCollection<BookmarkCollectionModel>(),
  updateSharedBookmarkCollection<BookmarkCollectionModel>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
