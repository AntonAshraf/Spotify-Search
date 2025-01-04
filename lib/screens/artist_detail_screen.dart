import 'package:flutter/material.dart';
import 'package:spotify_lyrics/screens/lyrics_screen.dart';
import 'package:spotify_lyrics/services/spotify_service.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistName;

  const ArtistDetailScreen({super.key, required this.artistName});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  final SpotifyService _spotifyService = SpotifyService();
  String? _artistInfo;
  String? _artistImage;
  List<Map<String, String>> _topTracks = [];

  Future<void> _searchArtist(String artistName) async {
    setState(() {
      _artistInfo = null;
      _artistImage = null;
      _topTracks = [];
    });

    final artistData = await _spotifyService.fetchArtistData(artistName);

    if (!mounted) return; // Ensure the widget is still mounted.

    if (artistData != null) {
      setState(() {
        _artistInfo = artistData['info'];
        _artistImage = artistData['image'];
        _topTracks = List<Map<String, String>>.from(artistData['topTracks']);
      });
    } else {
      setState(() {
        _artistInfo = 'Artist not found.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchArtist(widget.artistName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                if (_artistImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                        _artistImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                    )
                  ),
                if (_artistImage == null)
                  const Icon(
                    Icons.person,
                    size: 100,
                  ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.artistName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_artistInfo != null)
                      Text(
                        _artistInfo!.split('\n')[1],
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (_topTracks.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Top Tracks:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _topTracks.length,
                  itemBuilder: (context, index) {
                    final track = _topTracks[index];
                    return Card(
                      color: Colors.green[50],
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LyricsScreen(
                                  trackName: track['name']!,
                                  artistName: _artistInfo!
                                      .split('\n')
                                      .first
                                      .split(': ')[1],
                                  songImage: track['image'] ?? ''),
                            ),
                          );
                        },
                        leading: track['image']!.isNotEmpty
                            ? Image.network(
                                track['image']!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.music_note),
                        title: Text(track['name']!),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_topTracks.isEmpty && _artistInfo != null)
              Center(child: const Text('No Tracks Found.')),
          ],
        ),
      ),
    );
  }
}
