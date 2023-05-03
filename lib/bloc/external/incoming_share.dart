import 'dart:async';
import 'dart:convert';

import 'package:bookmark_blade/bloc/external/external_bookmark.dart';
import 'package:bookmark_blade/events/alert.dart';
import 'package:bookmark_blade/events/external_bookmark.dart';
import 'package:bookmark_blade/repository.dart/api.dart';
import 'package:bookmark_models/bookmark_requests.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';

class ShareLink {
  final String fullLink;

  const ShareLink(this.fullLink);

  bool get isValid => id.isNotEmpty;
  String get id => fullLink.split("/").last.trim();
}

class IncomingShareBookmarkBloc extends Bloc {
  IncomingShareBookmarkBloc({
    required super.parentChannel,
    required this.database,
    required this.api,
  }) {
    eventChannel.addEventListener(
        ExternalBookmarkEvent.loadAll.event, (p0, p1) => loadAll());
    eventChannel.addEventListener(
        ExternalBookmarkEvent.deleteBookmarkCollection.event,
        (p0, p1) => deleteBookmark(p1));
    eventChannel.addEventListener(
        ExternalBookmarkEvent.importBookmarkCollection.event,
        (p0, p1) => importBookmark(p1));
  }

  final DatabaseRepository database;
  final APIRepository api;

  final List<StreamSubscription> subscriptions = [];

  int currentImports = 0;
  bool get attemptingToImport => currentImports != 0;

  late final shareBookmarkMap = GenericModelMap(
    repository: () => database,
    defaultDatabaseName: externalBookmarkDB,
    supplier: IncomingBookmarkShareInfo.new,
  );

  Future<void> loadAll() async {
    await shareBookmarkMap.loadAll();
    updateBloc();
    // TODO BB-9
  }

  void autoUpdate() {
    // TODO BB-9
  }

  String shareLink(BookmarkCollectionModel model) {
    return api.createShareLink(model.idSuffix!);
  }

  String createFullId(String id) => (IncomingBookmarkShareInfo()
        ..idSuffix = (BookmarkCollectionModel()..idSuffix = id).id)
      .id!;

  Future<bool> updateShare(IncomingBookmarkShareInfo info) async {
    final syncRequest = BookmarkSyncRequest()
      ..collectionId = info.idSuffix!
      ..lastUpdated = info.lastUpdated;

    final response = await api.request("POST", "bookmarks/${info.idSuffix!}",
        (request) => request.body = json.encode(syncRequest.toMap()));

    switch (response.statusCode) {
      case 200:
        break;
      case 504:
        eventChannel.fireEvent(AlertEvent.noInternetAccess.event, null);
        updateBloc();
        return false;
      case 404:
      default:
        eventChannel.fireEvent(
            AlertEvent.error.event,
            "We couldn't find an update for the bookmark collection for this link. The original sharer may have"
            " deleted it.");
        updateBloc();
        return false;
    }

    final bodyMap = await response.bodyAsMap;
    final syncData = BookmarkSyncData()..loadFromMap(bodyMap);

    if (!syncData.updated) {
      return false;
    }

    info.lastUpdated = syncData.lastUpdated;
    shareBookmarkMap.specificDatabase().saveModel(info);
    eventChannel.fireEvent(ExternalBookmarkEvent.updateBookmarkCollection.event,
        syncData.collectionModel);

    return true;
  }

  IncomingBookmarkShareInfo? fromId(String id) {
    final String fullId = createFullId(id);
    return shareBookmarkMap.map[fullId];
  }

  void deleteBookmark(BookmarkCollectionModel model) async {
    final fullId = createFullId(model.idSuffix!);
    final currentShareInfo = shareBookmarkMap.map[fullId];

    if (currentShareInfo != null) {
      await shareBookmarkMap.deleteModel(currentShareInfo);
      updateBloc();
    }
  }

  void importBookmark(String id) async {
    final fullId = createFullId(id);
    final currentShareInfo = shareBookmarkMap.map[fullId];

    if (currentShareInfo != null) {
      if (await updateShare(currentShareInfo)) {
        updateBloc();
      }
      return;
    }

    currentImports++;
    updateBloc();

    final syncRequest = BookmarkSyncRequest()..collectionId = id;

    final response = await api.request("POST", "bookmarks/$id",
        (request) => request.body = json.encode(syncRequest.toMap()));

    currentImports--;

    switch (response.statusCode) {
      case 200:
        break;
      case 504:
        eventChannel.fireEvent(AlertEvent.noInternetAccess.event, null);
        updateBloc();
        return;
      case 404:
      default:
        eventChannel.fireEvent(
            AlertEvent.error.event,
            "We couldn't find the bookmark collection for this link. The original sharer may have"
            " deleted it, or they may be something wrong with your link.");
        updateBloc();
        return;
    }

    final syncData = BookmarkSyncData()..loadFromMap(await response.bodyAsMap);
    final newShareInfo = IncomingBookmarkShareInfo()
      ..id = fullId
      ..lastUpdated = syncData.lastUpdated;
    shareBookmarkMap.addModel(newShareInfo).then((value) => updateBloc());

    eventChannel.fireEvent(ExternalBookmarkEvent.addBookmarkCollection.event,
        syncData.collectionModel!);
  }
}
