import 'dart:async';

import 'package:bookmark_blade/events/alert.dart';
import 'package:event_bloc/event_bloc.dart';

class AlertInfo {
  final AlertEvent event;
  final String message;

  AlertInfo(this.event, this.message);
}

class AlertBloc extends Bloc {
  AlertBloc({required super.parentChannel}) {
    eventChannel.addEventListener(
        AlertEvent.noInternetAccess.event,
        (event, value) => _stream.sink.add(AlertInfo(
            AlertEvent.noInternetAccess,
            "We were unable to access the internet. Try again later when you have a more stable internet connection.")));
    eventChannel.addEventListener(AlertEvent.error.event,
        (event, value) => _stream.sink.add(AlertInfo(AlertEvent.error, value)));
  }

  final _stream = StreamController<AlertInfo>.broadcast();

  Stream<AlertInfo> get stream => _stream.stream;
}
