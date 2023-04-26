import 'package:event_navigation/event_navigation.dart';

class ImportDeepNavigationStrategy extends DeepNavigationStrategy<String> {
  @override
  bool shouldAcceptNavigation(String subNavigation, DeepNavigationNode? root) {
    if (root == null) {
      return true;
    }

    return false;
  }
}
