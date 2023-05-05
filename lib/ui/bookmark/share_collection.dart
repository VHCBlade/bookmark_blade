import 'package:bookmark_blade/bloc/bookmark/outgoing_share.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/ui/bookmark.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';

extension IDSuffixGetter on BookmarkCollectionModel {
  String get idSuffix => id!.split('::').last;
}

class ShareCollectionDialog extends StatelessWidget {
  const ShareCollectionDialog({super.key, required this.model});

  final BookmarkCollectionModel model;

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<OutgoingShareBookmarkBloc>();
    final shareInfo = bloc.shareInfoOfCollection(model);

    if (shareInfo == null) {
      if (bloc.attemptingToAdd) {
        return const AlertDialog(
          title: Text("Share Information"),
          content: CircularProgressIndicator(),
        );
      }

      return const AlertDialog(
        title: Text("Share Information"),
        content: Text("We are unable to share this at this time..."),
      );
    }

    return ShareLinkDialog(
      model: model,
      footer: Row(children: [
        if (!bloc.needsUpdate(model))
          const Text(
            "Shared Bookmark Collection is up to date!",
            textAlign: TextAlign.left,
          ),
        if (bloc.needsUpdate(model)) ...[
          const Expanded(
              child: Text(
            "Needs update",
            textAlign: TextAlign.left,
          )),
          ElevatedButton(
            onPressed: () => context.fireEvent(
                BookmarkEvent.updateSharedBookmarkCollection.event, model),
            child: const Text("Update"),
          )
        ]
      ]),
    );
  }
}
