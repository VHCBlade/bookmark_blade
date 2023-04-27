import 'dart:async';

import 'package:bookmark_blade/bloc/alert_bloc.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';

class AlertWatcher extends StatefulWidget {
  final Widget child;

  const AlertWatcher({super.key, required this.child});

  @override
  State<AlertWatcher> createState() => _AlertWatcherState();
}

class _AlertWatcherState extends State<AlertWatcher> {
  late final StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = context.readBloc<AlertBloc>().stream.listen((event) {});
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AlertInfoDialog extends StatelessWidget {
  const AlertInfoDialog({super.key, required this.info});
  final AlertInfo info;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(info.event.label),
      content: Text(info.message),
      scrollable: true,
      actions: [
        ElevatedButton(
            onPressed: Navigator.of(context).pop, child: const Text("OK"))
      ],
    );
  }
}
