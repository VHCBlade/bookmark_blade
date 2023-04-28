import 'package:bookmark_blade/ui/external/collection_list.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:vhcblade_theme/vhcblade_widget.dart';

class ExternalBookmarkScreen extends StatelessWidget {
  const ExternalBookmarkScreen({super.key});

  Widget buildWidget(BuildContext context) {
    final bloc = context.watchBloc<MainNavigationBloc<String>>();

    if (bloc.deepNavigationMap["external"] == null) {
      return const ExternalBookmarkCollectionListScreen();
    }

    return const ExternalBookmarkCollectionListScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FadeThroughWidgetSwitcher(builder: buildWidget);
  }
}
