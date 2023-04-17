import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

class BookmarkListScreen extends StatelessWidget {
  const BookmarkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BlocBackButton()),
    );
  }
}
