import 'package:bookmark_blade/bloc/bookmark/outgoing_share.dart';
import 'package:event_bloc/event_bloc.dart';

class ShareBookmarkDeleteQueue extends Bloc {
  ShareBookmarkDeleteQueue({required super.parentChannel, required this.bloc});

  final OutgoingShareBookmarkBloc bloc;
}
