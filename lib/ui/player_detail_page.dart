import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/song_model.dart';

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

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _playSong();
  }

  Future<void> _playSong() async {
    final song = widget.songsList[_currentIndex];
    await _audioPlayer.stop();
    if (song.previewUrl.isNotEmpty) {
      await _audioPlayer.play(UrlSource(song.previewUrl));
    }
  }

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

  void _previousSong() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _playSong();
    }
  }

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
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.songsList[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedang Diputar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Artwork Sampul Lagu
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: song.artworkUrl.isNotEmpty
                  ? Image.network(
                      song.artworkUrl.replaceAll('100x100bb', '400x400bb'),
                      width: 260,
                      height: 260,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 260,
                        height: 260,
                        color: Colors.deepPurple.shade100,
                        child: const Icon(Icons.music_note, size: 100, color: Colors.deepPurple),
                      ),
                    )
                  : Container(
                      width: 260,
                      height: 260,
                      color: Colors.deepPurple.shade100,
                      child: const Icon(Icons.music_note, size: 100, color: Colors.deepPurple),
                    ),
            ),
            const SizedBox(height: 30),

            // Judul Lagu & Artis
            Text(
              song.trackName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              song.artistName,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Progress Slider
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
            const SizedBox(height: 20),

            // Kontrol Pemutar Musik (Previous, Play/Pause, Next)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 42,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _currentIndex > 0 ? _previousSong : null,
                ),
                const SizedBox(width: 20),
                IconButton(
                  iconSize: 64,
                  color: Colors.deepPurpleAccent,
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  onPressed: _togglePlayPause,
                ),
                const SizedBox(width: 20),
                IconButton(
                  iconSize: 42,
                  icon: const Icon(Icons.skip_next),
                  onPressed: _currentIndex < widget.songsList.length - 1 ? _nextSong : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
