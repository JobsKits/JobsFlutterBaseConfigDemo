import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> draftVideoController(String source) async {
  if (!source.startsWith('data:'))
    return VideoPlayerController.file(File(source));
  final data = UriData.parse(source);
  final directory = await getTemporaryDirectory();
  final extension = data.mimeType == 'video/quicktime' ? 'mov' : 'mp4';
  final file = File(
    '${directory.path}/jobs-draft-${source.hashCode}.$extension',
  );
  await file.writeAsBytes(data.contentAsBytes(), flush: true);
  return VideoPlayerController.file(file);
}
