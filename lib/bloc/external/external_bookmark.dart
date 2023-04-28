import 'dart:async';

import 'package:bookmark_blade/events/external_bookmark.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:search_me_up/search_me_up.dart';
import 'package:tuple/tuple.dart';

const externalBookmarkDB = "externalBookmarks";

class ExternalBookmarkBloc extends Bloc {
  ExternalBookmarkBloc(
      {required super.parentChannel, required this.databaseRepository}) {
    eventChannel.addEventListener(
        ExternalBookmarkEvent.addBookmarkCollection.event,
        (event, value) => addBookmarkCollection(value));
    eventChannel.addEventListener(
        ExternalBookmarkEvent.updateBookmarkCollection.event,
        (event, value) => updateBookmarkCollection(value));
    eventChannel.addEventListener(
        ExternalBookmarkEvent.deleteBookmarkCollection.event,
        (event, value) => deleteBookmarkCollection(value));
    eventChannel.addEventListener(
        ExternalBookmarkEvent.loadAll.event, (event, value) => loadAll());
    eventChannel.addEventListener(
        ExternalBookmarkEvent.reorderBookmarkCollections.event,
        (event, value) => reorderBookmarkCollection(value.moved, value.to));
    eventChannel.addEventListener(
        ExternalBookmarkEvent.selectBookmarkCollection.event, (event, value) {
      selected = value;
      updateBloc();
    });
  }

  BookmarkCollectionModel? selected;
  bool get hasSelected => selected != null;

  final DatabaseRepository databaseRepository;
  late final database =
      SpecificDatabase(databaseRepository, externalBookmarkDB);
  late final bookmarkMap = GenericModelMap(
    repository: () => databaseRepository,
    defaultDatabaseName: externalBookmarkDB,
    supplier: BookmarkCollectionModel.new,
  );
  final bookmarkList = SortedSearchList<BookmarkCollectionModel, String>(
      comparator: (a, b) => b.ordinal.compareTo(a.ordinal),
      converter: (e) => e.id!);
  bool loading = false;

  final _addedBookmarkCollectionIndex = StreamController<int>.broadcast();
  final _removeddBookmarkCollectionIndex =
      StreamController<Tuple2<int, BookmarkCollectionModel>>.broadcast();

  Stream<int> get addedBookmarkCollectionIndex =>
      _addedBookmarkCollectionIndex.stream;
  Stream<Tuple2<int, BookmarkCollectionModel>>
      get removeddBookmarkCollectionIndex =>
          _removeddBookmarkCollectionIndex.stream;

  BookmarkCollectionModel? bookmarkCollectionAt(int position) =>
      bookmarkList.list.length <= position
          ? null
          : bookmarkMap.map[bookmarkList.list[position]];

  Future<void> loadAll() async {
    final bookmarks = await bookmarkMap.loadAll();
    bookmarkList.generateList(bookmarks);
    bookmarks
        .map((e) => bookmarkList.list.indexOf(e.id!))
        .forEach(_addedBookmarkCollectionIndex.add);
    updateBloc();
  }

  Future<BookmarkCollectionModel> addBookmarkCollection(
      BookmarkCollectionModel model) async {
    final newModel = await bookmarkMap.addModel(model);
    bookmarkList.generateList(bookmarkMap.map.values);
    _addedBookmarkCollectionIndex.add(bookmarkList.list.indexOf(newModel.id!));
    updateBloc();

    return newModel;
  }

  Future<BookmarkCollectionModel> updateBookmarkCollection(
      BookmarkCollectionModel model) async {
    model.ordinal = bookmarkMap.map[model.id!]?.ordinal ?? 0;
    final newModel = await bookmarkMap.updateModel(model);
    bookmarkList.generateList(bookmarkMap.map.values);
    updateBloc();

    return newModel;
  }

  Future<bool> deleteBookmarkCollection(BookmarkCollectionModel model) async {
    final success = await bookmarkMap.deleteModel(model);
    if (!success) {
      return false;
    }
    final index = bookmarkList.list.indexOf(model.id!);
    bookmarkList.generateList(bookmarkMap.map.values);
    _removeddBookmarkCollectionIndex.add(Tuple2(index, model));
    updateBloc();

    return true;
  }

  Future<void> reorderBookmarkCollection(
      BookmarkCollectionModel model, int newOrdinal,
      [bool shouldUpdateBloc = true]) async {
    final reorder = bookmarkMap.reorder(model, newOrdinal);

    bookmarkList.generateList(bookmarkMap.map.values);

    if (shouldUpdateBloc) {
      updateBloc();
    }
    await reorder;
  }
}
