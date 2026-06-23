String formatDurationClock(int totalSec) {
  final minutes = totalSec ~/ 60;
  final seconds = totalSec % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

int durationFromClock(int minutes, int seconds) => minutes * 60 + seconds;
