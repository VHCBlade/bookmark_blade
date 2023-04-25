import 'package:bookmark_blade/repository.dart/api.dart';
import 'package:bookmark_blade/repository.dart/type_adapters.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_essay/event_essay.dart';
import 'package:event_hive/event_hive.dart';
import 'package:flutter/foundation.dart';

import 'site.dart' as site;
import 'local.dart' as local;

final repositoryBuilders = [
  RepositoryBuilder<DatabaseRepository>(
      (read) => HiveRepository(typeAdapters: typeAdapters)),
  RepositoryBuilder<TextRepository>((read) => DefaultTextRepository()),
  RepositoryBuilder<UrlLauncherRepository>((read) => UrlLauncherRepository()),
  RepositoryBuilder<APIRepository>(
      // You need to create a local.dart file with const site = "localhost:8080", or an equivalent to run.
      (read) => ServerAPIRepository(
            apiServer: kDebugMode ? local.site : site.site,
            website: site.website,
          )),
];
