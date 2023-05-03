import 'package:bookmark_blade/bloc/settings/settings.dart';
import 'package:event_bloc/event_bloc_widgets.dart';

enum SettingsEvent<T> {
  loadSettings<void>(),
  saveSettings<BBSettings>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
