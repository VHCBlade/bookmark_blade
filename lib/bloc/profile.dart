import 'dart:async';

import 'package:bookmark_blade/bloc/external_bookmark.dart';
import 'package:bookmark_blade/events/profile.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';

const profileKey = "Profile";

class ProfileBloc extends Bloc {
  ProfileBloc({
    required super.parentChannel,
    required this.database,
  }) {
    eventChannel.addEventListener(ProfileEvent.load.event, (p0, p1) => load());
  }

  final DatabaseRepository database;

  final Completer<ProfileModel> completer = Completer();
  ProfileModel? profile;
  bool initialized = false;

  void load() async {
    if (initialized) {
      return;
    }
    initialized = true;
    final specificDatabase = SpecificDatabase(database, bookmarkDb);
    profile = await specificDatabase.findModel<ProfileModel>(profileKey);

    if (profile != null) {
      completer.complete(profile);
      updateBloc();
      return;
    }

    profile = ProfileModel();
    profile!.id = profileKey;
    await specificDatabase.saveModel(profile!);
    completer.complete(profile);
    updateBloc();
  }
}
