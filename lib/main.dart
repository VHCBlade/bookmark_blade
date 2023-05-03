import 'package:bookmark_blade/bloc_builders.dart';
import 'package:bookmark_blade/events/bookmark.dart';
import 'package:bookmark_blade/events/external_bookmark.dart';
import 'package:bookmark_blade/events/profile.dart';
import 'package:bookmark_blade/events/settings.dart';
import 'package:bookmark_blade/repository_builders.dart';
import 'package:bookmark_blade/ui/main_transfer_screen.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhcblade_theme/vhcblade_picker.dart';
import 'package:vhcblade_theme/vhcblade_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      repositoryBuilders: repositoryBuilders,
      child: MultiBlocProvider(
        blocBuilders: blocBuilders,
        child: VHCBladeThemeBuilder(
          builder: (context, theme) => EventNavigationApp(
            title: 'Bookmark Blade',
            theme: theme,
            builder: (_) => Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Navigator(
                    onGenerateRoute: (_) =>
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    context.fireEvent<void>(ProfileEvent.load.event, null);
    context.fireEvent<void>(BookmarkEvent.loadAll.event, null);
    context.fireEvent<void>(ExternalBookmarkEvent.loadAll.event, null);
    context.fireEvent<void>(SettingsEvent.loadSettings.event, null);
  }

  Widget buildWidget(BuildContext context) {
    return const MainTransferScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FadeThroughWidgetSwitcher(
      duration: const Duration(milliseconds: 600),
      builder: buildWidget,
    );
  }
}
