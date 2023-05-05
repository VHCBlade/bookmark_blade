import 'package:bookmark_blade/bloc/external/incoming_share.dart';
import 'package:bookmark_blade/events/external_bookmark.dart';
import 'package:bookmark_blade/ui/bookmark.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';

class ShareInfoDialog extends StatelessWidget {
  final BookmarkCollectionModel model;

  const ShareInfoDialog({super.key, required this.model});
  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<IncomingShareBookmarkBloc>();
    final info = bloc.fromId(model.id!)!;
    bool loading = info.lastCheckedStatus == LastCheckedStatus.loading &&
        DateTime.now()
                .difference(info.lastChecked ?? DateTime.now())
                .inSeconds <
            50;
    return ShareLinkDialog(
      model: model,
      footer: Row(
        children: [
          const Expanded(
            child: Text(
              "Check for Updates",
              textAlign: TextAlign.left,
            ),
          ),
          if (loading) const CircularProgressIndicator.adaptive(),
          if (!loading)
            ElevatedButton(
                onPressed: () => context.fireEvent(
                    ExternalBookmarkEvent
                        .updateImportedBookmarkCollection.event,
                    UpdateImportedBookmark(info, true)),
                child: const Text("Update")),
        ],
      ),
    );
  }
}
