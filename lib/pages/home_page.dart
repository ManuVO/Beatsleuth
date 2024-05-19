import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'default_page.dart';
import 'track_page.dart';
import 'album_page.dart';
import 'artist_page.dart';
import 'package:beatsleuth2/data/models/homePage.dart';
import 'playlist_page.dart';

class HomePage extends StatefulWidget {
  final HomePageData data;

  const HomePage({Key? key, required this.data}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpotifyService _spotifyService = SpotifyService();
  late Future _dataFuture;

  @override
  void initState() {
    super.initState();
    // Pre-carga los datos al iniciar la página
    _dataFuture = _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Lógica de carga de datos aquí, solo si es necesario
      if (widget.data.albums.isEmpty) {
        print('Cargando datos...');
        final albums = await _spotifyService.getPopularAlbums();
        final artists = await _spotifyService.getPopularArtists();
        final songs = await _spotifyService.getPopularSongs();

        // Actualiza el estado para mostrar los datos en la página
        setState(() {
          widget.data.albums = albums;
          widget.data.artists = artists;
          widget.data.tracks = songs;

        });
      }
    } catch (e) {
      // Mejor manejo de errores en la UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    }
  }

  String _getSaludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) {
      return '¡Buenos días!';
    } else if (hora < 18) {
      return '¡Buenas tardes!';
    } else {
      return '¡Buenas noches!';
    }
  }

  Future<void> writeTrackToFile(Map<String, dynamic> tracks) async {
    try {
      // Encuentra el directorio de documentos de la aplicación
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/track_info.txt';
      final file = File(path);

      // Convierte el mapa de la pista a un string JSON y escribe en el archivo
      final jsonString = jsonEncode(tracks);
      await file.writeAsString(jsonString);
      print('Track info escrita en el archivo: $path');
    } catch (e) {
      print('Ocurrió un error al escribir en el archivo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // El resto del código de construcción de la UI aquí...
          return _buildContent(context);
        }
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    // Método refactorizado para construir el contenido de la página
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 24.0),
                child: RichText(
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: _getSaludo(),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      TextSpan(
                          text: ' \nManuel',
                          style:
                              Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SafeArea(child: DefaultPage())),
                  );
                },
              )
            ],
          ),
          const SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Text(
              'Álbumes populares',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          SizedBox(
            height: 250,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.3,
              ),
              itemCount: widget.data.albums.length,
              itemBuilder: (context, index) {
                final album = widget.data.albums[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SafeArea(
                          child: AlbumPage(album['id']),        
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 16.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            album['images'][0]['url'],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Flexible(
                          child: Column(
                            children: [
                              Text(
                                album['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                album['artists'][0]['name'],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Artistas populares',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          SizedBox(
            height: 230,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.data.artists.length,
              itemBuilder: (context, index) {
                final artista = widget.data.artists[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SafeArea(
                          child: ArtistPage(artista['id']),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      children: [
                        ClipOval(
                          child: Image.network(
                            artista['images'][0]['url'],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Flexible(
                          child: SizedBox(
                            width: 150,
                            child: Text(
                              artista['name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 0.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Canciones populares',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.data.tracks.length,
            itemBuilder: (context, index) {
              final track = widget.data.tracks[index]['track'];
              //writeTrackToFile(track);
              //print('Track info: ID DE LA CANCION: ${track['id']}');
              //print('Track info: ${jsonEncode(track)}');
              // Extrae la lista de artistas de la canción
              final artists = track['artists'];

              // Formatea la lista de artistas en el formato deseado
              final formattedArtists = artists
                  .map((artist) => artist['name'])
                  .toList() // Convertimos el resultado del map a una lista para poder usar join
                  .join(', ') // Usamos ', ' como separador
                  .replaceAll(' feat. ', ', ') // Esto parece redundante, considera removerlo si no tiene otro propósito
                  .replaceFirst(', ', ' feat. '); // Esto reemplazará solo la primera instancia, lo que podría no ser lo deseado si hay más de dos artistas

              return Column(
                children: [
                  const Divider(),
                  InkWell(
                    onTap: () {
                      print('Track info: ${jsonEncode(track)}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TrackPage(trackId: track["id"])
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Image.network(
                        track['album']['images'][0]['url'],
                        width: 50,
                        height: 50,
                      ),
                      title: Text(track['name'],
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      subtitle: Text(formattedArtists,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      trailing:
                          Row(mainAxisSize: MainAxisSize.min, children: [
                        if (track['preview_url'] != null)
                          Container(
                              width: 40,
                              height: 40,
                              child: FloatingActionButton(
                                heroTag: 'homeTrackPreview${track['id'] ?? index}',
                                backgroundColor:
                                    Theme.of(context).focusColor,
                                onPressed: track['preview_url'] !=
                                        null
                                    ? () {
                                        //Implementar reproductor
                                        print(track['preview_url']);
                                      }
                                    : null,
                                child: const Icon(Icons.music_note,
                                    size: 20),
                              )),
                        const SizedBox(width: 10),
                        Container(
                            width: 40,
                            height: 40,
                            child: FloatingActionButton(
                              heroTag: 'homeTrackexternalURL${track['id'] ?? index}',
                              backgroundColor: Colors.blue,
                              onPressed: track['external_urls']
                                          ['spotify'] !=
                                      null
                                  ? () async {
                                      final url = Uri.parse(
                                          track['external_urls']
                                              ['spotify']);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                    }
                                  : null,
                              child: const Icon(Icons.link, size: 20),
                            ))
                      ]),
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}