import 'dart:async';

import 'package:bookmark_blade/model/bookmark.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:search_me_up/search_me_up.dart';
import 'package:tuple/tuple.dart';

const bookmarkDb = "myBookmarks";

class BookmarkBloc extends Bloc {
  BookmarkBloc(
      {required super.parentChannel, required this.databaseRepository});

  final DatabaseRepository databaseRepository;
  late final database = SpecificDatabase(databaseRepository, bookmarkDb);
  late final bookmarkMap = GenericModelMap(
    repository: () => databaseRepository,
    defaultDatabaseName: bookmarkDb,
    supplier: BookmarkCollectionModel.new,
  );
  final bookmarkList = SortedSearchList<BookmarkCollectionModel, String>(
      comparator: (a, b) => a.ordinal.compareTo(b.ordinal),
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
  }

  Future<BookmarkCollectionModel> addBookmarkCollection(
      BookmarkCollectionModel model) async {
    model.lastEdited = DateTime.now();
    final newModel = await bookmarkMap.addModel(model);
    bookmarkList.generateList(bookmarkMap.map.values);
    _addedBookmarkCollectionIndex.add(bookmarkList.list.indexOf(newModel.id!));

    return newModel;
  }

  Future<BookmarkCollectionModel> updateBookmarkCollection(
      BookmarkCollectionModel model) async {
    model.lastEdited = DateTime.now();
    final newModel = await bookmarkMap.updateModel(model);
    bookmarkList.generateList(bookmarkMap.map.values);

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

    return true;
  }
}
