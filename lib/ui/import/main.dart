import 'package:bookmark_blade/ui/import/import.dart';
import 'package:bookmark_blade/ui/import/specific.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:vhcblade_theme/vhcblade_widget.dart';

class MainImportScreen extends StatelessWidget {
  const MainImportScreen({super.key});

  Widget buildWidget(BuildContext context) {
    final bloc = context.watchBloc<MainNavigationBloc<String>>();

    if (bloc.deepNavigationMap["import"] == null) {
      return const ImportScreen();
    }

    return const SpecificImportScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FadeThroughWidgetSwitcher(builder: buildWidget);
  }
}
