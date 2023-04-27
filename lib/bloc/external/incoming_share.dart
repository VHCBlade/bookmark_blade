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

  Future<bool> updateShare(IncomingBookmarkShareInfo info) {
    throw UnimplementedError();
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

    final response = await api.request("GET", "bookmarks/$id",
        (request) => request.body = json.encode(syncRequest));

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

    final syncData = BookmarkSyncData()
      ..loadFromMap(json.encode(await response.body) as Map<String, dynamic>);
    final newShareInfo = IncomingBookmarkShareInfo()
      ..id = fullId
      ..lastUpdated = syncData.lastUpdated;

    eventChannel.fireEvent(
        ExternalBookmarkEvent.addBookmarkCollection.event, newShareInfo);
    updateBloc();
  }
}
