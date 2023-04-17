import 'package:bookmark_blade/ui/bookmark/bookmark_list.dart';
import 'package:bookmark_blade/ui/bookmark/collection_list.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:vhcblade_theme/vhcblade_widget.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  Widget buildWidget(BuildContext context) {
    final bloc = context.watchBloc<MainNavigationBloc<String>>();

    if (bloc.deepNavigationMap["bookmark"] == null) {
      return const BookmarkCollectionListScreen();
    }

    return const BookmarkListScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FadeThroughWidgetSwitcher(builder: buildWidget);
  }
}
