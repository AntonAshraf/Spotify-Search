import 'package:flutter/material.dart';
import 'package:spotify_lyrics/screens/artist_detail_screen.dart';
import 'package:spotify_lyrics/screens/lyrics_screen.dart';
import '../services/spotify_service.dart';

class ArtistSearchScreen extends StatefulWidget {
  const ArtistSearchScreen({super.key});

  @override
  _ArtistSearchScreenState createState() => _ArtistSearchScreenState();
}

class _ArtistSearchScreenState extends State<ArtistSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final SpotifyService _spotifyService = SpotifyService();

  TabController? _tabController;
  bool _isLoading = false;

  List<Map<String, dynamic>> _artists = [];
  List<Map<String, dynamic>> _songs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _artists = [];
      _songs = [];
    });

    // Fetch artists and songs in parallel
    final artistResults = await _spotifyService.searchArtists(query);
    final songResults = await _spotifyService.searchSongs(query);

    setState(() {
      if (artistResults != null) _artists = artistResults;
      if (songResults != null) _songs = songResults;
      _isLoading = false;
    });
  }

  Widget _buildArtistList() {
    if (_artists.isEmpty) {
      return Center(
        child: Image.asset(
          'assets/music.png',
          width: 150,
          height: 150,
          opacity: const AlwaysStoppedAnimation(0.5),
        ),
      );
    }

    return ListView.builder(
      itemCount: _artists.length,
      itemBuilder: (context, index) {
        final artist = _artists[index];
        return Card(
          color: Colors.green[50],
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            onTap: () async {
              final artistData =
                  await _spotifyService.searchArtists(artist['id'] ?? '');
              if (artistData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArtistDetailScreen(
                        artistName: artist['name'] ?? 'Unknown'),
                  ),
                );
              }
            },
            leading: (artist['image']?.isNotEmpty ?? false)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      artist['image']!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person),
            title: Text(artist['name'] ?? 'Unknown'),
          ),
        );
      },
    );
  }

  Widget _buildSongList() {
    if (_songs.isEmpty) {
      return Center(
        child: Image.asset(
          'assets/music.png',
          width: 150,
          height: 150,
          opacity: const AlwaysStoppedAnimation(0.5),
        ),
      );
    }

    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return Card(
          color: Colors.green[50],
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LyricsScreen(
                      trackName: song['name'] ?? 'Unknown',
                      artistName: song['artist'] ?? 'Unknown',
                      songImage: song['image'] ?? ''),
                ),
              );
            },
            leading: (song['image']?.isNotEmpty ?? false)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      song['image']!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.music_note),
            title: Text(song['name'] ?? 'Unknown'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Spotify Search', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
        leading: Row(
          children: [
            SizedBox(width: 16),
            Image.asset('assets/spotify_logo.png', width: 30, height: 30),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for artists or songs',
                labelStyle: TextStyle(color: Colors.green[900]),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.green[800] ?? Colors.green),
                ),
              ),
              cursorColor: Colors.green[700],
              onSubmitted: (query) => _search(query),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Artists'),
              Tab(text: 'Songs'),
            ],
            labelColor: Colors.green,
            indicatorColor: Colors.green,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildArtistList(),
                      _buildSongList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
