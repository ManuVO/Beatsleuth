import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'track_page.dart';

class ArtistPage extends StatefulWidget {
  final String artistId;

  ArtistPage(this.artistId);

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  SpotifyService _spotifyService = SpotifyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _spotifyService.getArtist(widget.artistId),
          _spotifyService.getArtistTopTracks(widget.artistId),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final artistData = snapshot.data![0];
            final topTracks = snapshot.data![1]['tracks'];
            final artistName = artistData['name'];
            final artistImage = artistData['images'][0]['url'];
            final artistGenres = artistData['genres'].join(', ');
            final formatter = NumberFormat('#,##0');
            final artistFollowers =
                formatter.format(artistData['followers']['total'] as num);

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
                              artistImage,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          artistName,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Géneros',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(artistGenres),
                          const SizedBox(height: 12.0),
                          const Text('Seguidores mensuales',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(artistFollowers.toString()),
                          /*Text(
                          'Géneros\n$artistGenres',
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Seguidores mensuales\n$artistFollowers',
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),*/
                        ],
                      )),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap:
                        true, // Añade esta línea para evitar errores de restricciones de altura indefinidas
                    physics:
                        NeverScrollableScrollPhysics(), // Añade esta línea para deshabilitar el desplazamiento del ListView
                    itemCount: topTracks.length,
                    itemBuilder: (context, index) {
                      final track = topTracks[index];
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
                                  : const Color(0xFF002236)),
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
                                      heroTag: 'preview' + index.toString(),
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
                                    heroTag: 'externalURL' + index.toString(),
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
                child: Text('Error al cargar los datos del artista'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
