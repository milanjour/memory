import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Theme(
        data:
            ThemeData(brightness: Brightness.light, primarySwatch: Colors.teal),
        child: Scaffold(
            body: CustomScrollView(slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            "https://freesound.org/s/608624/",
            "https://freesound.org/s/572936/",
            "https://freesound.org/s/439211/",
            "https://freesound.org/s/439191/"
          ].map((text) => Text(text)).toList()))
        ])));
  }
}
