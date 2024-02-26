import 'package:flutter/material.dart';
import 'package:beatsleuth2/data/services/spotify_service.dart';

class PlaylistPage extends StatelessWidget {
  final Map<String, dynamic> playlist;

  PlaylistPage(this.playlist);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              playlist['images'][0]['url'],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 24.0),
            Text(
              playlist['name'],
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            if (playlist['description'] != null)
              Text(
                playlist['description'],
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

