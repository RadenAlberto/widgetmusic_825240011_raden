import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/song_model.dart';
import '../service/favorites_service.dart';

enum LoopMode { off, all, one }

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
  final FavoritesService _favoritesService = FavoritesService();

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Fitur Shuffle & Loop
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;

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

    // Event ketika pemutaran lagu selesai
    _audioPlayer.onPlayerComplete.listen((_) {
      _handleSongCompletion();
    });

    _playSong();
  }

  void _handleSongCompletion() {
    if (!mounted) return;

    if (_loopMode == LoopMode.one) {
      // Ulangi lagu yang sama
      _playSong();
    } else if (_isShuffle && widget.songsList.length > 1) {
      // Mainkan lagu acak (random)
      int nextIndex;
      do {
        nextIndex = Random().nextInt(widget.songsList.length);
      } while (nextIndex == _currentIndex);
      setState(() {
        _currentIndex = nextIndex;
      });
      _playSong();
    } else {
      // Berurutan
      if (_currentIndex < widget.songsList.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _playSong();
      } else if (_loopMode == LoopMode.all) {
        // Ulangi dari lagu pertama
        setState(() {
          _currentIndex = 0;
        });
        _playSong();
      } else {
        // Selesai di akhir playlist
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    }
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
    if (_isShuffle && widget.songsList.length > 1) {
      int prevIndex;
      do {
        prevIndex = Random().nextInt(widget.songsList.length);
      } while (prevIndex == _currentIndex);
      setState(() {
        _currentIndex = prevIndex;
      });
    } else if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    } else {
      setState(() {
        _currentIndex = widget.songsList.length - 1;
      });
    }
    _playSong();
  }

  void _nextSong() {
    if (_isShuffle && widget.songsList.length > 1) {
      int nextIndex;
      do {
        nextIndex = Random().nextInt(widget.songsList.length);
      } while (nextIndex == _currentIndex);
      setState(() {
        _currentIndex = nextIndex;
      });
    } else if (_currentIndex < widget.songsList.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _currentIndex = 0;
      });
    }
    _playSong();
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isShuffle ? 'Fitur Acak (Shuffle) Aktif' : 'Fitur Acak (Shuffle) Matikan'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleLoopMode() {
    setState(() {
      if (_loopMode == LoopMode.off) {
        _loopMode = LoopMode.all;
      } else if (_loopMode == LoopMode.all) {
        _loopMode = LoopMode.one;
      } else {
        _loopMode = LoopMode.off;
      }
    });

    String message;
    switch (_loopMode) {
      case LoopMode.all:
        message = 'Ulangi Semua Lagu (Repeat All)';
        break;
      case LoopMode.one:
        message = 'Ulangi 1 Lagu (Repeat One)';
        break;
      case LoopMode.off:
        message = 'Pengulangan Dimatikan';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
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
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // Ukuran gambar proporsional
    final double imageSize = isLandscape
        ? (screenSize.height * 0.40).clamp(120.0, 200.0)
        : (screenSize.height * 0.32).clamp(160.0, 280.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedang Diputar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<List<Song>>(
            valueListenable: _favoritesService.likedSongsNotifier,
            builder: (context, likedSongs, _) {
              final isFav = _favoritesService.isFavorite(song);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : null,
                ),
                onPressed: () {
                  _favoritesService.toggleFavorite(song);
                },
                tooltip: isFav ? 'Hapus dari Suka' : 'Sukai Lagu',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 1. Gambar Sampul Lagu (Artwork)
                      Center(
                        child: ClipRRect(
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
                      ),
                      const SizedBox(height: 16),

                      // 2. Judul Lagu & Nama Artis
                      Column(
                        children: [
                          Text(
                            song.trackName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            song.artistName,
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Slider Durasi Musik
                      Column(
                        children: [
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Tombol Kontrol Musik (Shuffle, Previous, Play/Pause, Next, Loop)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Tombol Shuffle
                          IconButton(
                            iconSize: 28,
                            icon: Icon(
                              Icons.shuffle,
                              color: _isShuffle ? Colors.deepPurpleAccent : Colors.grey,
                            ),
                            onPressed: _toggleShuffle,
                            tooltip: 'Acak Lagu',
                          ),

                          // Tombol Previous
                          IconButton(
                            iconSize: 38,
                            icon: const Icon(Icons.skip_previous),
                            onPressed: _previousSong,
                            tooltip: 'Lagu Sebelumnya',
                          ),

                          // Tombol Play / Pause
                          IconButton(
                            iconSize: 64,
                            color: Colors.deepPurpleAccent,
                            icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                            onPressed: _togglePlayPause,
                          ),

                          // Tombol Next
                          IconButton(
                            iconSize: 38,
                            icon: const Icon(Icons.skip_next),
                            onPressed: _nextSong,
                            tooltip: 'Lagu Berikutnya',
                          ),

                          // Tombol Loop / Repeat
                          IconButton(
                            iconSize: 28,
                            icon: Icon(
                              _loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                              color: _loopMode != LoopMode.off ? Colors.deepPurpleAccent : Colors.grey,
                            ),
                            onPressed: _toggleLoopMode,
                            tooltip: 'Ulangi Lagu',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
