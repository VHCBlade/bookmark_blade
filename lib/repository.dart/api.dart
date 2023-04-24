import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:http/http.dart';

Stream<List<int>> stringToStream(String str) async* {
  List<int> codeUnits = str.codeUnits.toList();
  for (int i = 0; i < codeUnits.length; i += 4) {
    yield codeUnits.sublist(i, i + 4);
  }
}

abstract class APIRepository extends Repository {
  FutureOr<StreamedResponse> request(
      String method, String urlSuffix, void Function(Request) addToRequest);
}

class ServerAPIRepository extends APIRepository {
  final String server;
  late final client = Client();

  ServerAPIRepository(this.server);
  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) => [];

  @override
  Future<StreamedResponse> request(
      String method, String urlSuffix, void Function(Request) addToRequest) {
    final fullUrl = "$server$urlSuffix";
    final request = Request(method, Uri.parse(fullUrl));
    addToRequest(request);
    return client.send(request);
  }
}
