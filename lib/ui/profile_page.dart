import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> userPlaylists = [
      {
        "title": "Lagu Disukai",
        "count": "24 Lagu",
        "icon": Icons.favorite,
        "color": Colors.redAccent,
      },
      {
        "title": "Pop Hits 2026",
        "count": "15 Lagu",
        "icon": Icons.music_note,
        "color": Colors.deepPurple,
      },
      {
        "title": "Fokus Belajar",
        "count": "10 Lagu",
        "icon": Icons.headphones,
        "color": Colors.blueAccent,
      },
      {
        "title": "Workout Vibes",
        "count": "8 Lagu",
        "icon": Icons.fitness_center,
        "color": Colors.orange,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurpleAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 15),
            const Text(
              'Raden Alberto Lumintu Negoro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              'Mahasiswa Sistem Informasi UNTAR',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur edit profil belum tersedia'),
                  ),
                );
              },
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Membuat playlist baru...'),
                        ),
                      );
                    },
                    tooltip: 'Buat Playlist Baru',
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = userPlaylists[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (playlist['color'] as Color).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        playlist['icon'],
                        color: playlist['color'],
                      ),
                    ),
                    title: Text(
                      playlist['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(playlist['count']),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Membuka ${playlist['title']}'),
                        ),
                      );
                    },
                  ),
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
