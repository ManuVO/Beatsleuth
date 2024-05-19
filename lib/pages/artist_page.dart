import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'track_page.dart';

class ArtistPage extends StatefulWidget {
  final String artistId;

  ArtistPage(this.artistId, {Key? key}) : super(key: key);

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final SpotifyService _spotifyService = SpotifyService();

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
            final artistImage = artistData['images'][0]['url'];
            final artistGenres = artistData['genres'].join(', ');
            final formatter = NumberFormat('#,##0');
            final artistFollowers = formatter.format(artistData['followers']['total'] as num);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildArtistImage(artistImage),
                  _buildArtistDetails(context, artistData['name'], artistGenres, artistFollowers),
                  _buildTopTracksList(topTracks),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos del artista: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildArtistImage(String imageUrl) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
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
            imageUrl,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildArtistDetails(BuildContext context, String name, String genres, String followers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            name,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text('Géneros: $genres', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text('Seguidores mensuales: $followers', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTopTracksList(List<dynamic> tracks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return _buildTrackListItem(context, track, index);
      },
    );
  }

  Widget _buildTrackListItem(BuildContext context, dynamic track, int index) {
    final artists = track['artists'].map((artist) => artist['name']).join(', ');
    final trackName = track['name'];
    final previewUrl = track['preview_url'];
    final externalUrl = track['external_urls']['spotify'];

    return InkWell(
      onTap: () {
        print('Track seleccionado: $track');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrackPage(trackId: track["id"])
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: index.isEven ? const Color(0xFF001A2E) : const Color(0xFF002236),
        ),
        child: ListTile(
          title: Text(trackName, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(artists, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (previewUrl != null)
                _buildActionButton(
                  context,
                  icon: Icons.music_note,
                  heroTag: 'artistTrackpreview${widget.artistId}$index',
                  onPressed: () {
                    // Implement preview player
                  },
                  buttonColor: Colors.blue,
                ),
              if (externalUrl != null)
                _buildActionButton(
                  context,
                  icon: Icons.link,
                  heroTag: 'artistTrackexternalURL${widget.artistId}$index',
                  onPressed: () async {
                    final url = Uri.parse(externalUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  buttonColor: Colors.green,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String heroTag, required VoidCallback onPressed, required Color buttonColor}) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(left: 8.0),
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: buttonColor,
        onPressed: onPressed,
        child: Icon(icon, size: 20),
      ),
    );
  }
}
