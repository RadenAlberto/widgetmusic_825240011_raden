import 'package:flutter/material.dart';
import '../main.dart';
import '../model/song_model.dart';
import '../service/api_service.dart';
import '../service/favorites_service.dart';
import 'player_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();
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

  void _showAddToPlaylistDialog(Song song) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final playlists = _favoritesService.playlistsNotifier.value;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambahkan ke Playlist',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              if (playlists.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Belum ada playlist. Buat playlist baru di halaman Profil.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final pl = playlists[index];
                    return ListTile(
                      leading: Icon(pl['icon'] as IconData, color: pl['color'] as Color),
                      title: Text(pl['title'] as String),
                      onTap: () {
                        _favoritesService.addSongToPlaylist(index, song);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Berhasil ditambahkan ke ${pl['title']}')),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadSongs(_searchController.text.isEmpty ? "pop" : _searchController.text),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
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
                return ValueListenableBuilder<List<Song>>(
                  valueListenable: _favoritesService.likedSongsNotifier,
                  builder: (context, likedSongs, _) {
                    return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        final isFav = _favoritesService.isFavorite(song);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                song.artworkUrl,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 55,
                                  height: 55,
                                  color: Colors.deepPurple.shade100,
                                  child: const Icon(Icons.music_note, color: Colors.deepPurple),
                                ),
                              ),
                            ),
                            title: Text(song.trackName, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(song.artistName, maxLines: 1),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: isFav ? Colors.redAccent : Colors.grey,
                                  ),
                                  onPressed: () {
                                    _favoritesService.toggleFavorite(song);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.playlist_add, color: Colors.deepPurpleAccent),
                                  onPressed: () => _showAddToPlaylistDialog(song),
                                ),
                              ],
                            ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
