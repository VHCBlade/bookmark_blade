import 'package:bookmark_blade/model/bookmark.dart';
import 'package:event_bloc/event_bloc.dart';

class ListMovement<T> {
  final T moved;
  final int to;

  ListMovement(this.moved, this.to);
}

enum BookmarkEvent<T> {
  loadAll<void>(),
  addBookmarkCollection<BookmarkCollectionModel>(),
  updateBookmarkCollection<BookmarkCollectionModel>(),
  deleteBookmarkCollection<BookmarkCollectionModel>(),
  reorderBookmarkCollections<ListMovement<BookmarkCollectionModel>>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
