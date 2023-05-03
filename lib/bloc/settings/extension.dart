import 'package:bookmark_blade/bloc/settings/settings.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

extension BuildContextExtension on BuildContext {
  BBSettings get readSettings =>
      read<SettingsBloc?>()?.settings ?? BBSettings();
  BBSettings get watchSettings =>
      watchBloc<SettingsBloc>().settings ?? BBSettings();
}
