import 'dart:async';
import 'dart:convert';

import 'package:bookmark_blade/bloc/bookmark/bookmark.dart';
import 'package:bookmark_blade/bloc/external/external_bookmark.dart';
import 'package:bookmark_blade/bloc/profile.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/repository.dart/api.dart';
import 'package:bookmark_models/bookmark_requests.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

extension OutgoingId on BookmarkCollectionModel {
  String? get outgoingId => (OutgoingBookmarkShareInfo()..idSuffix = id).id;
}

class OutgoingShareBookmarkBloc extends Bloc {
  OutgoingShareBookmarkBloc({
    required super.parentChannel,
    required this.database,
    required this.removedBookmarkStream,
    required this.bloc,
    required this.api,
  }) {
    subscriptions.add(
        removedBookmarkStream.listen((event) => deleteBookmark(event.item2)));
    eventChannel.addEventListener(
        BookmarkEvent.loadAll.event, (p0, p1) => loadAll());
    eventChannel.addEventListener(BookmarkEvent.shareBookmarkCollection.event,
        (p0, p1) => initialShareBookmark(p1));
  }

  final DatabaseRepository database;
  final APIRepository api;
  final ProfileBloc bloc;
  final Stream<Tuple2<int, BookmarkCollectionModel>> removedBookmarkStream;

  final List<StreamSubscription> subscriptions = [];

  bool attemptingToAdd = false;

  late final shareBookmarkMap = GenericModelMap(
    repository: () => database,
    defaultDatabaseName: bookmarkDb,
    supplier: OutgoingBookmarkShareInfo.new,
  );

  Future<void> loadAll() async {
    await shareBookmarkMap.loadAll();
    updateBloc();
  }

  String shareLink(BookmarkCollectionModel model) {
    print(api.createShareLink(model.idSuffix!));
    return api.createShareLink(model.idSuffix!);
  }

  void initialShareBookmark(BookmarkCollectionModel collectionModel) async {
    if (shareBookmarkMap.map.containsKey(collectionModel.outgoingId)) {
      final info = shareBookmarkMap.map[collectionModel.outgoingId]!;
      info.shouldBeDeleted = false;
      await shareBookmarkMap.specificDatabase().saveModel(info);

      return;
    }
    attemptingToAdd = true;
    updateBloc();

    final shareRequest = BookmarkShareRequest();
    shareRequest.collectionModel = collectionModel;
    shareRequest.profile = (await bloc.completer.future).identifier;

    final response = await api.request("POST", "bookmarks",
        (request) => request.body = json.encode(shareRequest.toMap()));

    switch (response.statusCode) {
      case 200:
        break;
      case 404:
      default:
        attemptingToAdd = false;
        updateBloc();
        return;
    }

    final shareInfo = OutgoingBookmarkShareInfo.fromCollection(collectionModel);
    await shareBookmarkMap.addModel(shareInfo);
    attemptingToAdd = false;
    updateBloc();
  }

  OutgoingBookmarkShareInfo? shareInfoOfCollection(
      BookmarkCollectionModel model) {
    return shareBookmarkMap.map[model.outgoingId];
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
