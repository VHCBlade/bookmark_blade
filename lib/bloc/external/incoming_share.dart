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
    eventChannel.addEventListener(
        ExternalBookmarkEvent.updateImportedBookmarkCollection.event,
        (p0, p1) => updateImportedBookmark(p1.shareInfo, p1.userInitiated));
    eventChannel.addEventListener(
        ExternalBookmarkEvent.autoUpdateImportedBookmarkCollection.event,
        (p0, p1) {
      if (p1 == null) {
        return;
      }
      final fullId = createFullId(p1);
      final currentShareInfo = shareBookmarkMap.map[fullId];
      if (currentShareInfo != null) {
        updateImportedBookmark(currentShareInfo, false);
      }
    });
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
  }

  String shareLink(BookmarkCollectionModel model) {
    return api.createShareLink(model.idSuffix!);
  }

  static String createFullId(String id) => (IncomingBookmarkShareInfo()
        ..idSuffix = (BookmarkCollectionModel()
              ..idSuffix = (BookmarkCollectionModel()..id = id).idSuffix)
            .id)
      .id!;

  Future<bool> updateImportedBookmark(IncomingBookmarkShareInfo info,
      [bool userInitiated = true]) async {
    final syncRequest = BookmarkSyncRequest()
      ..collectionId = info.idSuffix!
      ..lastUpdated = info.lastUpdated;

    final response = await api.request("POST", "bookmarks/${info.idSuffix!}",
        (request) => request.body = json.encode(syncRequest.toMap()));

    if (userInitiated) {
      info.lastChecked = DateTime.now();
      info.lastCheckedStatus = LastCheckedStatus.loading;
      updateBloc();
    }

    switch (response.statusCode) {
      case 200:
        break;
      case 504:
        if (userInitiated) {
          eventChannel.fireEvent(AlertEvent.noInternetAccess.event, null);
          info.lastCheckedStatus = LastCheckedStatus.failed;
        }
        updateBloc();
        return false;
      case 404:
      default:
        if (userInitiated) {
          eventChannel.fireEvent(
              AlertEvent.error.event,
              "We couldn't find an update for the bookmark collection for this link. The original sharer may have"
              " deleted it.");
          info.lastCheckedStatus = LastCheckedStatus.failed;
        }
        updateBloc();
        return false;
    }

    final bodyMap = await response.bodyAsMap;
    final syncData = BookmarkSyncData()..loadFromMap(bodyMap);

    if (userInitiated) {
      info.lastCheckedStatus = LastCheckedStatus.succeeded;
      updateBloc();
    }

    if (!syncData.updated) {
      return false;
    }

    info.lastUpdated = syncData.lastUpdated;
    shareBookmarkMap.specificDatabase().saveModel(info);
    eventChannel.fireEvent<BookmarkCollectionModel>(
        ExternalBookmarkEvent.updateBookmarkCollection.event,
        syncData.collectionModel!);

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
      if (await updateImportedBookmark(currentShareInfo)) {
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
