import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'drawer_state.dart';

Drawer buildDrawer(BuildContext context) {
  return Drawer(
    child: Consumer<DrawerModel>(builder: (context, drawerModel, child) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Container(),
          ),
          ListTile(
            title: const Text('Play'),
            onTap: () {
              drawerModel.setSelectedItem("play");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Credits'),
            onTap: () {
              drawerModel.setSelectedItem("credits");
              Navigator.pop(context);
            },
          ),
        ],
      );
    }),
  );
}
