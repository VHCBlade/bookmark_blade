import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc.dart';

enum ExternalBookmarkEvent<T> {
  loadAll<void>(),
  addBookmarkCollection<BookmarkCollectionModel>(),
  updateBookmarkCollection<BookmarkCollectionModel>(),
  deleteBookmarkCollection<BookmarkCollectionModel>(),

  // Share
  importBookmarkCollection<String>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
