import 'package:bookmark_blade/bloc/bookmark/outgoing_share.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_essay/event_essay.dart';
import 'package:event_modals/event_modals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'bookmark/bookmark_modal.dart';

class BookmarkLinkWidget extends StatelessWidget {
  final BookmarkModel bookmark;
  final bool showReorderable;
  final bool external;
  final int? index;

  const BookmarkLinkWidget({
    super.key,
    required this.bookmark,
    required this.showReorderable,
    this.external = true,
    this.index,
  }) : assert(!showReorderable || index != null);

  void launch(BuildContext context) {
    context.fireEvent(EssayEvent.url.event, bookmark.url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: GestureDetector(
        onTap: external
            ? () => showEventDialog<BookmarkModel>(
                  context: context,
                  onResponse:
                      (BlocEventChannel eventChannel, BookmarkModel response) {
                    eventChannel.fireEvent<BookmarkModel>(
                      BookmarkEvent.updateBookmark.event,
                      bookmark
                        ..name = response.name
                        ..url = response.url,
                    );
                  },
                  builder: (_) => BookmarkModal(initialValue: bookmark),
                )
            : () => launch(context),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.name,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(bookmark.url, textAlign: TextAlign.start),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                  onPressed: () => launch(context),
                  child: const Text("Launch")),
              if (external)
                IconButton(
                    onPressed: () => showEventDialog<bool>(
                          context: context,
                          builder: (_) => const ConfirmationDialog(
                              title: Text(
                                  "Are you sure you want to delete this bookmark?")),
                          onResponse:
                              (BlocEventChannel eventChannel, response) =>
                                  response
                                      ? context.fireEvent(
                                          BookmarkEvent.deleteBookmark.event,
                                          bookmark)
                                      : null,
                        ),
                    icon: const Icon(Icons.delete)),
              if (external && showReorderable)
                ReorderableDragStartListener(
                  index: index!,
                  child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Icon(Icons.reorder)),
                )
            ]),
          ),
        ),
      ),
    );
  }
}

class ShareLinkDialog extends StatelessWidget {
  final BookmarkCollectionModel model;
  final Widget? footer;

  const ShareLinkDialog({super.key, required this.model, this.footer});

  @override
  Widget build(BuildContext context) {
    final bloc = context.readBloc<OutgoingShareBookmarkBloc>();

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
          ),
          if (footer != null) const SizedBox(height: 10),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
