import 'package:bookmark_blade/bloc/external/incoming_share.dart';
import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Incoming Share Bookmark Bloc", () {
    group("Create Full Id", createFullIdTest);
  });
}

Map<String, List<String> Function()> get commonTestCases => {
      "suffix only": () => [
            "82c42fe0-222f-48c3-b132-7eb4ea77a29d",
            "4f6574d0-1a52-444f-a9a2-146b3e2ce557",
            "d2fcc3a2-611d-41bd-8562-6938c35aca9a",
          ],
      "with Prefix": () => [
            "BookmarkCollectionModel::82c42fe0-222f-48c3-b132-7eb4ea77a29d",
            "a::4f6574d0-1a52-444f-a9a2-146b3e2ce557",
            "BookmarkAmrazingModel::d2fcc3a2-611d-41bd-8562-6938c35aca9a",
          ],
    };

void createFullIdTest() {
  final tester = SerializableListTester<List<String>>(
    testGroupName: "Incoming Share Bookmark Bloc",
    mainTestName: "Create Full Id",
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester) {
      value.forEach((val) {
        tester.addTestValue(IncomingShareBookmarkBloc.createFullId(val));
      });
    },
    testMap: commonTestCases,
  );

  tester.runTests();
}
