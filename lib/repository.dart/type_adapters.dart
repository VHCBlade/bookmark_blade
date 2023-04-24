import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_hive/event_hive.dart';
import 'package:vhcblade_theme/vhcblade_picker.dart';

final typeAdapters = <GenericTypeAdapter>[
  GenericTypeAdapter<SelectedTheme>(SelectedTheme.new, (_) => 1),
  GenericTypeAdapter<UnlockedThemes>(UnlockedThemes.new, (_) => 2),
  GenericTypeAdapter<BookmarkCollectionModel>(
      BookmarkCollectionModel.new, (_) => 3),
  GenericTypeAdapter<ProfileModel>(ProfileModel.new, (_) => 4),
  GenericTypeAdapter<OutgoingBookmarkShareInfo>(
      OutgoingBookmarkShareInfo.new, (_) => 5),
  GenericTypeAdapter<IncomingBookmarkShareInfo>(
      IncomingBookmarkShareInfo.new, (_) => 6),
];
