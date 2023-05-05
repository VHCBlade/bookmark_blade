import 'dart:async';
import 'dart:convert';

import 'package:bookmark_blade/bloc/bookmark/bookmark.dart';
import 'package:bookmark_blade/bloc/profile.dart';
import 'package:bookmark_blade/events/alert.dart';
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
    eventChannel.addEventListener(
        BookmarkEvent.updateSharedBookmarkCollection.event,
        (p0, p1) => updateSharedBookmark(p1, true));
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
    return api.createShareLink(model.idSuffix!);
  }

  Future<BookmarkShareRequest> createShareRequest(
      BookmarkCollectionModel collectionModel) async {
    final shareRequest = BookmarkShareRequest();
    shareRequest.collectionModel = collectionModel;
    shareRequest.profile = (await bloc.completer.future).identifier;

    return shareRequest;
  }

  bool needsUpdate(BookmarkCollectionModel model) {
    final info = shareBookmarkMap.map[model.outgoingId]!;
    return info.lastUpdated != model.lastEdited;
  }

  void updateSharedBookmark(BookmarkCollectionModel collectionModel,
      [bool userInitiated = false]) async {
    final info = shareBookmarkMap.map[collectionModel.outgoingId]!;
    info.shouldBeDeleted = false;
    await shareBookmarkMap.updateModel(info);

    if (!needsUpdate(collectionModel)) {
      return;
    }

    final shareRequest = await createShareRequest(collectionModel);

    final response = await api.request(
        "PUT",
        "bookmarks/${collectionModel.idSuffix}",
        (request) => request.body = json.encode(shareRequest.toMap()));

    switch (response.statusCode) {
      case 200:
        break;
      case 504:
        eventChannel.fireEvent(AlertEvent.noInternetAccess.event, null);
        updateBloc();
        return;
      case 404:
      default:
        eventChannel.fireEvent(AlertEvent.error.event,
            "Something went wrong updating your shared bookmark collection. Try deleting your current bookmark collection first and try sharing again.");
        updateBloc();
        return;
    }

    info.lastUpdated = collectionModel.lastEdited;
    await shareBookmarkMap.updateModel(info);
    updateBloc();

    return;
  }

  void initialShareBookmark(BookmarkCollectionModel collectionModel) async {
    if (shareBookmarkMap.map.containsKey(collectionModel.outgoingId)) {
      updateSharedBookmark(collectionModel);

      return;
    }
    attemptingToAdd = true;
    updateBloc();

    final shareRequest = await createShareRequest(collectionModel);

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
