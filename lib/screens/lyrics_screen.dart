import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_lyrics/screens/artist_detail_screen.dart';
import 'package:spotify_lyrics/utils/badwords.dart';

class LyricsScreen extends StatelessWidget {
  final String trackName;
  final String artistName;
  final String songImage;

  const LyricsScreen(
      {super.key,
      required this.trackName,
      required this.artistName,
      required this.songImage});

  Future<String> fetchLyrics(String trackName) async {
    // List of inappropriate words
    final List<String> inappropriateWords = badWords;

    final response = await http.get(
      Uri.parse(
          'https://lrclib.net/api/get?artist_name=$artistName&track_name=$trackName'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Debug: Print the full response for testing
      // print("API Response: $data");

      if (data.containsKey('plainLyrics') && data['plainLyrics'] != null) {
        // Decode the plainLyrics
        String lyrics =
            utf8.decode(data['plainLyrics'].toString().runes.toList());

        // Replace inappropriate words with asterisks
        for (String word in inappropriateWords) {
          final regex = RegExp(r'\b' + word + r'\b', caseSensitive: false);
          lyrics = lyrics.replaceAllMapped(
              regex, (match) => '*' * match.group(0)!.length);
        }

        return lyrics;
      } else {
        return "No lyrics found in the response.";
      }
    } else {
      return "Failed to fetch lyrics: ${response.statusCode}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lyrics: $artistName - $trackName'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: ClipRRect(
                child: Image.network(songImage, width: 40, height: 40),
                borderRadius: BorderRadius.circular(25)),
            onPressed: () {
              Navigator.popUntil(
                context,
                ModalRoute.withName('/'),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ArtistDetailScreen(artistName: artistName),
                ),
              );
            },
          ),
          SizedBox(width: 5),
        ],
      ),
      backgroundColor: Colors.green[50],
      body: SingleChildScrollView(
        child: FutureBuilder<String>(
          future: fetchLyrics(trackName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error fetching lyrics: ${snapshot.error}'),
              );
            } else if (snapshot.data == "No lyrics found in the response." ||
                snapshot.data!.startsWith("Failed to fetch lyrics")) {
              return Center(
                child: Text(snapshot.data ?? "No lyrics found."),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(snapshot.data ?? 'No lyrics found.'),
              );
            }
          },
        ),
      ),
    );
  }
}
