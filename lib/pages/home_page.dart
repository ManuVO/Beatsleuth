import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';
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
  // Instancia del servicio de Spotify
  final SpotifyService _spotifyService = SpotifyService();

  // Listas para almacenar los datos de álbumes, artistas y canciones
  List<Map<String, dynamic>> _albumes = [];
  List<Map<String, dynamic>> _artistas = [];
  List<Map<String, dynamic>> _canciones = [];

  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Carga los datos de álbumes, artistas y canciones al iniciar la página
    if (widget.data.albumes.isNotEmpty) {
      _albumes = widget.data.albumes;
      _artistas = widget.data.artistas;
      _canciones = widget.data.canciones;

      _dataLoaded = true;
    }
    //_loadData();
  }

  // Método para cargar los datos de álbumes, artistas y canciones
  Future<void> _loadData() async {
    if (!_dataLoaded) {
      try {
        print('Cargando datos...');

        // Obtiene los álbumes más populares
        final albums = await _spotifyService.getPopularAlbums();

        // Obtiene los artistas más populares
        final artists = await _spotifyService.getPopularArtists();

        // Obtiene las canciones más populares
        final songs = await _spotifyService.getPopularSongs();

        // Actualiza el estado para mostrar los datos en la página
        setState(() {
          widget.data.albumes = albums;
          _albumes = albums;
          widget.data.artistas = artists;
          _artistas = artists;
          widget.data.canciones = songs;
          _canciones = songs;
        });
      } catch (e) {
        print('Error al cargar los datos: $e');
      }
      _dataLoaded = true;
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Muestra un widget de carga mientras se espera la respuesta de la API
          return const Center(child: CircularProgressIndicator());
        } else {
          // Muestra el contenido de la página una vez que se han cargado los datos
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
                    itemCount: _albumes.length,
                    itemBuilder: (context, index) {
                      final album = _albumes[index];

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
                                      maxLines: 2,
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
                    itemCount: _artistas.length,
                    itemBuilder: (context, index) {
                      final artista = _artistas[index];
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
                  itemCount: _canciones.length,
                  itemBuilder: (context, index) {
                    final cancion = _canciones[index];
                    // Extrae la lista de artistas de la canción
                    final artists = cancion['track']['artists'];

                    // Formatea la lista de artistas en el formato deseado
                    final formattedArtists = artists
                        .map((artist) => artist['name'])
                        .join(' feat. ')
                        .replaceAll(' feat. ', ', ')
                        .replaceFirst(', ', ' feat. ');
                    return Column(
                      children: [
                        const Divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SafeArea(child: TrackPage(cancion))),
                            );
                          },
                          child: ListTile(
                            leading: Image.network(
                              cancion['track']['album']['images'][0]['url'],
                              width: 50,
                              height: 50,
                            ),
                            title: Text(cancion['track']['name'],
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                            subtitle: Text(formattedArtists,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              if (cancion['track']['preview_url'] != null)
                                Container(
                                    width: 40,
                                    height: 40,
                                    child: FloatingActionButton(
                                      heroTag: 'preview$index',
                                      backgroundColor:
                                          Theme.of(context).focusColor,
                                      onPressed: cancion['track']
                                                  ['preview_url'] !=
                                              null
                                          ? () {
                                              //Implementar reproductor
                                              print(cancion['track']
                                                  ['preview_url']);
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
                                    heroTag: 'externalURL$index',
                                    backgroundColor: Colors.blue,
                                    onPressed: cancion['track']['external_urls']
                                                ['spotify'] !=
                                            null
                                        ? () async {
                                            final url = Uri.parse(
                                                cancion['track']
                                                        ['external_urls']
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
      },
    );
  }
}
