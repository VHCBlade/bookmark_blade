import 'package:bookmark_blade/events/external_bookmark.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';

const externalBookmarkDB = "externalBookmarks";

class ExternalBookmarkBloc extends Bloc {
  ExternalBookmarkBloc(
      {required super.parentChannel, required this.databaseRepository}) {
    eventChannel.addEventListener(
        ExternalBookmarkEvent.addBookmarkCollection.event,
        (event, value) => addBookmark(value));
  }
  final DatabaseRepository databaseRepository;

  late final bookmarkMap = GenericModelMap(
    repository: () => databaseRepository,
    defaultDatabaseName: externalBookmarkDB,
    supplier: BookmarkCollectionModel.new,
  );

  void addBookmark(BookmarkCollectionModel model) {
    bookmarkMap.addModel(model);
    updateBloc();
  }
}
