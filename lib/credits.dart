import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  static const String routeName = '/credits';

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
              delegate: SliverChildListDelegate(
                  ["url1", "url2"].map((text) => Text(text)).toList()))
        ])));
  }
}
