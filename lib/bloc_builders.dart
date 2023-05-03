import 'package:bookmark_blade/bloc/alert_bloc.dart';
import 'package:bookmark_blade/bloc/bookmark/bookmark.dart';
import 'package:bookmark_blade/bloc/bookmark/delete_share.dart';
import 'package:bookmark_blade/bloc/bookmark/edit.dart';
import 'package:bookmark_blade/bloc/bookmark/outgoing_share.dart';
import 'package:bookmark_blade/bloc/external/incoming_share.dart';
import 'package:bookmark_blade/bloc/navigation/navigation.dart';
import 'package:bookmark_blade/bloc/profile.dart';
import 'package:bookmark_blade/bloc/settings/settings.dart';
import 'package:bookmark_blade/repository.dart/api.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_navigation/event_navigation.dart';

import 'bloc/external/external_bookmark.dart';

final blocBuilders = [
  BlocBuilder<SettingsBloc>((read, channel) => SettingsBloc(
        parentChannel: channel,
        databaseRepository: read.read<DatabaseRepository>(),
      )),
  BlocBuilder<AlertBloc>((read, channel) => AlertBloc(parentChannel: channel)),
  BlocBuilder<ProfileBloc>((read, channel) => ProfileBloc(
      parentChannel: channel, database: read.read<DatabaseRepository>())),
  BlocBuilder<MainNavigationBloc<String>>(
      (read, channel) => generateNavigationBloc(parentChannel: channel)),
  BlocBuilder<BookmarkBloc>((read, channel) => BookmarkBloc(
      parentChannel: channel,
      databaseRepository: read.read<DatabaseRepository>())),
  BlocBuilder<ExternalBookmarkBloc>((read, channel) => ExternalBookmarkBloc(
      parentChannel: channel,
      databaseRepository: read.read<DatabaseRepository>())),
  BlocBuilder<BookmarkEditBloc>((read, channel) => BookmarkEditBloc(
        parentChannel: channel,
      )),
  BlocBuilder<OutgoingShareBookmarkBloc>(
      (read, channel) => OutgoingShareBookmarkBloc(
            parentChannel: channel,
            api: read.read<APIRepository>(),
            database: read.read<DatabaseRepository>(),
            removedBookmarkStream:
                read.read<BookmarkBloc>().removedBookmarkCollectionIndex,
            bloc: read.read<ProfileBloc>(),
          )),
  BlocBuilder<IncomingShareBookmarkBloc>(
      (read, channel) => IncomingShareBookmarkBloc(
            parentChannel: channel,
            api: read.read<APIRepository>(),
            database: read.read<DatabaseRepository>(),
          )),
  BlocBuilder<ShareBookmarkDeleteQueue>(
      (read, channel) => ShareBookmarkDeleteQueue(
            parentChannel: channel,
            bloc: read.read<OutgoingShareBookmarkBloc>(),
          )),
];
