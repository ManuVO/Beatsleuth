//import 'package:beatsleuth/models/Music.dart';
//import 'package:beatsleuth/services/audio_service.dart';
import 'package:flutter/material.dart';

class SearchProvider with ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  String? keyword;
  //List<Music>? search;
  bool loadingSearch = false;

  Future searchMusic(String keyword) async {
    loadingSearch = true;
    notifyListeners();
    //search = await AudioService.search(keyword);
    loadingSearch = false;
    notifyListeners();
  }

  onChangeSearch(String keyword) {
    this.keyword = keyword;
    notifyListeners();
  }
}
