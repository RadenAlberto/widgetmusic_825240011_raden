import 'package:flutter/material.dart';
import '../model/song_model.dart';

// Service singleton untuk mengelola state Lagu Disukai (Favorites) & Playlist
class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  // ValueNotifier untuk daftar lagu yang disukai pengguna
  final ValueNotifier<List<Song>> likedSongsNotifier = ValueNotifier<List<Song>>([]);

  // ValueNotifier untuk playlist kustom pengguna
  final ValueNotifier<List<Map<String, dynamic>>> playlistsNotifier = ValueNotifier<List<Map<String, dynamic>>>([
    {
      "title": "Pop Hits 2026",
      "icon": Icons.music_note,
      "color": Colors.deepPurple,
      "songs": <Song>[],
    },
    {
      "title": "Fokus Belajar",
      "icon": Icons.headphones,
      "color": Colors.blueAccent,
      "songs": <Song>[],
    },
    {
      "title": "Workout Vibes",
      "icon": Icons.fitness_center,
      "color": Colors.orange,
      "songs": <Song>[],
    },
  ]);

  // Cek apakah lagu ada di daftar suka
  bool isFavorite(Song song) {
    return likedSongsNotifier.value.any((s) => s.trackName == song.trackName && s.artistName == song.artistName);
  }

  // Tambahkan atau hapus lagu dari daftar suka
  void toggleFavorite(Song song) {
    final list = List<Song>.from(likedSongsNotifier.value);
    if (isFavorite(song)) {
      list.removeWhere((s) => s.trackName == song.trackName && s.artistName == song.artistName);
    } else {
      list.add(song);
    }
    likedSongsNotifier.value = list;
  }

  // Tambahkan playlist baru
  void createPlaylist(String title, Color color, IconData icon) {
    final list = List<Map<String, dynamic>>.from(playlistsNotifier.value);
    list.add({
      "title": title,
      "icon": icon,
      "color": color,
      "songs": <Song>[],
    });
    playlistsNotifier.value = list;
  }

  // Tambahkan lagu ke playlist tertentu
  void addSongToPlaylist(int playlistIndex, Song song) {
    final list = List<Map<String, dynamic>>.from(playlistsNotifier.value);
    final songsList = List<Song>.from(list[playlistIndex]["songs"] as List<Song>);
    if (!songsList.any((s) => s.trackName == song.trackName && s.artistName == song.artistName)) {
      songsList.add(song);
      list[playlistIndex]["songs"] = songsList;
      playlistsNotifier.value = list;
    }
  }
}
