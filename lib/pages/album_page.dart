import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'track_page.dart';

class AlbumPage extends StatefulWidget {
  final String albumId;

  AlbumPage(this.albumId);

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  SpotifyService _spotifyService = SpotifyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _spotifyService.getAlbum(widget.albumId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final albumData = snapshot.data!;
            final albumName = albumData['name'];
            final albumType = albumData['album_type'];
            final albumImage = albumData['images'][0]['url'];
            // Extrae la lista de artistas de la canción
            final artists = albumData['artists'];

            // Formatea la lista de artistas en el formato deseado
            final formattedArtistsAlbum = artists
                .map((artist) => artist['name'])
                .join(' feat. ')
                .replaceAll(' feat. ', ', ')
                .replaceFirst(', ', ' feat. ');
            final artistName = albumData['artists'][0]['name'];
            final releaseDate = DateTime.parse(albumData['release_date']);
            final releaseYear = releaseDate.year;
            final tracks = albumData['tracks']['items'];
            final trackCount = tracks.length;
            final totalDurationMs =
                tracks.fold(0, (sum, track) => sum + track['duration_ms']);
            final totalDurationMin = (totalDurationMs / 60000).floor();
            final totalDurationSec = ((totalDurationMs % 60000) / 1000).round();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 32.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              albumImage,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            albumName,
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Row(children: [
                    const SizedBox(width: 10),
                    Text(
                      artistName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    )
                  ]),
                  const SizedBox(height: 8.0),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '    ${albumType.toString()[0].toUpperCase()}${albumType.toString().substring(1)} · $releaseYear \n    $trackCount cancion/es, $totalDurationMin min $totalDurationSec s',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      // Extrae la lista de artistas de la canción
                      final artists = track['artists'];

                      // Formatea la lista de artistas en el formato deseado
                      final formattedArtistsTrack = artists
                          .map((artist) => artist['name'])
                          .join(' feat. ')
                          .replaceAll(' feat. ', ', ')
                          .replaceFirst(', ', ' feat. ');
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SafeArea(
                                    child: TrackPage({'track': track}))),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? const Color(0xFF001A2E)
                                : const Color(0xFF002236),
                          ),
                          child: ListTile(
                            title: Text(
                              track['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              formattedArtistsTrack,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              if (track['preview_url'] != null)
                                Container(
                                    width: 40,
                                    height: 40,
                                    child: FloatingActionButton(
                                      heroTag: 'preview$index',
                                      backgroundColor:
                                          Theme.of(context).focusColor,
                                      onPressed: track['preview_url'] != null
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
                                    heroTag: 'externalURL$index',
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
                      );
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error al cargar los datos del álbum'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
