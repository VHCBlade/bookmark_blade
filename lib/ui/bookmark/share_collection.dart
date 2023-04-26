import 'package:bookmark_blade/bloc/bookmark/outgoing_share.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

    return AlertDialog(
      title: const Text("Share Information"),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Share Link",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text(bloc.shareLink(model))),
              IconButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: bloc.shareLink(model)));
                    Fluttertoast.showToast(
                        msg: "Copied Share Link to Clipboard!");
                  },
                  icon: const Icon(Icons.copy))
            ],
          )
        ],
      ),
    );
  }
}
