import 'package:bookmark_blade/bloc/bookmark.dart';
import 'package:bookmark_blade/bloc/external_bookmark.dart';
import 'package:bookmark_blade/bloc/navigation/navigation.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_navigation/event_navigation.dart';

final blocBuilders = [
  BlocBuilder<MainNavigationBloc<String>>(
      (read, channel) => generateNavigationBloc(parentChannel: channel)),
  BlocBuilder<BookmarkBloc>((read, channel) => BookmarkBloc(
      parentChannel: channel,
      databaseRepository: read.read<DatabaseRepository>())),
  BlocBuilder<ExternalBookmarkBloc>((read, channel) => ExternalBookmarkBloc(
      parentChannel: channel,
      databaseRepository: read.read<DatabaseRepository>())),
];
