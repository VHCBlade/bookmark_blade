import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

class BookmarkModel extends GenericModel with OrdereableModel {
  late String url;
  late String name;
  bool launch = true;

  @override
  int ordinal = 0;

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "url": Tuple2(() => url, (value) => url = value),
        "name": Tuple2(() => name, (value) => name = value),
        "launch": Tuple2(() => launch, (value) => launch = value),
        "ordinal": ordinalGetterSetter,
      };

  @override
  String get type => "BookmarkModel";
}

class BookmarkCollectionModel extends GenericModel with OrdereableModel {
  late String bookmarkName;
  DateTime lastEdited = DateTime.now();
  Map<String, BookmarkModel> bookmarkMap = {};
  List<String> bookmarkOrder = [];
  @override
  int ordinal = 0;

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "bookmarkName": Tuple2(() => bookmarkName, (val) => bookmarkName = val),
        "lastEdited": GenericModel.dateTime(
            () => lastEdited, (value) => lastEdited = value ?? DateTime.now()),
        "bookmarkMap": GenericModel.modelMap(() => bookmarkMap,
            (value) => bookmarkMap = value ?? {}, BookmarkModel.new),
        "bookmarkOrder": Tuple2(() => bookmarkOrder,
            (val) => bookmarkOrder = val.map<String>((e) => "$e").toList()),
        "ordinal": ordinalGetterSetter,
      };

  @override
  String get type => "BookmarkCollectionModel";
}
