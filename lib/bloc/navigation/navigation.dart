import 'package:bookmark_blade/bloc/navigation/bookmark.dart';
import 'package:bookmark_blade/bloc/navigation/settings.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:event_bloc/event_bloc.dart';

const possibleNavigations = <String>{
  "bookmark",
  "external",
  "import",
  "settings",
  "error",
};

MainNavigationBloc<String> generateNavigationBloc(
    {BlocEventChannel? parentChannel}) {
  final bloc = MainNavigationBloc<String>(
    parentChannel: parentChannel,
    strategy: ListNavigationStrategy(
      possibleNavigations: possibleNavigations.toList(),
      defaultNavigation: 'bookmark',
      navigationOnError: 'error',
    ),
    undoStrategy: UndoRedoMainNavigationStrategy(),
  );

  bloc.deepNavigationStrategyMap["settings"] = SettingsDeepNavigationStrategy();
  bloc.deepNavigationStrategyMap["bookmark"] = BookmarkDeepNavigationStrategy();
  bloc.deepNavigationStrategyMap["external"] = BookmarkDeepNavigationStrategy();

  return bloc;
}
