import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

class ProfileModel extends GenericModel {
  late String identifier = const Uuid().v4();

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "identifier": Tuple2(() => identifier, (val) => identifier = val),
      };

  @override
  String get type => "Profile";
}
