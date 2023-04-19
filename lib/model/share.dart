import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

class BookmarkShareModel extends GenericModel {
  DateTime? lastUpdated;

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "lastUpdated": GenericModel.dateTime(
            () => lastUpdated, (value) => lastUpdated = value),
      };

  @override
  String get type => "BookmarkShareModel";
}
