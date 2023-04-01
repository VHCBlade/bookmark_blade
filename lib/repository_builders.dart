import 'package:bookmark_blade/repository.dart/type_adapters.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_essay/event_essay.dart';
import 'package:event_hive/event_hive.dart';

final repositoryBuilders = [
  RepositoryBuilder<DatabaseRepository>(
      (read) => HiveRepository(typeAdapters: typeAdapters)),
  RepositoryBuilder<TextRepository>((read) => DefaultTextRepository()),
];
