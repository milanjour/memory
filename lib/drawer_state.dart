import 'package:flutter/material.dart';

class DrawerModel extends ChangeNotifier {

  String _selectedItem = "";

  String getSelectedItem(){
    return _selectedItem;
  }

  setSelectedItem(String newSelectedItem){
    _selectedItem = newSelectedItem;
    notifyListeners();
  }

}