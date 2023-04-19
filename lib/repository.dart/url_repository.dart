import 'package:event_essay/event_essay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_bloc/event_bloc.dart';

class UrlRepository extends Repository {
  /// Generates the listener map that this [Repository] will add to the
  @override
  List<BlocEventListener> generateListeners(BlocEventChannel eventChannel) => [
        eventChannel.addEventListener<String>(
            EssayEvent.url.event, (_, val) => launchTarget(val)),
      ];

  void launchTarget(String target) {
    launchUrl(Uri.parse(prefixIfNecessary(target)),
        mode: LaunchMode.externalApplication);
  }

  String prefixIfNecessary(String target) {
    if (!target.startsWith(RegExp("[^\\/]*://"))) {
      return target;
    }

    return "https://$target";
  }
}
