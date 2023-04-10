import 'dart:async';
import 'dart:math';

import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/model/bookmark.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:search_me_up/search_me_up.dart';
import 'package:tuple/tuple.dart';

const bookmarkDb = "myBookmarks";

class BookmarkBloc extends Bloc {
  BookmarkBloc(
      {required super.parentChannel, required this.databaseRepository}) {
    eventChannel.addEventListener(
        BookmarkEvent.loadAll.event, (p0, p1) => loadAll());
    eventChannel.addEventListener(BookmarkEvent.addBookmarkCollection.event,
        (p0, p1) => addBookmarkCollection(p1));
    eventChannel.addEventListener(BookmarkEvent.deleteBookmarkCollection.event,
        (p0, p1) => deleteBookmarkCollection(p1));
    eventChannel.addEventListener<ListMovement<BookmarkCollectionModel>>(
        BookmarkEvent.reorderBookmarkCollections.event,
        (p0, p1) => reorderBookmarkCollections(p1.moved, p1.to));
  }

  final DatabaseRepository databaseRepository;
  late final database = SpecificDatabase(databaseRepository, bookmarkDb);
  late final bookmarkMap = GenericModelMap(
    repository: () => databaseRepository,
    defaultDatabaseName: bookmarkDb,
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
        .forEach((element) => _addedBookmarkCollectionIndex.add(element));
    updateBloc();
  }

  Future<BookmarkCollectionModel> addBookmarkCollection(
      BookmarkCollectionModel model) async {
    model.lastEdited = DateTime.now();
    final newModel = await bookmarkMap.addModel(model);
    newModel.ordinal = bookmarkMap.map.length;
    bookmarkList.generateList(bookmarkMap.map.values);
    _addedBookmarkCollectionIndex.add(bookmarkList.list.indexOf(newModel.id!));
    updateBloc();

    return newModel;
  }

  Future<BookmarkCollectionModel> updateBookmarkCollection(
      BookmarkCollectionModel model) async {
    model.lastEdited = DateTime.now();
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

  Future<void> reorderBookmarkCollections(
      BookmarkCollectionModel model, int newOrdinal,
      [bool shouldUpdateBloc = true]) async {
    print(newOrdinal);
    final list = bookmarkMap.map.keys.toList();
    list.sort((a, b) =>
        bookmarkMap.map[b]!.ordinal.compareTo(bookmarkMap.map[a]!.ordinal));

    newOrdinal = min(newOrdinal, list.length);
    final initialOrdinal = list.indexOf(model.id!);

    if (newOrdinal == initialOrdinal) {
      return;
    }

    final updatedModels = <BookmarkCollectionModel>{};

    for (int i = 0; i < list.length; i++) {
      final pastOldIndex = i >= initialOrdinal;
      final pastNewIndex = i >= newOrdinal;

      if (!pastOldIndex && !pastNewIndex) {
        continue;
      }
      if (pastNewIndex && pastOldIndex) {
        break;
      }
      final updatedModel = bookmarkMap.map[list[i]]!;
      updatedModels.add(updatedModel);
      if (pastNewIndex) {
        updatedModel.ordinal = list.length - i - 2;
      }
      if (pastOldIndex) {
        updatedModel.ordinal = list.length - i;
      }
    }
    updatedModels.add(model);
    model.ordinal =
        list.length - newOrdinal - (newOrdinal > initialOrdinal ? 0 : 1);

    print(list.map((e) => bookmarkMap.map[e]!.ordinal));
    print(list.map((e) => bookmarkMap.map[e]!.bookmarkName));
    bookmarkList.generateList(bookmarkMap.map.values);

    if (shouldUpdateBloc) {
      updateBloc();
    }
    await Future.wait(updatedModels.map(bookmarkMap.updateModel));
  }
}
