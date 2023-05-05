import 'package:bookmark_models/bookmark_models.dart';
import 'package:flutter/material.dart';

class BookmarkModal extends StatefulWidget {
  const BookmarkModal({super.key, this.initialValue});
  final BookmarkModel? initialValue;

  @override
  State<BookmarkModal> createState() => _BookmarkModalState();
}

class _BookmarkModalState extends State<BookmarkModal> {
  late final nameController =
      TextEditingController(text: widget.initialValue?.name);
  late final nameFocusNode = FocusNode();
  late final linkController =
      TextEditingController(text: widget.initialValue?.url);
  late final linkFocusNode = FocusNode();

  bool get allowSave =>
      nameController.text.trim().isNotEmpty &&
      linkController.text.trim().isNotEmpty;

  bool hasPopped = false;

  void popBookmark() {
    if (hasPopped) {
      return;
    }
    hasPopped = true;
    Navigator.of(context).pop(BookmarkModel()
      ..name = nameController.text
      ..url = linkController.text);
  }

  void popNothing() {
    if (hasPopped) {
      return;
    }
    hasPopped = true;
    Navigator.of(context).pop(null);
  }

  @override
  void initState() {
    super.initState();
    nameFocusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();

    linkController.dispose();
    linkFocusNode.dispose();
    nameController.dispose();
    nameFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Link Entry"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: nameFocusNode.requestFocus,
            child: const Text("Name", textAlign: TextAlign.center),
          ),
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            focusNode: nameFocusNode,
            onSubmitted: (_) => linkFocusNode.requestFocus(),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: linkFocusNode.requestFocus,
            child: const Text("Link", textAlign: TextAlign.center),
          ),
          TextField(
            controller: linkController,
            textInputAction:
                !allowSave ? TextInputAction.next : TextInputAction.done,
            focusNode: linkFocusNode,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) =>
                allowSave ? popBookmark() : nameFocusNode.requestFocus(),
          ),
        ],
      ),
      actions: [
        // BB- This gets called for some reason on the initial TextField
        OutlinedButton(
          onPressed: popNothing,
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: allowSave ? popBookmark : null,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
