import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';
import '视频来源.dart';

import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

class DraftVideoPreview extends StatefulWidget {
  const DraftVideoPreview({super.key, required this.source});
  final String source;
  @override
  State<DraftVideoPreview> createState() => _DraftVideoState();
}

class _DraftVideoState extends State<DraftVideoPreview> {
  VideoPlayerController? controller;
  bool error = false;
  int generation = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final current = ++generation;
    setState(() => error = false);
    VideoPlayerController? next;
    try {
      next = await draftVideoController(widget.source);
      if (!mounted || current != generation) {
        await next.dispose();
        return;
      }
      await next.initialize();
      if (!mounted || current != generation) {
        await next.dispose();
        return;
      }
      final previous = controller;
      setState(() => controller = next);
      await previous?.dispose();
    } catch (_) {
      await next?.dispose();
      if (mounted && current == generation) setState(() => error = true);
    }
  }

  @override
  void dispose() {
    generation++;
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(uiTr(context, '视频'))),
    body: error
        ? uiEmpty(context, load)
        : controller == null
        ? const Center(child: CircularProgressIndicator())
        : ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller!,
            builder: (context, value, _) => Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: value.aspectRatio,
                      child: VideoPlayer(controller!),
                    ),
                  ),
                ),
                VideoProgressIndicator(controller!, allowScrubbing: true),
                IconButton(
                  tooltip: uiTr(context, value.isPlaying ? '暂停' : '开始'),
                  onPressed: () => value.isPlaying
                      ? controller!.pause()
                      : controller!.play(),
                  icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              ],
            ),
          ),
  );
}
