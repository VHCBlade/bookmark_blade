import 'dart:async';

import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/repository.dart/api.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

import '../external_bookmark.dart';

class ShareBookmarkBloc extends Bloc {
  ShareBookmarkBloc({
    required super.parentChannel,
    required this.database,
    required this.removedBookmarkStream,
    required this.api,
  }) {
    subscriptions.add(
        removedBookmarkStream.listen((event) => deleteBookmark(event.item2)));
    eventChannel.addEventListener(
        BookmarkEvent.loadAll.event, (p0, p1) => loadAll());
  }

  final DatabaseRepository database;
  final APIRepository api;
  final Stream<Tuple2<int, BookmarkCollectionModel>> removedBookmarkStream;

  final List<StreamSubscription> subscriptions = [];

  late final shareBookmarkMap = GenericModelMap(
    repository: () => database,
    defaultDatabaseName: bookmarkDb,
    supplier: OutgoingBookmarkShareInfo.new,
  );

  Future<void> loadAll() async {
    await shareBookmarkMap.loadAll();
    updateBloc();
  }

  void deleteBookmark(BookmarkCollectionModel collectionModel) async {
    if (!shareBookmarkMap.map.containsKey(collectionModel.id)) {
      return;
    }

    final bookmark = shareBookmarkMap.map[collectionModel.id]!;
    bookmark.shouldBeDeleted = true;
    database.saveModel(bookmarkDb, bookmark);
    updateBloc();
  }
}
