class Song {
  final String trackName;
  final String artistName;
  final String artworkUrl;
  final String previewUrl;

  // Konstruktor model data lagu
  Song({
    required this.trackName,
    required this.artistName,
    required this.artworkUrl,
    required this.previewUrl,
  });

  // Factory method untuk melakukan parsing dari JSON API ke objek Dart secara aman
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      trackName: json['trackName'] ?? 'Unknown Track', // Fallback jika null
      artistName: json['artistName'] ?? 'Unknown Artist',
      artworkUrl: json['artworkUrl100'] ?? '', // Mengambil resolusi gambar 100x100
      previewUrl: json['previewUrl'] ?? '', // URL audio mp3 (preview 30 detik)
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song &&
          runtimeType == other.runtimeType &&
          trackName == other.trackName &&
          artistName == other.artistName;

  @override
  int get hashCode => trackName.hashCode ^ artistName.hashCode;
}
