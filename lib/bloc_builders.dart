import 'package:bookmark_blade/bloc/bookmark/bookmark.dart';
import 'package:bookmark_blade/bloc/bookmark/delete_share.dart';
import 'package:bookmark_blade/bloc/bookmark/edit.dart';
import 'package:bookmark_blade/bloc/bookmark/share.dart';
import 'package:bookmark_blade/bloc/external_bookmark.dart';
import 'package:bookmark_blade/bloc/navigation/navigation.dart';
import 'package:bookmark_blade/bloc/profile.dart';
import 'package:bookmark_blade/repository.dart/api.dart';
import 'package:bookmark_models/bookmark_requests.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_navigation/event_navigation.dart';

final blocBuilders = [
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
  BlocBuilder<ShareBookmarkBloc>((read, channel) => ShareBookmarkBloc(
        parentChannel: channel,
        api: read.read<APIRepository>(),
        database: read.read<DatabaseRepository>(),
        removedBookmarkStream:
            read.read<BookmarkBloc>().removedBookmarkCollectionIndex,
      )),
  BlocBuilder<ShareBookmarkDeleteQueue>(
      (read, channel) => ShareBookmarkDeleteQueue(
            parentChannel: channel,
            bloc: read.read<ShareBookmarkBloc>(),
          )),
];
