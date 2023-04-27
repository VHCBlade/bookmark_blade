import 'package:bookmark_blade/bloc/external/incoming_share.dart';
import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Share Link", () {
    group("isValid", isValidTest);
    group("Id", idTest);
  });
}

Map<String, List<String> Function()> get commonTestCases => {
      "empty": () => [
            "",
            "/",
            " ",
            " / ",
            "  /",
            "/   ",
            "https://bookmark.vhcblade.com/import/",
          ],
      "justId": () => [
            "82c42fe0-222f-48c3-b132-7eb4ea77a29d",
            "4f6574d0-1a52-444f-a9a2-146b3e2ce557",
            "d2fcc3a2-611d-41bd-8562-6938c35aca9a",
          ],
      "fullLink": () => [
            "https://bookmark.vhcblade.com/#/import/82c42fe0-222f-48c3-b132-7eb4ea77a29d",
            "https://bookmark.vhcblade.com/#/import/4f6574d0-1a52-444f-a9a2-146b3e2ce557",
            "https://bookmark.vhcblade.com/#/import/d2fcc3a2-611d-41bd-8562-6938c35aca9a",
          ],
    };

void idTest() {
  final tester = SerializableListTester<List<String>>(
    testGroupName: "Share Link",
    mainTestName: "Id",
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester) {
      value.forEach((val) {
        tester.addTestValue(val);
        tester.addTestValue(ShareLink(val).id);
      });
    },
    testMap: commonTestCases,
  );

  tester.runTests();
}

void isValidTest() {
  final tester = SerializableListTester<List<String>>(
    testGroupName: "Share Link",
    mainTestName: "isValid",
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester) {
      value.forEach((val) {
        tester.addTestValue(val);
        tester.addTestValue(ShareLink(val).isValid);
      });
    },
    testMap: commonTestCases,
  );

  tester.runTests();
}
