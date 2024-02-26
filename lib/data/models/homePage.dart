import 'package:beatsleuth2/data/services/spotify_service.dart';

class HomePageData {
  List<Map<String, dynamic>> albumes = [];
  List<Map<String, dynamic>> artistas = [];
  List<Map<String, dynamic>> canciones = [];

  Future<void> fetchData() async {
    final spotifyService = SpotifyService();

    // Obtiene los álbumes más populares
    albumes = await spotifyService.getPopularAlbums();

    // Obtiene los artistas más populares
    artistas = await spotifyService.getPopularArtists();

    // Obtiene las canciones más populares
    canciones = await spotifyService.getPopularSongs();
  }
}