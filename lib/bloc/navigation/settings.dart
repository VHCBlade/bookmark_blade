import 'package:event_navigation/event_navigation.dart';

class SettingsDeepNavigationStrategy extends DeepNavigationStrategy<String> {
  @override
  bool shouldAcceptNavigation(String subNavigation, DeepNavigationNode? root) {
    if (root == null) {
      switch (subNavigation) {
        case "theme":
        case "privacy":
          return true;
        default:
          return false;
      }
    }

    return false;
  }
}
