// lib/services/spotify_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyService {

  final String _clientId = dotenv.get('SPOTIFY_CLIENT_ID');
  final String _clientSecret = dotenv.get('SPOTIFY_CLIENT_SECRET');

  Future<String?> _getAccessToken() async {
    final String credentials =
        base64Encode(utf8.encode('$_clientId:$_clientSecret'));

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['access_token'];
    } else {
      if (kDebugMode) {
        print('Failed to get access token: ${response.statusCode}');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchArtistData(String artistName) async {
    final token = await _getAccessToken();
    if (token == null) return null;

    final artistResponse = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$artistName&type=artist&limit=1'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (artistResponse.statusCode == 200) {
      final Map<String, dynamic> artistData = json.decode(artistResponse.body);
      if (artistData['artists']['items'].isNotEmpty) {
        final artist = artistData['artists']['items'][0];
        final artistId = artist['id'];
        final image =
            artist['images'].isNotEmpty ? artist['images'][0]['url'] : null;
        final topTracks = await _fetchTopTracks(artistId, token);

        return {
          'info': 'Artist: ${artist['name']}\n'
                  'Followers: ${artist['followers']['total']}\n'
                  'Genres: ${artist['genres'].join(', ')}\n'
                  'Popularity: ${artist['popularity']}',
          'image': image,
          'topTracks': topTracks,
        };
      }
    }

    return null;
  }

  Future<List<Map<String, String>>> _fetchTopTracks(String artistId, String token) async {
    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/artists/$artistId/top-tracks?market=US'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> tracks = json.decode(response.body)['tracks'];
      return tracks.map((track) {
        return {
          'name': track['name'].toString(),
          'image': track['album']['images'].isNotEmpty
              ? track['album']['images'][0]['url'].toString()
              : '',
        };
      }).toList().cast<Map<String, String>>();
    } else {
      if (kDebugMode) {
        print('Error fetching top tracks: ${response.statusCode}');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> searchArtists(String query) async {
    final token = await _getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$query&type=artist&limit=10'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> artists = data['artists']['items'];
      return artists.map((artist) {
        return {
          'id': artist['id'],
          'name': artist['name'],
          'followers': artist['followers']['total'],
          'genres': artist['genres'],
          'popularity': artist['popularity'],
          'image': artist['images'].isNotEmpty ? artist['images'][0]['url'] : null,
        };
      }).toList();
    } else {
      if (kDebugMode) {
        print('Error searching artists: ${response.statusCode}');
      }
      return null;
    }
  }
  Future<List<Map<String, dynamic>>?> searchSongs(String query) async {
    final token = await _getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track&limit=10'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> tracks = data['tracks']['items'];
      return tracks.map((track) {
        final album = track['album'];
        final artist = track['artists'][0]['name'].toString();

        return {
          'id': track['id'],
          'name': track['name'],
          'album': album['name'],
          'artist': artist,
          'release_date': album['release_date'],
          'image': album['images'].isNotEmpty ? album['images'][0]['url'] : null,
          'popularity': track['popularity'],
        };
      }).toList();
    } else {
      if (kDebugMode) {
        print('Error searching songs: ${response.statusCode}');
      }
      return null;
    }
  }
}
