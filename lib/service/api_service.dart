import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/song_model.dart';

class ApiService {
  // Fungsi pencarian lagu secara dinamis (default query: 'pop')
  Future<List<Song>> fetchSongs({String query = "pop"}) async {
    // Endpoint API iTunes, membatasi hasil 15 agar rapi
    final String url = 'https://itunes.apple.com/search?term=$query&entity=song&limit=15';

    try {
      final response = await http.get(Uri.parse(url));

      // Validasi status code HTTP
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        // Map data JSON ke dalam List of Song
        return results.map((json) => Song.fromJson(json)).toList();
      } else {
        // Melempar error jika status bukan 200 OK
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Menangani error koneksi atau parsing
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}