import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LyricsScreen extends StatelessWidget {
  final String trackName;
  final String artistName;

  const LyricsScreen({super.key, required this.trackName, required this.artistName});

  Future<String> fetchLyrics(String trackName) async {
    // List of inappropriate words
    final List<String> inappropriateWords = ['badword1', 'badword2', 'hello'];

    final response = await http.get(
      Uri.parse('https://api.lyrics.ovh/v1/$artistName/$trackName'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String lyrics = data['lyrics'] as String;

      // Replace inappropriate words with asterisks
      for (String word in inappropriateWords) {
        final regex = RegExp(r'\b' + word + r'\b', caseSensitive: false);
        lyrics = lyrics.replaceAllMapped(regex, (match) => '*' * match.group(0)!.length);
      }

      return lyrics;
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
