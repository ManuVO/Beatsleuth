import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class SpotifyService {
  // Reemplaza estos valores con tus propias credenciales de Spotify
  final String clientId = '2efb385b388f49ce9af41d6c0dbf0022';
  final String clientSecret = 'ee75efb22e724f42ae109b159a928d95';

  // URL base de la API de Spotify
  final String baseUrl = 'https://api.spotify.com/v1';

  // Token de acceso a la API de Spotify
  String? _accessToken;

  // Método para autenticarse en la API de Spotify
  Future<void> _authenticate() async {
    // Codifica las credenciales en base64
    final String credentials =
        base64Url.encode(utf8.encode('$clientId:$clientSecret'));

    // Realiza una petición POST para obtener el token de acceso
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    // Decodifica la respuesta y guarda el token de acceso
    final data = jsonDecode(response.body);
    _accessToken = data['access_token'];
  }

  Future<List<Map<String, dynamic>>> getPopularAlbums() async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Obtiene la lista de reproducción más popular en Estados Unidos
    final playlistResponse = await http.get(
      Uri.parse(
          '$baseUrl/browse/categories/toplists/playlists?country=US&limit=1'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    final playlistData = jsonDecode(playlistResponse.body);
    final playlistId = playlistData['playlists']['items'][0]['id'];

    // Obtiene las canciones de la lista de reproducción
    final tracksResponse = await http.get(
      Uri.parse('$baseUrl/playlists/$playlistId/tracks?limit=50'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    final tracksData = jsonDecode(tracksResponse.body);

    // Extrae los datos de todos los álbumes de las canciones
    final allAlbums =
        tracksData['items'].map((item) => item['track']['album']).toList();

    // Mezcla aleatoriamente la lista de álbumes
    allAlbums.shuffle();

    // Selecciona los primeros 6 álbumes de la lista mezclada
    final popularAlbums =
        List<Map<String, dynamic>>.from(allAlbums.take(6).toList());

    // Devuelve los datos de los álbumes
    return popularAlbums;
  }

  // Método para obtener los artistas más populares
  Future<List<Map<String, dynamic>>> getPopularArtists() async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Obtiene el año actual
    final int currentYear = DateTime.now().year;

    // Realiza una petición GET para buscar artistas populares del año actual
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=year:$currentYear&type=artist&limit=50'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    // Decodifica la respuesta y obtiene la lista de artistas
    final data = jsonDecode(response.body);
    final allArtists = data['artists']['items'];

    // Mezcla aleatoriamente la lista de artistas
    allArtists.shuffle();

    // Selecciona los primeros 6 artistas de la lista mezclada
    final popularArtists =
        List<Map<String, dynamic>>.from(allArtists.take(6).toList());

    return popularArtists;
  }

  // Método para obtener las canciones más populares
  Future<List<Map<String, dynamic>>> getPopularSongs() async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Realiza una petición GET para obtener las canciones más populares
    final response = await http.get(
      Uri.parse('$baseUrl/playlists/37i9dQZEVXbMDoHDwVN2tF/tracks?limit=50'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    // Decodifica la respuesta y devuelve los datos de las canciones
    final data = jsonDecode(response.body);
    final allSongs = data['items'];

    // Mezcla aleatoriamente la lista de canciones
    allSongs.shuffle();

    // Selecciona las primeras 10 canciones de la lista mezclada
    final popularSongs =
        List<Map<String, dynamic>>.from(allSongs.take(10).toList());

/*
    // Suponiendo que popularSongs es una List<Map<String, dynamic>> con los datos de las canciones
    for (var song in popularSongs) {
      // Accede a los valores que quieras imprimir de cada canción
      var songId = song['track']['id']; // ID de la canción
      var songName = song['track']['name']; // Nombre de la canción
      var artistName = song['track']['artists'][0]['name']; // Nombre del primer artista

      // Imprime los detalles de la canción
      print('ID de la Canción: $songId, Nombre de la Canción: $songName, Artista: $artistName');
    }
*/
    return popularSongs;
  }

  Future<List<Map<String, dynamic>>> getTopPlaylists() async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Realiza una petición GET para obtener las playlists más populares de Estados Unidos
    final response = await http.get(
      Uri.parse(
          '$baseUrl/browse/categories/toplists/playlists?country=US&limit=10'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    // Decodifica la respuesta y devuelve los datos de las playlists
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['playlists']['items']);
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$query&type=artist,album,track&limit=10'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> results = [];

      final List<dynamic> artists = data['artists']['items'];
      final List<dynamic> albums = data['albums']['items'];
      final List<dynamic> tracks = data['tracks']['items'];

      // Función para calcular el peso de relevancia de un resultado
      double calculateWeight(
          String name, String query, String type, double popularity) {
        final String lowerCaseName = name.toLowerCase();
        final String lowerCaseQuery = query.toLowerCase();
        double weight = 0.0;

        // Calcular el peso basado en las coincidencias de letras
        for (final char in query.toLowerCase().runes) {
          final letter = String.fromCharCode(char);
          if (lowerCaseName.contains(letter)) {
            weight += 0.05;
          }
        }

        if (lowerCaseName == lowerCaseQuery) {
          weight = 0.75; // Coincidencia exacta
        } else if (lowerCaseName.startsWith(lowerCaseQuery)) {
          weight = 0.7; // Coincidencia en el inicio
        } else if (lowerCaseName.contains(lowerCaseQuery)) {
          weight = 0.7; // Coincidencia en cualquier lugar
        }

        // Ajustar el peso según el tipo
        if (type == 'artist') {
          weight += 0.8; // Aumentar el peso para los artistas
          weight += (popularity / 100) *
              0.75; // Ajustar el peso según la popularidad del artista
        } else if (type == 'track') {
          weight += 0.7; // Aumentar el peso para las canciones
          weight += (popularity / 100) *
              1.0; // Ajustar el peso según la popularidad de la canción
        } else if (type == 'album') {
          weight += 1.1; // Aumentar el peso para los álbumes (relevancia menor)
        }

        // Ajustar el peso según la longitud del nombre
        weight -= (name.length - query.length) * 0.01;

        return weight;
      }

      // Agregar resultados de artistas
      for (final artist in artists) {
        final double popularity = artist['popularity'].toDouble();
        final double weight =
            calculateWeight(artist['name'], query, 'artist', popularity);
        results.add({...artist, 'weight': weight});
      }

      // Agregar resultados de álbumes
      for (final album in albums) {
        final double weight = calculateWeight(album['name'], query, 'album',
            0.0); // No considerar la popularidad de los álbumes
        results.add({...album, 'weight': weight});
      }

      // Agregar resultados de canciones
      for (final track in tracks) {
        final double popularity = track['popularity'].toDouble();
        final double weight =
            calculateWeight(track['name'], query, 'track', popularity);
        results.add({...track, 'weight': weight});
      }

      // Ordenar resultados por peso de relevancia (descendente)
      results.sort((a, b) => b['weight'].compareTo(a['weight']));

      return results;
    } else {
      throw Exception('Error en la solicitud: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> songSearch(String query) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$query&type=track&limit=10'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> results = [];

      final List<dynamic> tracks = data['tracks']['items'];

      double calculateWeight(String name, String query, double popularity) {
        final String lowerCaseName = name.toLowerCase();
        final String lowerCaseQuery = query.toLowerCase();
        double weight = 0.0;

        // Calcular el peso basado en las coincidencias de letras
        for (final char in query.toLowerCase().runes) {
          final letter = String.fromCharCode(char);
          if (lowerCaseName.contains(letter)) {
            weight += 0.05;
          }
        }

        if (lowerCaseName == lowerCaseQuery) {
          weight = 0.75; // Coincidencia exacta
        } else if (lowerCaseName.startsWith(lowerCaseQuery)) {
          weight = 0.7; // Coincidencia en el inicio
        } else if (lowerCaseName.contains(lowerCaseQuery)) {
          weight = 0.7; // Coincidencia en cualquier lugar
        }

        // Ajustar el peso para las canciones
        weight += 0.7;
        // Ajustar el peso según la popularidad de la canción
        weight += (popularity / 100) * 1.0;

        // Ajustar el peso según la longitud del nombre
        weight -= (name.length - query.length) * 0.01;

        return weight;
      }

      // Agregar resultados de canciones
      for (final track in tracks) {
        final double popularity = track['popularity'].toDouble();
        final double weight = calculateWeight(track['name'], query, popularity);
        results.add({...track, 'weight': weight});
      }

      // Ordenar resultados por peso de relevancia (descendente)
      results.sort((a, b) => b['weight'].compareTo(a['weight']));

      return results;
    } else {
      throw Exception('Error en la solicitud: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> advancedSearch({
    String? song,
    double? popularityMin,
    double? popularityMax,
    double? danceabilityMin,
    double? danceabilityMax,
    double? acousticsMin,
    double? acousticsMax,
    double? energyMin,
    double? energyMax,
    double? positivityMin,
    double? positivityMax,
    String? tone,
    int? bpm,
  }) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Construye la URL con los filtros necesarios
    String baseUrl = 'https://api.spotify.com/v1/recommendations?limit=30';
    if (song != null) {
      baseUrl += '&seed_tracks=' + song.toString();
    }
    if (popularityMin != null) {
      // La API de Spotify no admite directamente filtrar por popularidad,
      // por lo que es posible que debas manejar esto por separado después de recuperar los resultados.
    }
    if (danceabilityMin != null)
      baseUrl += '&min_danceability=' + danceabilityMin.toString();
    if (danceabilityMax != null)
      baseUrl += '&max_danceability=' + danceabilityMax.toString();
    if (acousticsMin != null)
      baseUrl += '&min_acousticness=' + acousticsMin.toString();
    if (acousticsMax != null)
      baseUrl += '&max_acousticness=' + acousticsMax.toString();
    if (energyMin != null) baseUrl += '&min_energy=' + energyMin.toString();
    if (energyMax != null) baseUrl += '&max_energy=' + energyMax.toString();
    if (positivityMin != null)
      baseUrl += '&min_valence=' + positivityMin.toString();
    if (positivityMax != null)
      baseUrl += '&max_valence=' + positivityMax.toString();
    if (tone != null)
      baseUrl += '&key=' +
          tone; // Asumiendo que tone es un valor de 0 a 11 representando las claves musicales
    if (bpm != null) baseUrl += '&target_tempo=' + bpm.toString();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['tracks'] is List) {
        for (var track in data['tracks']) {
          if (track is Map && track['name'] is String) {
            print(track['name']); // Imprimir el nombre de la pista
          }
        }
      }
      final results = List<Map<String, dynamic>>.from(data['tracks']);
      return results;
    } else {
      // TODO: Maneja adecuadamente los errores
      return [];
    }
  }

  Future<Map<String, dynamic>> getAudioFeatures(String trackId) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Realiza una petición GET para obtener las características de audio de la canción
    final response = await http.get(
      Uri.parse('$baseUrl/audio-features/$trackId'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    // Decodifica la respuesta y devuelve los datos de las características de audio
    final data = jsonDecode(response.body);
    print(data);
    return data;
  }

  Future<List<Map<String, dynamic>>> getTrackRecommendations(
      String trackId) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Realiza una petición GET para obtener recomendaciones basadas en la canción
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations?seed_tracks=$trackId&limit=10'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    // Decodifica la respuesta y devuelve los datos de las canciones recomendadas
    final data = jsonDecode(response.body);
    final trackRecommendations =
        List<Map<String, dynamic>>.from(data['tracks']);
    return trackRecommendations;
  }

  // Método para obtener una cancion
  Future<Map<String, dynamic>> getTrack(String trackId) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Realiza una petición GET para obtener información sobre la canción
    final response = await http.get(
      Uri.parse('$baseUrl/tracks/$trackId'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    // Decodifica la respuesta y devuelve los datos de la cancion
    final data = jsonDecode(response.body);

    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> getAlbum(String albumId) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Realiza una petición GET para obtener información sobre el álbum
    final response = await http.get(
      Uri.parse('$baseUrl/albums/$albumId'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    final data = jsonDecode(response.body);
    return data;
  }

  // Método para obtener la imagen del album de una cancion
  Future<String> getTrackImage(String trackId) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Realiza una petición GET para obtener información sobre la canción
    final response = await http.get(
      Uri.parse('$baseUrl/tracks/$trackId'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    // Decodifica la respuesta y obtiene los datos de la canción
    final data = jsonDecode(response.body);

    // Accede a la información del álbum y obtiene la URL de la imagen
    final album = data['album'];
    final imageUrl = album['images'][0]['url'];

    return imageUrl;
  }

  Future<Map<String, dynamic>> getArtist(String artistId) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Realiza una petición GET para obtener información sobre el artista
    final response = await http.get(
      Uri.parse('$baseUrl/artists/$artistId'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> getArtistTopTracks(String artistId) async {
    // Autentica en la API de Spotify si es necesario
    if (_accessToken == null) await _authenticate();

    // Realiza una petición GET para obtener las canciones más populares del artista
    final response = await http.get(
      Uri.parse('$baseUrl/artists/$artistId/top-tracks?market=US'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    final data = jsonDecode(response.body);
    return data;
  }
}
