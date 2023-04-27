import 'package:bookmark_blade/bloc/external/incoming_share.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

void openLink(ShareLink link, BuildContext context) {
  if (!link.isValid) {
    return;
  }

  context.fireEvent(NavigationEvent.pushDeepNavigation.event, link.id);
}

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  late final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Import Bookmark"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child:
                Text("Use Link", style: Theme.of(context).textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.go,
              onSubmitted: (val) => openLink(ShareLink(val), context),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
                onPressed: ShareLink(controller.text).isValid
                    ? () => openLink(ShareLink(controller.text), context)
                    : null,
                child: const Text("Import with Link")),
          ),
        ],
      ),
    );
  }
}
