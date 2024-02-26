import 'package:beatsleuth2/data/services/spotify_service.dart';

class SearchPageData {
  List<Map<String, dynamic>> playlists = [];

  Future<void> fetchData() async {
    final spotifyService = SpotifyService();

    playlists = await spotifyService.getTopPlaylists();
  }
}