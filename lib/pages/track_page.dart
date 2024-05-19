import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/cupertino.dart';

class TrackPage extends StatefulWidget {
  final String trackId;

  TrackPage({required this.trackId, Key? key}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  late Future<Map<String, dynamic>> _trackDetailsFuture;
  late Future<Map<String, dynamic>> _audioFeaturesFuture;
  late Future<List<dynamic>> _recommendationsFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final spotifyService = SpotifyService();
    _trackDetailsFuture = spotifyService.getTrack(widget.trackId);
    _audioFeaturesFuture = spotifyService.getAudioFeatures(widget.trackId);
    _recommendationsFuture = spotifyService.getTrackRecommendations(widget.trackId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _trackDetailsFuture,
          _audioFeaturesFuture,
          _recommendationsFuture,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final trackDetails = snapshot.data![0];
            final audioFeatures = snapshot.data![1];
            final recommendations = snapshot.data![2];
            final artists = trackDetails['artists'].map((artist) => artist['name']).join(', ');

            return Stack(
              children: [
                // Fondo de gradiente que cubre toda la pantalla
                Container(
                  height: MediaQuery.of(context).size.height * 0.32, // Altura total de la pantalla
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(255, 187, 74, 1),
                        Color.fromRGBO(255, 187, 74, 0),
                      ],
                    ),
                  ),
                ),
                // Contenido principal
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Espacio para el efecto visual del gradiente
                      _buildTrackImage(trackDetails['album']['images'][0]['url']),
                      _buildTrackNameAndArtists(trackDetails['name'], artists),
                      _buildActionButtonSection(context, trackDetails),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      _buildTabs(context, trackDetails, audioFeatures, recommendations),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildGradientBackground() {
    return FractionallySizedBox(
      heightFactor: 0.3,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(255, 187, 74, 1),
              Color.fromRGBO(255, 187, 74, 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 5, blurRadius: 7, offset: const Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(imageUrl, width: 150, height: 150, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTrackNameAndArtists(String name, String artists) {
    return Column(
      children: [
        Text(name, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8.0),
        Text(artists, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildActionButtonSection(BuildContext context, Map<String, dynamic> track) {
    // Ajustado para mantener los colores específicos
    final previewUrl = track['preview_url'];
    final spotifyUrl = track['external_urls']['spotify'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (previewUrl != null)
          _ActionButton(
            icon: Icons.music_note,
            label: 'Escuchar Preview',
            onPressed: () => _launchURL(previewUrl),
          ),
        _ActionButton(
          icon: Icons.link,
          label: 'Ver en Spotify',
          onPressed: () => _launchURL(spotifyUrl),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context, Map<String, dynamic> track, Map<String, dynamic> audioFeatures, List<dynamic> recommendations) {
    return Column(
      children: [
        CupertinoSegmentedControl<int>(
          children: {
            0: const Padding(padding: EdgeInsets.all(8.0), child: Text('Características')),
            1: const Padding(padding: EdgeInsets.all(8.0), child: Text('Recomendaciones')),
          },
          groupValue: _selectedIndex,
          onValueChanged: (int value) {
            setState(() {
              _selectedIndex = value;
            });
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Container( // En lugar de Expanded, usa Container para controlar la altura
          height: MediaQuery.of(context).size.height * 0.47, // Ajusta este valor según sea necesario
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              SingleChildScrollView(child: _buildAudioFeatures(context, track, audioFeatures)),
              SingleChildScrollView(child: _buildRecommendations(context, recommendations)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioFeatures(BuildContext context, Map<String, dynamic> track, Map<String, dynamic> audioFeatures) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        padding: const EdgeInsets.only(top: 10, left: 16.0, right: 16.0, bottom: 16.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 34, 67, 91),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text("Popularidad", style: Theme.of(context).textTheme.bodyLarge),
            LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 96, // Ajustado para tener en cuenta el padding y margin
              animation: true,
              lineHeight: 20.0,
              progressColor: Colors.blue,
              percent: track['popularity'] / 100,
              center: Text('${track['popularity']}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              barRadius: const Radius.circular(16),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(left: 35.0, right: 55.0), // Ajusta el valor del padding según necesites
              child: Center( // Asegura que los elementos de la fila estén centrados
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAudioFeatureCard(context, "Tono", getKey(audioFeatures['key'], audioFeatures['mode'])),
                    _buildAudioFeatureCard(context, "BPM", audioFeatures['tempo'].toStringAsFixed(0)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18.0),
            // Las filas de CircularPercentIndicator ya deberían estar centradas debido a MainAxisAlignment.spaceEvenly
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildCircularPercentIndicator(context, audioFeatures['danceability'], 'Bailabilidad'),
                buildCircularPercentIndicator(context, audioFeatures['acousticness'], 'Acústica'),
              ],
            ),
            const SizedBox(height: 18.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildCircularPercentIndicator(context, audioFeatures['energy'], 'Energía'),
                buildCircularPercentIndicator(context, audioFeatures['valence'], 'Positividad'),
              ],
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioFeatureCard(BuildContext context, String featureName, String featureValue) {
    return Column(
      children: [
        Text(featureName, style: Theme.of(context).textTheme.bodyLarge),
        Card(
          color: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              featureValue,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, List<dynamic> recommendations) {
    return Container(
      margin: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 12.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 34, 67, 91),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: recommendations.isNotEmpty ? 5 : 0.0), // Reducido el espacio superior
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          final formattedArtistsRecommendation = recommendation['artists'].map((artist) => artist['name']).join(', ');
          
          return InkWell(
            onTap: () {
              // Implementar navegación a detalles de la recomendación si es necesario
            },
            child: ListTile(
              leading: Image.network(recommendation['album']['images'][0]['url'], width: 50, height: 50),
              title: Text(recommendation['name'], overflow: TextOverflow.ellipsis, maxLines: 1),
              subtitle: Text(formattedArtistsRecommendation, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Manejo de errores si no se puede lanzar la URL
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir el enlace')));
    }
  }

  Widget buildCircularPercentIndicator(BuildContext context, dynamic porcentaje, String nombre) {
    return CircularPercentIndicator(
      header: Text(nombre, style: Theme.of(context).textTheme.bodyLarge),
      radius: 60.0,
      lineWidth: 14.0,
      animation: true,
      percent: porcentaje,
      center: Text('${(porcentaje.toDouble() * 100).round()}%',
          style: Theme.of(context).textTheme.displaySmall),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.blue,
    );
  }

  String getKey(int valorKey, int valormode) {
    List<String> keys = [
      'C',
      'C♯/D♭',
      'D',
      'D♯/E♭',
      'E',
      'F',
      'F♯/G♭',
      'G',
      'G♯/A♭',
      'A',
      'A♯/B♭',
      'B'
    ];

    List<String> mode = ['Menor', 'Mayor'];

    if ((valorKey >= 0 && valorKey <= 11) &&
        (valormode >= 0 && valormode <= 1)) {
      return '${keys[valorKey]} ${mode[valormode]}';
    } else {
      return 'Desconocida';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({Key? key, required this.icon, required this.label, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: null, // Asegurar que cada botón tenga un heroTag único
          backgroundColor: Theme.of(context).focusColor,
          onPressed: onPressed,
          child: Icon(icon),
        ),
        const SizedBox(height: 8.0),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
