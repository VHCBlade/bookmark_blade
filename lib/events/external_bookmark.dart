import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';

enum ExternalBookmarkEvent<T> {
  loadAll<void>(),
  addBookmarkCollection<BookmarkCollectionModel>(),
  updateBookmarkCollection<BookmarkCollectionModel>(),
  deleteBookmarkCollection<BookmarkCollectionModel>(),
  reorderBookmarkCollections<ListMovement<BookmarkCollectionModel>>(),
  selectBookmarkCollection<BookmarkCollectionModel?>(),

  // Share
  importBookmarkCollection<String>(),
  updateImportedBookmarkCollection<UpdateImportedBookmark>(),
  autoUpdateImportedBookmarkCollection<String?>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}

class UpdateImportedBookmark {
  final IncomingBookmarkShareInfo shareInfo;
  final bool userInitiated;

  UpdateImportedBookmark(this.shareInfo, this.userInitiated);
}
