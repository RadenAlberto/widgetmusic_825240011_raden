// File: lib/ui/home_page.dart
import 'package:flutter/material.dart';
import '../main.dart'; // Import untuk mengakses themeNotifier
import '../model/song_model.dart';
import '../service/api_service.dart';
import 'player_detail_page.dart'; // Import halaman detail baru

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  void _loadSongs([String query = "pop"]) {
    setState(() {
      _songsFuture = _apiService.fetchSongs(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // 1. Tombol Refresh Manual
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadSongs(_searchController.text.isEmpty ? "pop" : _searchController.text),
            tooltip: 'Refresh Data',
          ),
          // 2. Tombol Toggle Dark Mode
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              // Membalikkan status tema
              themeNotifier.value = themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
            tooltip: 'Toggle Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari lagu atau artis...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) _loadSongs(value);
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Song>>(
              future: _songsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Lagu tidak ditemukan.'));
                }

                final songs = snapshot.data!;
                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(song.artworkUrl, width: 55, height: 55, fit: BoxFit.cover),
                        ),
                        title: Text(song.trackName, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(song.artistName, maxLines: 1),
                        trailing: const Icon(Icons.play_arrow, color: Colors.deepPurpleAccent),
                        // Logika saat lagu diklik: Buka halaman Player Detail
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerDetailPage(
                                songsList: songs,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}