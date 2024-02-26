import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/cupertino.dart';

class TrackPage extends StatefulWidget {
  final Map<String, dynamic> cancion;

  TrackPage(this.cancion, {Key? key}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  final PageController _controller = PageController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    SpotifyService spotifyService = SpotifyService();
    Map<String, dynamic> cancion = widget.cancion['track'];
    return Scaffold(
      body: Stack(
        children: [
          FractionallySizedBox(
            heightFactor: 0.225,
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FutureBuilder<List<dynamic>>(
              future: Future.wait([
                spotifyService.getAudioFeatures(cancion['id']),
                spotifyService.getTrackRecommendations(cancion['id']),
                spotifyService.getTrack(cancion['id'])
              ]),
              builder: (context, snapshot) {
                print('Track: ${snapshot.data?[2]}');
                if (snapshot.hasData) {
                  print('ID cancion: ${cancion['id']}');
                  final audioFeatures = snapshot.data?[0];
                  final recommendations = snapshot.data?[1];
                  final track = snapshot.data?[2];
                  // Extrae la lista de artistas de la canción
                  final artists = cancion['artists'];
                  // Formatea la lista de artistas en el formato deseado
                  final formattedArtists = artists
                      .map((artist) => artist['name'])
                      .join(' feat. ')
                      .replaceAll(' feat. ', ', ')
                      .replaceFirst(', ', ' feat. ');

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                track['album']['images'][0]['url'],
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Text(cancion['name'],
                              style: Theme.of(context).textTheme.displayMedium,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 8.0),
                          Text(formattedArtists,
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 18.0),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.0),
                            child: Divider(),
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (cancion['preview_url'] != null)
                                Column(
                                  children: [
                                    FloatingActionButton(
                                      heroTag: 'preview',
                                      backgroundColor:
                                          Theme.of(context).focusColor,
                                      onPressed: cancion['preview_url'] != null
                                          ? () {
                                              //Implementar reproductor
                                              print(cancion['preview_url']);
                                            }
                                          : null,
                                      child: const Icon(Icons.music_note),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text("Escuchar preview",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                              Column(
                                children: [
                                  FloatingActionButton(
                                    heroTag: 'externalURL',
                                    backgroundColor: Colors.blue,
                                    onPressed: cancion['external_urls']
                                                ['spotify'] !=
                                            null
                                        ? () async {
                                            final url = Uri.parse(
                                                cancion['external_urls']
                                                    ['spotify']);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            }
                                          }
                                        : null,
                                    child: const Icon(Icons.link),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text("Ver en Spotify",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18.0),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.0),
                            child: Divider(),
                          ),
                          const SizedBox(height: 12.0),
                          /*
                          CupertinoSegmentedControl(
                            unselectedColor: Colors.grey[100],
                            children: const {
                              0: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Características',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ),
                              1: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Recomendaciones',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ),
                            },
                            groupValue: _selectedIndex,
                            onValueChanged: (int value) {
                              setState(() {
                                _selectedIndex = value;
                                _controller.animateToPage(value,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease);
                              });
                            },
                          ),
                          const SizedBox(height: 12.0),
                          */
                          ExpandablePageView(
                            controller: _controller,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 32.0, right: 32.0, bottom: 12.0),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 34, 67, 91),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(children: [
                                  const SizedBox(height: 16.0),
                                  Text("Popularidad",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          child: LinearPercentIndicator(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                100,
                                            animation: true,
                                            lineHeight: 20.0,
                                            progressColor: Colors.blue,
                                            percent: track['popularity'] * 0.01,
                                            center: Text(
                                                '${track['popularity']}%',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                            barRadius:
                                                const Radius.circular(16),
                                          ),
                                        )
                                      ]),
                                  const SizedBox(height: 16.0),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text("Tono",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge),
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          255, 34, 150, 243),
                                                      Color.fromARGB(
                                                          255, 26, 118, 192)
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 150,
                                                          minWidth: 125,
                                                          maxHeight: 100),
                                                  child: Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            getKey(
                                                                audioFeatures[
                                                                    'key'],
                                                                audioFeatures[
                                                                    'mode']),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text("BPM",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge),
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          255, 34, 150, 243),
                                                      Color.fromARGB(
                                                          255, 26, 118, 192),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 150,
                                                          minWidth: 125,
                                                          maxHeight: 100),
                                                  child: Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            audioFeatures[
                                                                    'tempo']
                                                                .toStringAsFixed(
                                                                    0),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                  const SizedBox(height: 18.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildCircularPercentIndicator(
                                          context,
                                          audioFeatures['danceability'],
                                          'Bailabilidad'),
                                      buildCircularPercentIndicator(
                                          context,
                                          audioFeatures['acousticness'],
                                          'Acústica'),
                                    ],
                                  ),
                                  const SizedBox(height: 18.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildCircularPercentIndicator(context,
                                          audioFeatures['energy'], 'Energía'),
                                      buildCircularPercentIndicator(
                                          context,
                                          audioFeatures['valence'],
                                          'Positividad'),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                ]),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 32.0, right: 32.0, bottom: 12.0),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 34, 67, 91),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: recommendations.length,
                                  itemBuilder: (context, index) {
                                    final recommendation =
                                        recommendations[index];

                                    // Extrae la lista de artistas de la canción
                                    final recommendationArtists =
                                        recommendation['artists'];

                                    // Formatea la lista de artistas en el formato deseado
                                    final formattedArtistsRecommendation =
                                        recommendationArtists
                                            .map((artist) => artist['name'])
                                            .join(' feat. ')
                                            .replaceAll(' feat. ', ', ')
                                            .replaceFirst(', ', ' feat. ');
                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SafeArea(
                                                  child: TrackPage({
                                                    'track': recommendation
                                                  }),
                                                ),
                                              ),
                                            );
                                          },
                                          child: ListTile(
                                            leading: Image.network(
                                              recommendation['album']['images']
                                                  [0]['url'],
                                              width: 50,
                                              height: 50,
                                            ),
                                            title: Text(recommendation['name'],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1),
                                            subtitle: Text(
                                                formattedArtistsRecommendation,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCircularPercentIndicator(
      BuildContext context, dynamic porcentaje, String nombre) {
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
