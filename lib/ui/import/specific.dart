import 'package:bookmark_blade/bloc/external/incoming_share.dart';
import 'package:bookmark_blade/events/external_bookmark.dart';
import 'package:bookmark_models/bookmark_models.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

class SpecificImportScreen extends StatefulWidget {
  const SpecificImportScreen({super.key});

  @override
  State<SpecificImportScreen> createState() => _SpecificImportScreenState();
}

class _SpecificImportScreenState extends State<SpecificImportScreen> {
  late final String id;

  @override
  void initState() {
    super.initState();

    id = context
        .readBloc<MainNavigationBloc<String>>()
        .deepNavigationMap["import"]!
        .leaf
        .value;
    Future.delayed(Duration.zero).then((_) => context.fireEvent(
        ExternalBookmarkEvent.importBookmarkCollection.event, id));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<IncomingShareBookmarkBloc>();
    final info = bloc.fromId(id);

    if (info != null) {
      Future.delayed(const Duration(seconds: 3)).then((_) {
        context.fireEvent(NavigationEvent.popDeepNavigation.event, null);
        context.fireEvent(
            NavigationEvent.deepLinkNavigation.event, "external/$id");
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BlocBackButton(),
        title: Text(id),
      ),
      body: Center(
        child: info == null
            ? bloc.attemptingToImport
                ? const CircularProgressIndicator()
                : Text(
                    "We were unable to import this bookmark collection",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  )
            : Text(
                "Successfully Loaded!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
      ),
    );
  }
}
