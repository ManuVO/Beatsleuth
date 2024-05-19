import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';
import 'dart:async';

import 'track_page.dart';

class AdvancedSearchPage extends StatefulWidget {
  const AdvancedSearchPage({Key? key}) : super(key: key);

  @override
  _AdvancedSearchPageState createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  final SpotifyService _spotifyService = SpotifyService();
  final TextEditingController _searchController = TextEditingController();
  late Timer _debounceTimer;

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _advancedSearchResults = [];
  Map<String, dynamic>? _selectedSong;

  bool _showAdvancedResults = false;

  String? selectedSongId;
  double? popularityMin, popularityMax;
  double? danceabilityMin, danceabilityMax;
  double? acousticsMin, acousticsMax;
  double? energyMin, energyMax;
  double? positivityMin, positivityMax;
  String? tone;
  int? toneKey;
  int? bpm;

  @override
  void initState() {
    super.initState();
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

  void _onSearchChanged() {
    _debounceTimer.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      if (_searchController.text.isEmpty) {
        setState(() {});
      } else {
        final results =
            await _spotifyService.songSearch(_searchController.text);
        setState(() {
          _searchResults = results;
        });
      }
    });
  }

  void _performAdvancedSearch() async {
    // Realiza una búsqueda avanzada utilizando los filtros
    var results = await _spotifyService.advancedSearch(
        song: selectedSongId,
        popularityMin: popularityMin,
        popularityMax: popularityMax,
        danceabilityMin: danceabilityMin,
        danceabilityMax: danceabilityMax,
        acousticsMin: acousticsMin,
        acousticsMax: acousticsMax,
        energyMin: energyMin,
        energyMax: energyMax,
        positivityMin: positivityMin,
        positivityMax: positivityMax,
        tone: tone,
        bpm: bpm);
    setState(() {
      _advancedSearchResults = results;
      _showAdvancedResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showAdvancedResults) ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Esta columna contiene el texto y ocupa la mayoría del espacio
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 0.5),
                                ),
                              ),
                              child: Text(
                                'Canciones parecidas a "${_selectedSong?['name'] ?? 'Unknown'}"',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayLarge,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2, // ajuste según necesidad
                              ),
                            ),
                          ),
                          // Esta columna contiene el botón de cerrar y no ocupa mucho espacio
                          Column(
                            mainAxisSize: MainAxisSize
                                .min, // para limitar el tamaño de la columna
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showAdvancedResults = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _advancedSearchResults.length,
                          itemBuilder: (context, index) {
                            final song = _advancedSearchResults[index];
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  _showAdvancedResults = false;
                                });
                                _navigateToTrackPage(song);
                              },
                              leading: song['album']['images'].isNotEmpty
                                  ? Image.network(
                                      song['album']['images'][0]['url'])
                                  : null,
                              title: Text(song['name']),
                              subtitle: Text(song['artists'][0]['name']),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Búsqueda Avanzada',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              if (_selectedSong != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Color.fromARGB(255, 18, 63, 85),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_selectedSong!['album']['images'].isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            _selectedSong!['album']['images'][0]['url'],
                            width: 60,
                            height: 60,
                          ),
                        ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedSong!['name'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              _selectedSong!['artists'][0]['name'],
                              style: TextStyle(color: Colors.grey[300]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedSong = null;
                            selectedSongId = null;
                          });
                        },
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(16.0),
                    constraints: BoxConstraints(minHeight: 80.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color.fromARGB(255, 18, 63, 85),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Seleccionar canción",
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: '¿Cual es la canción de referencia?',
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),

              // Sección de búsqueda dinámica
              Visibility(
                visible: _searchController.text.isNotEmpty,
                child: Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final song = _searchResults[index];
                      return ListTile(
                        onTap: () {
                          setState(() {
                            _selectedSong = song;
                            selectedSongId = song['id'];
                            _searchController.clear();
                            FocusScope.of(context).requestFocus(FocusNode());
                          });
                        },
                        leading: song['album']['images'].isNotEmpty
                            ? Image.network(song['album']['images'][0]['url'])
                            : null,
                        title: Text(song['name']),
                        subtitle: Text(song['artists'][0]['name']),
                      );
                    },
                  ),
                ),
              ),

              // Sección de filtros
              Visibility(
                visible:
                    _searchController.text.isEmpty && !_showAdvancedResults,
                child: Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Text(
                        "Filtros",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      _buildRangeFilter(
                          "Popularidad",
                          (min) => popularityMin = min,
                          (max) => popularityMax = max),
                      _buildRangeFilter(
                          "Bailabilidad",
                          (min) => danceabilityMin = min,
                          (max) => danceabilityMax = max),
                      _buildRangeFilter("Acústica", (min) => acousticsMin = min,
                          (max) => acousticsMax = max),
                      _buildRangeFilter("Energía", (min) => energyMin = min,
                          (max) => energyMax = max),
                      _buildRangeFilter(
                          "Positividad",
                          (min) => positivityMin = min,
                          (max) => positivityMax = max),
                      DropdownButtonFormField<String>(
                        value: tone,
                        onChanged: (String? newValue) {
                          setState(() {
                            tone = newValue;
                            if (newValue != null) {
                              toneKey = toneToKeyMap[newValue];
                            } else {
                              toneKey = null;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Tono',
                          border: OutlineInputBorder(),
                        ),
                        items: <String>[
                          "C",
                          "C#",
                          "D",
                          "D#",
                          "E",
                          "F",
                          "F#",
                          "G",
                          "G#",
                          "A",
                          "A#",
                          "B"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        onChanged: (value) => bpm = int.tryParse(value),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'BPM',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: ElevatedButton(
                            onPressed: _performAdvancedSearch,
                            child: Text("Búsqueda Avanzada"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  final Map<String, int> toneToKeyMap = {
    "C": 0,
    "C#": 1,
    "D": 2,
    "D#": 3,
    "E": 4,
    "F": 5,
    "F#": 6,
    "G": 7,
    "G#": 8,
    "A": 9,
    "A#": 10,
    "B": 11
  };

  Widget _buildRangeFilter(String label, Function(double) onMinChanged,
      Function(double) onMaxChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  double? parsedValue = double.tryParse(value);
                  if (parsedValue != null) {
                    onMinChanged(parsedValue);
                  }
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Mínimo',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  double? parsedValue = double.tryParse(value);
                  if (parsedValue != null) {
                    onMaxChanged(parsedValue);
                  }
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Máximo',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  void _navigateToTrackPage(Map<String, dynamic> track) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackPage(trackId: track["id"])
      ),
    );
  }
}
