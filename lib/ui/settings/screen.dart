import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_essay/event_essay.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:vhcblade_theme/vhcblade_picker.dart';
import 'package:vhcblade_theme/vhcblade_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeThroughWidgetSwitcher(builder: (_) {
      final bloc = context.watchBloc<MainNavigationBloc<String>>();
      if (bloc.deepNavigationMap["settings"] != null) {
        switch (bloc.deepNavigationMap["settings"]!.leaf.value) {
          case 'theme':
            return VHCBladeThemePicker(
              navigateBack: () => context.fireEvent(
                  NavigationEvent.popDeepNavigation.event, null),
              enableAdUnlock: false,
            );
          // case 'privacy':
          //   return const PrivacyScreen();
          default:
        }
      }

      return const SettingsPage();
    });
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          Column(children: [
            // const SizedBox(height: 20),
            // Image.asset("icons/180x180.png"),
            const SizedBox(height: 10),
            Text("Bookmark Blade",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
          ]),
          const ListTile(title: Text("Change Settings"), selected: true),
          ListTile(
              title: const Text("Change Theme"),
              onTap: () => context.fireEvent(
                  NavigationEvent.pushDeepNavigation.event, "theme")),
          const ListTile(title: Text("Others"), selected: true),
          ListTile(
              title: const Text("Show Licenses"),
              onTap: () => showLicensePage(context: context)),
          ListTile(
              title: const Text("Our Other Apps"),
              onTap: () => context.fireEvent(
                  EssayEvent.url.event, "https://vhcblade.com/#/apps")),
          ListTile(
              title: const Text("Source Code"),
              onTap: () => context.fireEvent(EssayEvent.url.event,
                  "https://github.com/VHCBlade/bookmark_blade")),
          // ListTile(
          //     title: const Text("Send Us Your Feedback"),
          //     onTap: () => context.fireEvent(
          //         EssayEvent.url.event, "mailto:weight@vhcblade.com")),
          // ListTile(
          //     title: const Text("Privacy Policy"),
          //     onTap: () => context.fireEvent(
          //         NavigationEvent.pushDeepNavigation.event, "privacy")),
        ],
      ),
    );
  }
}
