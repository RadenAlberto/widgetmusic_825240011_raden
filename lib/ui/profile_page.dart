import 'package:flutter/material.dart';
import '../model/song_model.dart';
import '../service/favorites_service.dart';
import 'player_detail_page.dart';

// Halaman Profil Pengguna & Koleksi Playlist
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Data profil pengguna yang dapat diubah
  String _userName = 'Raden Alberto Lumintu Negoro';
  String _userBio = 'Mahasiswa Sistem Informasi UNTAR';
  String _avatarUrl = '';

  // Dialog untuk mengedit profil (Nama, Bio, Foto Profil)
  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    final TextEditingController bioController = TextEditingController(text: _userBio);
    final TextEditingController avatarController = TextEditingController(text: _avatarUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.deepPurpleAccent),
              SizedBox(width: 8),
              Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama Anda',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Diri',
                    hintText: 'Masukkan bio singkat',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: avatarController,
                  decoration: const InputDecoration(
                    labelText: 'URL Foto Profil (Opsional)',
                    hintText: 'https://example.com/foto.jpg',
                    prefixIcon: Icon(Icons.image),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                final newBio = bioController.text.trim();
                final newAvatar = avatarController.text.trim();

                if (newName.isNotEmpty) {
                  setState(() {
                    _userName = newName;
                    _userBio = newBio.isEmpty ? 'Belum ada deskripsi' : newBio;
                    _avatarUrl = newAvatar;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui!'),
                      backgroundColor: Colors.deepPurple,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Dialog untuk membuat playlist baru
  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buat Playlist Baru'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Nama Playlist',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  FavoritesService().createPlaylist(
                    name,
                    Colors.deepPurpleAccent,
                    Icons.music_note,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Playlist "$name" berhasil dibuat!')),
                  );
                }
              },
              child: const Text('Buat'),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan daftar lagu di dalam playlist tertentu (termasuk Lagu Disukai)
  void _showPlaylistSongs(BuildContext context, String title, List<Song> songs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: songs.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada lagu di playlist ini.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    song.artworkUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.deepPurple.shade100,
                                      child: const Icon(Icons.music_note, color: Colors.deepPurple),
                                    ),
                                  ),
                                ),
                                title: Text(song.trackName, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(song.artistName, maxLines: 1),
                                trailing: const Icon(Icons.play_arrow, color: Colors.deepPurpleAccent),
                                onTap: () {
                                  Navigator.pop(context);
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
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService();

    return Scaffold(
      // 1. App Bar Atas
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      // SingleChildScrollView membuat seluruh halaman bisa di-scroll agar responsif di layar kecil
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 2. Foto Profil (Avatar) & Info Pengguna
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurpleAccent,
              backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
              child: _avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _userBio,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),

            // 3. Tombol Edit Profil
            OutlinedButton.icon(
              onPressed: _showEditProfileDialog,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Profil'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 10),

            // 4. Header Judul Bagian Playlist & Tombol Tambah Playlist Baru
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Koleksi & Playlist',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.deepPurpleAccent,
                    ),
                    onPressed: () => _showCreatePlaylistDialog(context),
                    tooltip: 'Buat Playlist Baru',
                  ),
                ],
              ),
            ),

            // 5. Card "Lagu Disukai" (Real State dari FavoritesService)
            ValueListenableBuilder<List<Song>>(
              valueListenable: favoritesService.likedSongsNotifier,
              builder: (context, likedSongs, _) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.redAccent),
                    ),
                    title: const Text(
                      'Lagu Disukai',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${likedSongs.length} Lagu'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      _showPlaylistSongs(context, 'Lagu Disukai', likedSongs);
                    },
                  ),
                );
              },
            ),

            // 6. List Playlist Kustom Real dari User
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: favoritesService.playlistsNotifier,
              builder: (context, playlists, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final songs = playlist['songs'] as List<Song>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (playlist['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            playlist['icon'] as IconData,
                            color: playlist['color'] as Color,
                          ),
                        ),
                        title: Text(
                          playlist['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${songs.length} Lagu'),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () {
                          _showPlaylistSongs(context, playlist['title'] as String, songs);
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

