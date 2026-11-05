import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/song_model.dart';

// Halaman Detail Pemutar Musik yang menampilkan lagu sedang diputar dan kontrol audio
class PlayerDetailPage extends StatefulWidget {
  final List<Song> songsList;
  final int initialIndex;

  const PlayerDetailPage({
    Key? key,
    required this.songsList,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  late int _currentIndex;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _audioPlayer = AudioPlayer();

    // Mendengarkan perubahan status pemutar (Play/Pause)
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Mendengarkan durasi total lagu
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    // Mendengarkan posisi detik lagu yang sedang berjalan
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    // Otomatis memutar lagu pertama saat halaman dibuka
    _playSong();
  }

  // Fungsi untuk memutar lagu sesuai index aktif
  Future<void> _playSong() async {
    final song = widget.songsList[_currentIndex];
    await _audioPlayer.stop();
    if (song.previewUrl.isNotEmpty) {
      await _audioPlayer.play(UrlSource(song.previewUrl));
    }
  }

  // Toggle tombol Play / Pause
  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_position >= _duration && _duration != Duration.zero) {
        await _audioPlayer.seek(Duration.zero);
      }
      final song = widget.songsList[_currentIndex];
      if (song.previewUrl.isNotEmpty) {
        await _audioPlayer.play(UrlSource(song.previewUrl));
      }
    }
  }

  // Berpindah ke lagu sebelumnya
  void _previousSong() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _playSong();
    }
  }

  // Berpindah ke lagu berikutnya
  void _nextSong() {
    if (_currentIndex < widget.songsList.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _playSong();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Membersihkan resource audio saat halaman ditutup
    super.dispose();
  }

  // Format durasi dari detik ke menit:detik (misal 01:30)
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.songsList[_currentIndex];
    final screenSize = MediaQuery.of(context).size;
    // Ukuran gambar responsif mengikuti tinggi & lebar layar agar tidak overflow
    final double imageSize = (screenSize.height * 0.30).clamp(140.0, 260.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedang Diputar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // SingleChildScrollView + SafeArea agar responsif & bebas error overflow di layar kecil/landscape
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // 1. Gambar Sampul Lagu (Artwork)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: song.artworkUrl.isNotEmpty
                      ? Image.network(
                          song.artworkUrl.replaceAll('100x100bb', '400x400bb'),
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: imageSize,
                            height: imageSize,
                            color: Colors.deepPurple.shade100,
                            child: Icon(Icons.music_note, size: imageSize * 0.4, color: Colors.deepPurple),
                          ),
                        )
                      : Container(
                          width: imageSize,
                          height: imageSize,
                          color: Colors.deepPurple.shade100,
                          child: Icon(Icons.music_note, size: imageSize * 0.4, color: Colors.deepPurple),
                        ),
                ),
                const SizedBox(height: 20),

                // 2. Informas Judul Lagu & Artis
                Text(
                  song.trackName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  song.artistName,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // 3. Slider Waktu & Durasi Pemutaran Lagu
                Slider(
                  min: 0.0,
                  max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                  value: _position.inSeconds.toDouble().clamp(
                        0.0,
                        _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                      ),
                  activeColor: Colors.deepPurpleAccent,
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 4. Tombol Kontrol Musik (Previous, Play/Pause, Next)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 38,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: _currentIndex > 0 ? _previousSong : null,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      iconSize: 58,
                      color: Colors.deepPurpleAccent,
                      icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                      onPressed: _togglePlayPause,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      iconSize: 38,
                      icon: const Icon(Icons.skip_next),
                      onPressed: _currentIndex < widget.songsList.length - 1 ? _nextSong : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
