import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';
import 'package:beatsleuth2/pages/track_page.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:beatsleuth2/data/models/searchPage.dart';
import 'dart:async';
import 'album_page.dart';
import 'artist_page.dart';

class SearchPage extends StatefulWidget {
  final SearchPageData data;
  const SearchPage({Key? key, required this.data}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Instancia del servicio de Spotify
  final SpotifyService _spotifyService = SpotifyService();
  final TextEditingController _searchController = TextEditingController();
  late Timer _debounceTimer;

  List<Map<String, dynamic>> _playlists = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
    _searchController.addListener(_onSearchChanged);
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer.cancel();
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    if (widget.data.playlists.isNotEmpty) {
      _playlists = widget.data.playlists;
    } else {
      final playlists = await _spotifyService.getTopPlaylists();
      setState(() {
        widget.data.playlists = playlists;
        _playlists = widget.data.playlists;
      });
    }
  }

  void _onSearchChanged() async {
    _debounceTimer.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      if (_searchController.text.isEmpty) {
        setState(() {
          _showSearchResults = false;
        });
      } else {
        final results = await _spotifyService.search(_searchController.text);
        setState(() {
          _searchResults = results;
          _showSearchResults = true;
        });
      }
    });
  }

  void saveFile(String content) async {
    final directory = await getApplicationDocumentsDirectory();
    //print(directory.path);
    final file = File('${directory.path}/archivo.txt');
    await file.writeAsString(content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Búsqueda',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '¿Qué canción buscas?',
              ),
              controller: _searchController,
            ),
          ),
          Visibility(
            visible: !_showSearchResults,
            child: Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 16.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disfruta de las mejores playlist',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4.0),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: _playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = _playlists[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 16.0),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      playlist['images'][0]['url'],
                                      width: 125,
                                      height: 125,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Flexible(
                                    child: Text(
                                      playlist['name'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showSearchResults,
            child: Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 4.0),
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    var jsonString = jsonEncode(_searchResults);
                    saveFile(jsonString);
                    //print(result);
                    String imageUrl = '';
                    String title = '';
                    String subtitle = '';
                    if (result['type'] == 'track') {
                      if (result['album']['images'].isNotEmpty) {
                        imageUrl = result['album']['images'][0]['url'];
                      }
                      title = result['name'];
                      subtitle = result['artists'][0]['name'];
                    } else if (result['type'] == 'album') {
                      if (result['images'].isNotEmpty) {
                        imageUrl = result['images'][0]['url'];
                      }
                      title = result['name'];
                      subtitle = 'Album - ${result['artists'][0]['name']}';
                    } else if (result['type'] == 'artist') {
                      if (result['images'].isNotEmpty) {
                        imageUrl = result['images'][0]['url'];
                      }
                      title = result['name'];
                    }
                    if (imageUrl.isEmpty) {
                      return const SizedBox();
                    } else {
                      return InkWell(
                        onTap: () {
                          if (result['type'] == 'track') {
                            _navigateToTrackPage(result);
                          } else if (result['type'] == 'album') {
                            _navigateToAlbumPage(result['id']);
                          } else if (result['type'] == 'artist') {
                            _navigateToArtistPage(result['id']);
                          }
                        },
                        child: ListTile(
                          leading: _imageType(result['type'], imageUrl),
                          title: Text(title),
                          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _imageType(String type, String imageUrl) {
    if (type == 'album') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(imageUrl),
      );
    } else if (type == 'artist') {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      // Devuelve una imagen normal para otros tipos de objetos
      return Image.network(imageUrl);
    }
  }

  void _navigateToTrackPage(Map<String, dynamic> track) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafeArea(
          child: TrackPage({'track': track}),
        ),
      ),
    );
  }

  void _navigateToAlbumPage(String albumId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafeArea(
          child: AlbumPage(albumId),
        ),
      ),
    );
  }

  void _navigateToArtistPage(String artistId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafeArea(
          child: ArtistPage(artistId),
        ),
      ),
    );
  }
}
