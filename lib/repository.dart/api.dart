import 'dart:async';
import 'dart:convert';

import 'package:event_bloc/event_bloc.dart';
import 'package:http/http.dart';

extension FutureResponse on StreamedResponse {
  Future<String> get body async => (await stream.toStringStream().toList())
      .reduce((value, element) => "$value$element");
}

Stream<List<int>> stringToStream(String str) async* {
  List<int> codeUnits = str.codeUnits.toList();
  for (int i = 0; i < codeUnits.length; i += 4) {
    yield codeUnits.sublist(i, i + 4);
  }
}

abstract class APIRepository extends Repository {
  FutureOr<StreamedResponse> request(
      String method, String urlSuffix, void Function(Request) addToRequest);

  String createShareLink(String id);
}

class ServerAPIRepository extends APIRepository {
  final String apiServer;
  final String website;
  late final client = Client();

  ServerAPIRepository({required this.apiServer, required this.website});
  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) => [];

  @override
  Future<StreamedResponse> request(String method, String urlSuffix,
      void Function(Request) addToRequest) async {
    final fullUrl = "$apiServer$urlSuffix";
    final request = Request(method, Uri.parse(fullUrl));
    addToRequest(request);
    try {
      return await client.send(request);
    } on Object {
      return StreamedResponse(
          Stream.fromIterable(
              [utf8.encode("Unable to connect to the server...")]),
          504);
    }
  }

  @override
  String createShareLink(String id) {
    return "${website}import/$id";
  }
}
