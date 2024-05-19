import 'package:flutter/material.dart';

import 'puzzle_widget.dart';

class PageWidget extends StatelessWidget {
  final String title;

  const PageWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: const Center(
          child: PuzzleWidget(),
        ));
  }
}
