import 'package:bookmark_blade/ui/bookmark/main.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

class MainTransferScreen extends StatelessWidget {
  const MainTransferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<MainNavigationBloc<String>>();

    final navigationBar = MainNavigationBar(
      currentNavigation: bloc.currentMainNavigation,
      navigationPossibilities: const [
        "bookmark",
        "external",
        "import",
        "settings"
      ],
      builder: (index, onTap) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Bookmarks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmarks), label: 'External'),
          BottomNavigationBarItem(
              icon: Icon(Icons.import_export), label: 'Import'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );

    return Scaffold(
      bottomNavigationBar: navigationBar,
      body: const MainCarouselScreen(),
    );
  }
}

class MainCarouselScreen extends StatelessWidget {
  const MainCarouselScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainNavigationFullScreenCarousel(
        navigationOptions: const ["bookmark", "external", "import", "settings"],
        navigationBuilder: (_, navigation) {
          switch (navigation) {
            case "bookmark":
              return const BookmarkScreen();
            default:
              return Container();
          }
        });
  }
}
