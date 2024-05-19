import 'package:beatsleuth2/data/services/spotify_service.dart';

class HomePageData {
  List<Map<String, dynamic>> albums = [];
  List<Map<String, dynamic>> artists = [];
  List<Map<String, dynamic>> tracks = [];

  Future<void> fetchData() async {
    final spotifyService = SpotifyService();

    // Obtiene los álbumes más populares
    albums = await spotifyService.getPopularAlbums();

    // Obtiene los artistas más populares
    artists = await spotifyService.getPopularArtists();

    // Obtiene las canciones más populares
    tracks = await spotifyService.getPopularSongs();
  }
}