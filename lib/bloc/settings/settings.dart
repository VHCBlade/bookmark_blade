import 'package:bookmark_blade/events/settings.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

const settingsKey = "BBSettings";
const settingsDb = "Settings";

class SettingsBloc extends Bloc {
  final DatabaseRepository databaseRepository;

  BBSettings? settings;

  SettingsBloc(
      {required super.parentChannel, required this.databaseRepository}) {
    eventChannel.addEventListener<void>(
        SettingsEvent.loadSettings.event, (p0, p1) => loadSettings());
    eventChannel.addEventListener<BBSettings>(
        SettingsEvent.saveSettings.event, (p0, p1) => saveSettings(p1));
  }

  void loadSettings() async {
    final loadedSettings =
        await databaseRepository.findModel<BBSettings>(settingsDb, settingsKey);

    if (loadedSettings == null) {
      settings = BBSettings();
      return;
    }

    settings = loadedSettings;
    updateBloc();
  }

  void saveSettings(BBSettings settings) async {
    this.settings = settings..id = settingsKey;
    updateBloc();
    databaseRepository.saveModel<BBSettings>(settingsDb, settings);
  }
}

class BBSettings extends GenericModel {
  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {};

  @override
  String get type => "BBSettings";
}
