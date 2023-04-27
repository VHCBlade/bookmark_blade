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
            padding: const EdgeInsets.all(20),
            child:
                Text("Use Link", style: Theme.of(context).textTheme.titleLarge),
          )
        ],
      ),
    );
  }
}
