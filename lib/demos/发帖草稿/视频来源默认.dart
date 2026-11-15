import 'package:video_player/video_player.dart';

Future<VideoPlayerController> draftVideoController(String source) async =>
    VideoPlayerController.networkUrl(Uri.parse(source));
